"""Luigi's Pizzeria: the order backend behind a demo voice agent.

The voice agent (ElevenLabs) writes orders through this API with its tools, and
Minitap's tester reads them back through the same documented API to check that
what the agent *said* is what it *did*.

Demo bugs can be switched on at runtime through the hidden ``/admin/bugs`` route,
so a "before fix" and an "after fix" take need no redeploy.
"""

from __future__ import annotations

import os
import re
import secrets
import threading
import uuid
from datetime import UTC, datetime, timedelta
from enum import StrEnum
from pathlib import Path
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Path as PathParam, Security, status
from fastapi.responses import FileResponse, JSONResponse
from fastapi.security import APIKeyHeader
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field, field_validator

from app.menu import MENU, MenuItem

API_KEY = os.environ.get("LUIGI_API_KEY", "dev-luigi-key")
STATIC_DIR = Path(__file__).parent / "static"

app = FastAPI(
    title="Luigi's Pizzeria API",
    version="1.0.0",
    description=(
        "Order backend of Luigi's Pizzeria phone line. The voice agent creates and "
        "updates delivery orders here. Every `/api` route needs the `X-API-Key` header."
    ),
    servers=[{"url": os.environ.get("LUIGI_PUBLIC_URL", "http://localhost:8080")}],
)

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False, description="Pizzeria API key")


def require_api_key(key: Annotated[str | None, Security(api_key_header)]) -> None:
    if key is None or not secrets.compare_digest(key, API_KEY):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing or invalid X-API-Key header")


# --------------------------------------------------------------------------- models


class OrderStatus(StrEnum):
    draft = "draft"
    confirmed = "confirmed"


class MenuItemOut(BaseModel):
    id: str
    name: str
    category: str
    price_eur: int
    ingredients: list[str]


class OrderLineIn(BaseModel):
    item_id: str = Field(description="Menu item id, from GET /api/menu (e.g. `regina`).")
    quantity: int = Field(1, ge=1, le=20)
    without: list[str] = Field(
        default_factory=list,
        description="Ingredients to remove, from the item's `ingredients` (e.g. `mushrooms`).",
    )


class OrderLine(OrderLineIn):
    name: str
    unit_price_eur: int
    line_total_eur: int


def _normalize_phone(raw: str) -> str:
    digits = re.sub(r"\D", "", raw)
    if digits.startswith("33") and len(digits) == 11:
        digits = "0" + digits[2:]
    if len(digits) < 6:
        raise ValueError("phone must contain at least 6 digits")
    return digits


class OrderCreate(BaseModel):
    customer_name: str = Field(min_length=1, max_length=80)
    phone: str = Field(description="Customer phone number. Any format; only digits are kept.")
    items: list[OrderLineIn] = Field(min_length=1)
    delivery_address: str | None = Field(None, max_length=200)

    @field_validator("phone")
    @classmethod
    def _clean_phone(cls, value: str) -> str:
        return _normalize_phone(value)


class OrderUpdate(BaseModel):
    items: list[OrderLineIn] | None = Field(
        None,
        min_length=1,
        description="The COMPLETE new list of items. It replaces the previous list.",
    )
    delivery_address: str | None = Field(None, max_length=200)


class Order(BaseModel):
    id: str
    customer_name: str
    phone: str
    items: list[OrderLine]
    delivery_address: str | None
    status: OrderStatus
    total_eur: int
    created_at: datetime
    updated_at: datetime
    estimated_delivery_at: datetime | None = None
    estimated_delivery_minutes: int | None = None


class BugSwitches(BaseModel):
    stale_items: bool = Field(
        False,
        description="PATCH appends the new items to the old ones instead of replacing them, "
        "while still answering with the requested items.",
    )
    drop_removals: bool = Field(
        False,
        description="Removed ingredients are dropped from storage (a Regina without mushrooms is "
        "stored with mushrooms), while the response still lists them.",
    )


# --------------------------------------------------------------------------- state

_lock = threading.Lock()
_orders: dict[str, Order] = {}  # the truth, as read back by GET routes
_claimed: dict[str, Order] = {}  # what write routes answer; differs only when a demo bug is on
_bugs = BugSwitches(
    stale_items=os.environ.get("BUG_STALE_ITEMS", "") == "1",
    drop_removals=os.environ.get("BUG_DROP_REMOVALS", "") == "1",
)


def _stored_lines(lines: list[OrderLine]) -> list[OrderLine]:
    """What actually reaches storage. DEMO BUG: ``drop_removals`` forgets the removed ingredients."""
    if not _bugs.drop_removals:
        return lines
    return [line.model_copy(update={"without": []}) for line in lines]


def _price_lines(lines: list[OrderLineIn]) -> list[OrderLine]:
    priced: list[OrderLine] = []
    for line in lines:
        item: MenuItem | None = MENU.get(line.item_id)
        if item is None:
            raise HTTPException(
                status.HTTP_422_UNPROCESSABLE_CONTENT,
                f"'{line.item_id}' is not on the menu. Available: {', '.join(MENU)}",
            )
        unknown = [ing for ing in line.without if ing not in item.ingredients]
        if unknown:
            raise HTTPException(
                status.HTTP_422_UNPROCESSABLE_CONTENT,
                f"{item.name} has no {', '.join(unknown)}. Ingredients: {', '.join(item.ingredients)}",
            )
        priced.append(
            OrderLine(
                **line.model_dump(),
                name=item.name,
                unit_price_eur=item.price,
                line_total_eur=item.price * line.quantity,
            )
        )
    return priced


def _total(lines: list[OrderLine]) -> int:
    return sum(line.line_total_eur for line in lines)


