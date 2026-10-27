"""Pre-shoot smoke test: a real Luigi call over the ElevenLabs WebSocket, typed instead of spoken.

Tools run for real against the deployed API, so the stored order can be checked afterwards.

    ELEVENLABS_AGENT_ID=... uv run --with websockets python smoke_call.py
"""

from __future__ import annotations

import asyncio
import json
import os

import websockets

AGENT_ID = os.environ["ELEVENLABS_AGENT_ID"]
URL = f"wss://api.elevenlabs.io/v1/convai/conversation?agent_id={AGENT_ID}"
QUIET_SECONDS = float(os.environ.get("QUIET_SECONDS", "8"))

SCRIPT = [
    "Hi Luigi, Marco here, my number is 06 12 34 56 78. One Quattro Formaggi please.",
    "Actually I changed my mind, make it two Reginas without mushrooms instead.",
    "Can you also do a pineapple and chorizo pizza?",
    "No thanks. Deliver to 12 rue de la Paix, Paris.",
    "Yes, confirm it please.",
]


async def drain(ws) -> None:
    """Print agent events until no agent text or tool event arrived for QUIET_SECONDS.

    Audio chunks and pings keep flowing while the agent talks, so they don't count as activity.
    """
    loop = asyncio.get_running_loop()
    last_activity = loop.time()
    while loop.time() - last_activity < QUIET_SECONDS:
        try:
            raw = await asyncio.wait_for(ws.recv(), 1)
        except TimeoutError:
            continue
        event = json.loads(raw)
        if event.get("type") not in {"audio", "ping", "vad_score", "internal_tentative_agent_response"}:
            last_activity = loop.time()
        kind = event.get("type")
        if kind == "ping":
            await ws.send(json.dumps({"type": "pong", "event_id": event["ping_event"]["event_id"]}))
        elif kind == "agent_response":
            print(f"LUIGI: {event['agent_response_event']['agent_response']}")
        elif kind in {"agent_tool_response", "client_tool_call", "agent_tool_request"}:
            print(f"   [{kind}] {json.dumps(event)[:220]}")


async def main() -> None:
    if os.environ.get("BUG"):
        print(f"(bug switches: {os.environ['BUG']})")
    async with websockets.connect(URL, max_size=None) as ws:
        await ws.send(json.dumps({"type": "conversation_initiation_client_data"}))
        await drain(ws)
        for line in SCRIPT:
            print(f"YOU:   {line}")
            await ws.send(json.dumps({"type": "user_message", "text": line}))
            await drain(ws)


if __name__ == "__main__":
    asyncio.run(main())
