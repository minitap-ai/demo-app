"""Create or update Luigi's ElevenLabs voice agents and their webhook tools.

Idempotent: tools and agents are matched by name and updated in place.

    ELEVENLABS_API_KEY=... LUIGI_PUBLIC_URL=https://... LUIGI_API_KEY=... \
        uv run python provision_elevenlabs.py

Prints the two agent ids to set as ELEVENLABS_AGENT_ID / ELEVENLABS_AGENT_ID_DEAF.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

API = "https://api.elevenlabs.io/v1/convai"
KEY = os.environ["ELEVENLABS_API_KEY"]
BASE = os.environ["LUIGI_PUBLIC_URL"].rstrip("/")
LUIGI_KEY = os.environ["LUIGI_API_KEY"]
VOICE_ID = os.environ.get("LUIGI_VOICE_ID", "pNInz6obpgDQGcFmaJgB")
LLM = os.environ.get("LUIGI_LLM", "gemini-2.5-flash")
LANGUAGE = os.environ.get("LUIGI_LANGUAGE", "en")

PROMPT = (Path(__file__).parent / "agent_prompt.md").read_text()
FIRST_MESSAGE = "Luigi's Pizzeria, Luigi speaking! What can I get you tonight?"
# The multilingual flash TTS covers these; Luigi switches when the caller does.
EXTRA_LANGUAGES = {
    "it": "Pizzeria da Luigi, sono Luigi! Cosa le preparo stasera?",
    "zh": "您好，这里是Luigi披萨店，我是Luigi！今晚想吃点什么？",
    "fr": "Pizzeria Luigi, ici Luigi ! Qu'est-ce que je vous prépare ce soir ?",
}


def call(method: str, path: str, body: dict | None = None) -> dict:
    req = urllib.request.Request(
        API + path,
        method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"xi-api-key": KEY, "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as err:
        sys.exit(f"{method} {path} -> {err.code}: {err.read().decode()}")


def s(type_: str, description: str, **extra) -> dict:
    return {"type": type_, "description": description, **extra}


LINE_ITEMS = s(
    "array",
    "The COMPLETE list of items the customer wants right now.",
    items={
        "type": "object",
        "description": "One order line",
        "properties": {
            "item_id": s("string", "Menu item id from get_menu, e.g. regina"),
            "quantity": s("integer", "How many"),
            "without": s(
                "array",
                "Ingredients to remove, using the ids from get_menu, e.g. mushrooms. Empty if none.",
                items=s("string", "Ingredient"),
            ),
        },
        "required": ["item_id", "quantity", "without"],
    },
)
HEADERS = {"X-API-Key": LUIGI_KEY}
ORDER_ID = {"order_id": s("string", "The exact `id` field returned by create_order. Never make one up.")}

TOOLS = [
    {
        "name": "get_menu",
        "description": "Get the menu: item ids, prices in euros and removable ingredients. Call it once at the start of every call.",
        "api_schema": {"url": f"{BASE}/api/menu", "method": "GET", "request_headers": HEADERS},
    },
    {
        "name": "create_order",
        "description": "Open the customer's order as soon as you know their name, phone number and at least one item. Call it only ONCE per call.",
        "api_schema": {
            "url": f"{BASE}/api/orders",
            "method": "POST",
            "request_headers": HEADERS,
            "request_body_schema": {
                "type": "object",
                "description": "New order",
                "properties": {
                    "customer_name": s("string", "Customer first name"),
                    "phone": s("string", "Customer phone number, digits only"),
                    "items": LINE_ITEMS,
                },
                "required": ["customer_name", "phone", "items"],
            },
        },
    },
    {
        "name": "update_order",
        "description": "Change the open order. Call it EVERY time the customer adds, removes or changes anything, with the complete new item list, or to save the delivery address.",
        "api_schema": {
            "url": f"{BASE}/api/orders/{{order_id}}",
            "method": "PATCH",
            "request_headers": HEADERS,
            "path_params_schema": ORDER_ID,
            "request_body_schema": {
                "type": "object",
                "description": "Fields to change",
                "properties": {
                    "items": LINE_ITEMS,
                    "delivery_address": s("string", "Full delivery address as the customer said it"),
                },
                "required": [],
            },
        },
    },
    {
        "name": "confirm_order",
        "description": "Confirm the order once the customer agreed to the recap and the delivery address is saved. Returns the estimated delivery time.",
        "api_schema": {
            "url": f"{BASE}/api/orders/{{order_id}}/confirm",
            "method": "POST",
            "request_headers": HEADERS,
            "path_params_schema": ORDER_ID,
            # ElevenLabs requires a body schema on POST; the API ignores it.
            "request_body_schema": {
                "type": "object",
                "description": "Confirmation",
                "properties": {"customer_agreed": s("boolean", "True once the customer accepted the recap")},
                "required": ["customer_agreed"],
            },
        },
    },
]


def upsert_tools() -> list[str]:
    existing = {t["tool_config"]["name"]: t["id"] for t in call("GET", "/tools").get("tools", [])}
    ids = []
    for tool in TOOLS:
        config = {"type": "webhook", "response_timeout_secs": 10, **tool}
        if tool["name"] in existing:
            call("PATCH", f"/tools/{existing[tool['name']]}", {"tool_config": config})
            ids.append(existing[tool["name"]])
        else:
            ids.append(call("POST", "/tools", {"tool_config": config})["id"])
    return ids


def forgetful(prompt: str) -> str:
    """Demo bug: Luigi never asks for the caller's name or phone number."""
    out = prompt.replace(
        "2. Get the caller's first name and phone number (read the number back digit by digit) and\n   their first item.",
        "2. Get the caller's first item.",
    ).replace(
        "The moment you have the name, the phone number and one item",
        "The moment you have one item (use the name and phone the caller gave, else \"Guest\" and \"0000000000\")",
    )
    assert out != prompt, "agent_prompt.md changed: update forgetful()"
    return out