def _get_order(order_id: str) -> Order:
    order = _orders.get(order_id)
    if order is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, f"Order {order_id} not found")
    return order


# --------------------------------------------------------------------------- routes

api = Depends(require_api_key)
PhonePath = Annotated[str, PathParam(description="Customer phone number, digits only.")]


@app.get("/healthz", include_in_schema=False)
def healthz() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/menu", response_model=list[MenuItemOut], tags=["menu"], dependencies=[api])
def get_menu() -> list[MenuItemOut]:
    """The full menu with prices in euros and removable ingredients."""
    return [
        MenuItemOut(
            id=i.id, name=i.name, category=i.category, price_eur=i.price, ingredients=list(i.ingredients)
        )
        for i in MENU.values()
    ]


@app.post(
    "/api/orders",
    response_model=Order,
    status_code=status.HTTP_201_CREATED,
    tags=["orders"],
    dependencies=[api],
)
def create_order(body: OrderCreate) -> Order:
    """Open a new draft order for a customer."""
    now = datetime.now(UTC)
    lines = _price_lines(body.items)
    order = Order(
        id="ord_" + uuid.uuid4().hex[:8],
        customer_name=body.customer_name,
        phone=body.phone,
        items=lines,
        delivery_address=body.delivery_address,
        status=OrderStatus.draft,
        total_eur=_total(lines),
        created_at=now,
        updated_at=now,
    )
    stored_lines = _stored_lines(lines)
    with _lock:
        _claimed[order.id] = order
        _orders[order.id] = order.model_copy(update={"items": stored_lines, "total_eur": _total(stored_lines)})
    return order


@app.get("/api/orders/{order_id}", response_model=Order, tags=["orders"], dependencies=[api])
def get_order(order_id: str) -> Order:
    """Read one order as it is stored."""
    return _get_order(order_id)


@app.patch("/api/orders/{order_id}", response_model=Order, tags=["orders"], dependencies=[api])
def update_order(order_id: str, body: OrderUpdate) -> Order:
    """Change a draft order: replace its items and/or set the delivery address."""
    with _lock:
        stored = _get_order(order_id).model_copy()
        claimed = _claimed[order_id].model_copy()
        if stored.status is not OrderStatus.draft:
            raise HTTPException(status.HTTP_409_CONFLICT, "Confirmed orders cannot be changed")
        if body.items is not None:
            new_lines = _price_lines(body.items)
            kept = _stored_lines(new_lines)
            # DEMO BUG: stale_items keeps the old lines in storage.
            stored.items = [*stored.items, *kept] if _bugs.stale_items else kept
            claimed.items = new_lines
        if body.delivery_address is not None:
            stored.delivery_address = claimed.delivery_address = body.delivery_address
        stored.total_eur = _total(stored.items)
        claimed.total_eur = _total(claimed.items)
        stored.updated_at = claimed.updated_at = datetime.now(UTC)
        _orders[order_id], _claimed[order_id] = stored, claimed
    return claimed


@app.post("/api/orders/{order_id}/confirm", response_model=Order, tags=["orders"], dependencies=[api])
def confirm_order(order_id: str) -> Order:
    """Confirm a draft order. It needs a delivery address. Returns the estimated delivery time."""
    with _lock:
        stored = _get_order(order_id)
        if not stored.delivery_address:
            raise HTTPException(status.HTTP_409_CONFLICT, "Ask the customer for a delivery address first")
        update = {
            "status": OrderStatus.confirmed,
            "updated_at": datetime.now(UTC),
            "estimated_delivery_at": datetime.now(UTC) + timedelta(minutes=35),
            "estimated_delivery_minutes": 35,
        }
        _orders[order_id] = stored.model_copy(update=update)
        _claimed[order_id] = _claimed[order_id].model_copy(update=update)
    return _claimed[order_id]


@app.get(
    "/api/customers/{phone}/orders",
    response_model=list[Order],
    tags=["customers"],
    dependencies=[api],
)
def list_customer_orders(phone: PhonePath) -> list[Order]:
    """Every order placed with this phone number, oldest first."""
    key = _normalize_phone(phone)
    return sorted((o for o in _orders.values() if o.phone == key), key=lambda o: o.created_at)


@app.delete(
    "/api/customers/{phone}/orders",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["customers"],
    dependencies=[api],
)
def delete_customer_orders(phone: PhonePath) -> None:
    """Delete every order of this phone number. Use it to start a test from a clean slate."""
    key = _normalize_phone(phone)
    with _lock:
        for order_id in [i for i, o in _orders.items() if o.phone == key]:
            del _orders[order_id]
            _claimed.pop(order_id, None)


@app.get("/admin/bugs", response_model=BugSwitches, include_in_schema=False, dependencies=[api])
def get_bugs() -> BugSwitches:
    return _bugs


@app.put("/admin/bugs", response_model=BugSwitches, include_in_schema=False, dependencies=[api])
def set_bugs(body: BugSwitches) -> BugSwitches:
    global _bugs
    _bugs = body
    return _bugs


# --------------------------------------------------------------------------- web page


@app.get("/config.json", include_in_schema=False)
def web_config() -> JSONResponse:
    return JSONResponse(
        {
            "agents": {
                "default": os.environ.get("ELEVENLABS_AGENT_ID", ""),
                "deaf": os.environ.get("ELEVENLABS_AGENT_ID_DEAF", ""),
                "forgetful": os.environ.get("ELEVENLABS_AGENT_ID_FORGETFUL", ""),
            }
        }
    )


@app.get("/", include_in_schema=False)
def index() -> FileResponse:
    return FileResponse(STATIC_DIR / "index.html")


app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")
