# Luigi's Pizzeria: voice-agent demo target

A web phone line (ElevenLabs voice agent) plus the order API it writes to. Mini calls Luigi
with `web-audio converse` and checks the API to catch the bug you can't hear: Luigi *says*
the right order but *stores* a different one.

```
Mini (browser, virtual mic) ──voice──▶ Luigi (ElevenLabs agent) ──webhook tools──▶ Order API
          └──────────────── backend-curl (OpenAPI + X-API-Key) ─────────────────────▶ Order API
```

## Pieces

| Path | What |
|---|---|
| `app/main.py` | FastAPI order API (`/api/*`, OpenAPI at `/openapi.json`) and the web page at `/` |
| `app/static/` | The phone-line page (ElevenLabs JS SDK over WebRTC) |
| `agent_prompt.md` | Luigi's system prompt |
| `provision_elevenlabs.py` | Creates/updates the webhook tools and both agents |

## Demo switches

| Switch | How | Effect |
|---|---|---|
| Stale items | `PUT /admin/bugs {"stale_items": true}` (hidden from OpenAPI) | `update_order` keeps the old items in storage but answers with the new ones, so Luigi's spoken recap and total stay right while the stored order is wrong. |
| Dropped removals | `PUT /admin/bugs {"drop_removals": true}` | Removed ingredients are dropped in storage (Regina *without* mushrooms is stored with them). Fires on every order: the safest bug for a shoot. |
| Never asks the phone | open `/?line=forgetful` | Same Luigi, but he never asks for the caller's name or phone number. |
| No barge-in | open `/?line=deaf` | Same Luigi, with interruptions disabled: he keeps talking when cut off. |

```bash
curl -X PUT "$URL/admin/bugs" -H "X-API-Key: $LUIGI_API_KEY" -H 'content-type: application/json' -d '{"stale_items": true}'
```

Switches are runtime state: `PUT /admin/bugs {}` turns everything off. A redeploy also resets them (and every order).

**Deployed**: `https://luigi-qebldsvdha-ew.a.run.app` (Cloud Run `luigi`, project `minitap-dev`, europe-west1).
Secrets for scripts live in the umbrella's `local/luigi.env` and `local/elevenlabs.env`.

## Pre-shoot check

`smoke_call.py` runs a real call over the ElevenLabs WebSocket with typed lines; tools hit the
deployed API, so you can read the stored order afterwards.

```bash
set -a; . local/luigi.env; set +a
uv run --with websockets python -u smoke_call.py
curl -s -H "X-API-Key: $LUIGI_API_KEY" "$LUIGI_PUBLIC_URL/api/customers/0612345678/orders"
```

## Run locally

```bash
uv run --group dev pytest -q
LUIGI_API_KEY=dev-luigi-key ELEVENLABS_AGENT_ID=agent_xxx uv run uvicorn app.main:app --port 8080
```

Orders live in memory. Cloud Run runs exactly one instance (`--min-instances 1 --max-instances 1`).

## Deploy (Cloud Run)

```bash
docker buildx build --platform linux/amd64 -t europe-west1-docker.pkg.dev/minitap-dev/demo-apps/luigi:vN --push .
gcloud run deploy luigi --project minitap-dev --image europe-west1-docker.pkg.dev/minitap-dev/demo-apps/luigi:vN --region europe-west1 --allow-unauthenticated \
  --min-instances 1 --max-instances 1 \
  --set-env-vars LUIGI_API_KEY=...,LUIGI_PUBLIC_URL=https://...,ELEVENLABS_AGENT_ID=...,ELEVENLABS_AGENT_ID_DEAF=...
ELEVENLABS_API_KEY=... LUIGI_PUBLIC_URL=https://... LUIGI_API_KEY=... uv run python provision_elevenlabs.py
```

## Minitap setup (web app)

1. Vault secret `LUIGI_API_KEY` (kind `token`) on the app.
2. App settings → Backend API: base URL = service URL, OpenAPI URL = `<service URL>/openapi.json`,
   authentication secret = `LUIGI_API_KEY`.
3. Flags on the tenant: `backend-api`, `secrets-vault-ui`, `secrets-references`.

## Scenarios

The phone number is the key Mini uses to find its order in the API
(`GET /api/customers/{phone}/orders`), so each scenario uses its own number.

Write each scenario as a situation, not a dialogue: who the caller is (context it may draw
on), what it wants, and how its mind changes. Never script lines or the order in which the
caller gives its details: the caller talks like a real customer, gives a detail only when
Luigi asks for it, and never fills a step Luigi skips. That is what lets a criterion such as
"Luigi asks for the phone number" fail when Luigi forgets.

### 1. The indecisive football fan

**Who**: Marco, a football fan, a bit in a hurry and indecisive. Phone 06 12 34 56 78,
delivery address 12 rue de la Paix, Paris.

**What happens**: he calls for tonight's match wanting one Quattro Formaggi, then changes his
mind for two Reginas without mushrooms. He is curious whether they make a pineapple and chorizo
pizza but won't take an alternative. He wants the order confirmed and delivered.

**Setup**: before calling, delete every order of 0612345678 through the API.

**Acceptance criteria**
1. Luigi asks for Marco's phone number before confirming the order.
2. Luigi refuses the pineapple and chorizo pizza and suggests something from the menu.
3. Luigi's spoken recap is exactly two Reginas without mushrooms, and the spoken total is 24 €.
4. The API shows exactly one order for 0612345678, containing only 2 × Regina without
   mushrooms, with no Quattro Formaggi and no pineapple item.
5. The order stored in the API has a total of 24 €, matching what Luigi said.
6. The order stored in the API has the delivery address 12 rue de la Paix, Paris, and status
   `confirmed`.

With `stale_items` on, criteria 4 and 5 fail: the API still holds the Quattro Formaggi next to
the Reginas (37 € or more). With `drop_removals` on, only criterion 4 fails: the stored Reginas
have their mushrooms back. Everything else passes, because Luigi *says* the right order.

### 2. Cut him off (barge-in)

**Goal**: Check that Luigi stops talking when the caller interrupts him.

**Who**: Giulia, phone 06 98 76 54 32, impatient.

**What happens**: she asks Luigi what pizzas they have, loses patience while he lists them,
and cuts him off to order one Margherita. Needs `converse --barge-in` (not shipped yet).

**Acceptance criteria**
1. When Giulia interrupts, Luigi stops talking within about a second.
2. Luigi's next answer is about the Margherita, not the rest of the menu.
3. The API shows one order for 0698765432 with exactly 1 × Margherita.

Open `/?line=deaf` to make criteria 1 and 2 fail.

### 3. Nonna from Napoli (language switch)

Run Mini with `converse start --language it` (or `zh` for Mandarin).

**Who**: Nonna Rosa, warm, chatty and a little slow; speaks only Italian. Phone 06 11 22 33 44,
delivery address Via Toledo 15, Napoli.

**What happens**: she wants one Margherita and one Tiramisu delivered and confirmed, and never
switches to English, even if Luigi does.

**Acceptance criteria**
1. After Rosa's first sentence, Luigi answers in Italian for the rest of the call.
2. Luigi's spoken total is 16 €.
3. The API shows one confirmed order for 0611223344 with 1 × Margherita and 1 × Tiramisu,
   total 16 €, delivered to Via Toledo 15.
