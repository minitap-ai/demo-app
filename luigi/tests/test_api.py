import pytest
from fastapi.testclient import TestClient

from app import main

H = {"X-API-Key": "dev-luigi-key"}
PHONE = "06 12 34 56 78"


@pytest.fixture(autouse=True)
def clean_state():
    main._orders.clear()
    main._claimed.clear()
    main._bugs = main.BugSwitches()
    yield


client = TestClient(main.app)


def _create(items):
    r = client.post(
        "/api/orders",
        headers=H,
        json={"customer_name": "Marco", "phone": PHONE, "items": items},
    )
    assert r.status_code == 201, r.text
    return r.json()


def test_auth_required():
    assert client.get("/api/menu").status_code == 401
    assert client.get("/api/menu", headers={"X-API-Key": "nope"}).status_code == 401
    assert client.get("/openapi.json").status_code == 200


def test_order_flow_replaces_items():
    order = _create([{"item_id": "quattro_formaggi"}])
    assert order["phone"] == "0612345678"
    assert order["total_eur"] == 13

    patched = client.patch(
        f"/api/orders/{order['id']}",
        headers=H,
        json={
            "items": [{"item_id": "regina", "quantity": 2, "without": ["mushrooms"]}],
            "delivery_address": "12 rue de la Paix",
        },
    ).json()
    assert patched["total_eur"] == 24

    stored = client.get("/api/customers/+33612345678/orders", headers=H).json()
    assert len(stored) == 1
    assert [(i["item_id"], i["quantity"], i["without"]) for i in stored[0]["items"]] == [
        ("regina", 2, ["mushrooms"])
    ]
    assert stored[0]["total_eur"] == 24

    confirmed = client.post(f"/api/orders/{order['id']}/confirm", headers=H).json()
    assert confirmed["status"] == "confirmed"
    assert confirmed["estimated_delivery_at"]


def test_stale_items_bug_lies_in_response_but_keeps_old_items():
    client.put("/admin/bugs", headers=H, json={"stale_items": True})
    order = _create([{"item_id": "quattro_formaggi"}])
    patched = client.patch(
        f"/api/orders/{order['id']}",
        headers=H,
        json={"items": [{"item_id": "regina", "quantity": 2, "without": ["mushrooms"]}]},
    ).json()
    assert patched["total_eur"] == 24
    assert [i["item_id"] for i in patched["items"]] == ["regina"]

    # An address-only update must keep lying, or the agent notices and "fixes" it.
    address = client.patch(
        f"/api/orders/{order['id']}", headers=H, json={"delivery_address": "12 rue de la Paix"}
    ).json()
    assert address["total_eur"] == 24
    confirmed = client.post(f"/api/orders/{order['id']}/confirm", headers=H).json()
    assert confirmed["total_eur"] == 24

    stored = client.get(f"/api/orders/{order['id']}", headers=H).json()
    assert [i["item_id"] for i in stored["items"]] == ["quattro_formaggi", "regina"]
    assert stored["total_eur"] == 37
    assert stored["status"] == "confirmed"


def test_off_menu_and_bad_ingredient_rejected():
    r = client.post(
        "/api/orders",
        headers=H,
        json={"customer_name": "M", "phone": PHONE, "items": [{"item_id": "pineapple_chorizo"}]},
    )
    assert r.status_code == 422
    assert "not on the menu" in r.text
    r = client.post(
        "/api/orders",
        headers=H,
        json={
            "customer_name": "M",
            "phone": PHONE,
            "items": [{"item_id": "margherita", "without": ["mushrooms"]}],
        },
    )
    assert r.status_code == 422


def test_confirm_requires_address_and_reset():
    order = _create([{"item_id": "diavola"}])
    assert client.post(f"/api/orders/{order['id']}/confirm", headers=H).status_code == 409
    assert client.delete(f"/api/customers/{PHONE}/orders", headers=H).status_code == 204
    assert client.get(f"/api/customers/{PHONE}/orders", headers=H).json() == []


def test_admin_routes_hidden_from_spec():
    paths = client.get("/openapi.json").json()["paths"]
    assert "/admin/bugs" not in paths
    assert "/api/customers/{phone}/orders" in paths


def test_drop_removals_bug_stores_mushrooms_back():
    client.put("/admin/bugs", headers=H, json={"drop_removals": True})
    order = _create([{"item_id": "regina", "quantity": 2, "without": ["mushrooms"]}])
    assert order["items"][0]["without"] == ["mushrooms"]
    stored = client.get(f"/api/orders/{order['id']}", headers=H).json()
    assert stored["items"][0]["without"] == []


def test_swap_phone_digits_bug_hides_the_order_from_its_customer():
    client.put("/admin/bugs", headers=H, json={"swap_phone_digits": True})
    order = _create([{"item_id": "margherita"}])
    assert order["phone"] == "0612345678"
    assert client.get(f"/api/customers/{PHONE}/orders", headers=H).json() == []
    stored = client.get(f"/api/orders/{order['id']}", headers=H).json()
    assert stored["phone"] == "0612345687"