def agent_body(name: str, tool_ids: list[str], *, interruptions: bool, prompt: str = PROMPT) -> dict:
    client_events = ["audio", "agent_response", "user_transcript", "agent_response_correction"]
    if interruptions:
        client_events.append("interruption")
    return {
        "name": name,
        "conversation_config": {
            "agent": {
                "first_message": FIRST_MESSAGE,
                "language": LANGUAGE,
                "disable_first_message_interruptions": not interruptions,
                "prompt": {
                    "prompt": prompt,
                    "llm": LLM,
                    "temperature": 0.3,
                    "tool_ids": tool_ids,
                    "built_in_tools": {
                        "language_detection": {
                            "type": "system",
                            "name": "language_detection",
                            "description": "Switch language as soon as the caller speaks another language.",
                            "params": {"system_tool_type": "language_detection"},
                        }
                    },
                },
            },
            "language_presets": {
                code: {
                    "overrides": {
                        "agent": {"first_message": greeting, "language": code},
                        "tts": {"model_id": "eleven_flash_v2_5"},
                    }
                }
                for code, greeting in EXTRA_LANGUAGES.items()
            },
            "tts": {"voice_id": VOICE_ID, "model_id": "eleven_flash_v2" if LANGUAGE == "en" else "eleven_flash_v2_5"},
            # Mini (an AI caller) takes a few seconds per reply: don't nag it with "are you still there?".
            "turn": {"turn_eagerness": "normal", "turn_timeout": 15},
            "conversation": {"max_duration_seconds": 600, "client_events": client_events},
        },
        "platform_settings": {"auth": {"enable_auth": False}},
    }


def upsert_agent(body: dict) -> str:
    agents = call("GET", "/agents?page_size=100").get("agents", [])
    match = next((a["agent_id"] for a in agents if a["name"] == body["name"]), None)
    if match:
        call("PATCH", f"/agents/{match}", body)
        return match
    return call("POST", "/agents/create", body)["agent_id"]


if __name__ == "__main__":
    tool_ids = upsert_tools()
    default = upsert_agent(agent_body("Luigi", tool_ids, interruptions=True))
    deaf = upsert_agent(agent_body("Luigi (line 2, no barge-in)", tool_ids, interruptions=False))
    print(f"ELEVENLABS_AGENT_ID={default}")
    absent = upsert_agent(
        agent_body("Luigi (line 3, never asks the phone)", tool_ids, interruptions=True, prompt=forgetful(PROMPT))
    )
    print(f"ELEVENLABS_AGENT_ID_DEAF={deaf}")
    print(f"ELEVENLABS_AGENT_ID_FORGETFUL={absent}")
