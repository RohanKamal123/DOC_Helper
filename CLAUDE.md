# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

BD Document Helper (সরকারি কাগজ সহায়তা) — a bilingual (Bengali/English) agentic assistant that guides Bangladeshi citizens through government document processes (NID, birth certificate, passport, BRTA, land, TIN, police clearance, etc.). It is **not** a plain LLM chatbot: the agent calls tools backed by a verified, human-curated Postgres database (offices, fees, documents, steps, forms, sources) instead of answering from the model's memorized/assumed knowledge, plus a live web-search tool for freshness. Everything is scoped to government document processes — no legal-advice framing.

## Repository structure

```
index.html    ← frontend: markup, CSS, and client JS in one file (chat UI, calls /api/chat)
api/          ← Vercel serverless functions (chat.js = agent endpoint, services.js = service list)
lib/          ← backend logic: db.js (Supabase), agent.js (tool-calling loop), deepseek.js,
                tavily.js, systemPrompt.js, tools/ (one file per agent tool)
db/           ← schema.sql + seed/*.sql (one seed file per service) + README.md (setup steps)
vercel.json   ← Vercel deployment config + security headers (CSP, X-Frame-Options, etc.)
package.json  ← runtime dep: @supabase/supabase-js only; no bundler/build step
readme.md     ← user-facing deployment/setup instructions (predates this architecture; needs a refresh)
```

## Development workflow

- **Run locally**: `npm install`, then `vercel dev` (needs `.env.local` — see `.env.example` and `db/README.md`). Opening `index.html` directly no longer works standalone since it now calls `/api/chat`.
- **Database**: Supabase Postgres (free tier). Run `db/schema.sql` once, then everything in `db/seed/` — see `db/README.md` for the exact steps and for how to read the confidence notes on seeded data.
- **Deploy**: Vercel, zero-config (`api/*.js` auto-detected as serverless functions alongside the static `index.html`). Requires `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `TAVILY_API_KEY` set as Vercel project env vars.
- **No lint/test/build commands** — none are configured in this repo. There's no test suite; when changing `lib/agent.js` or the tools, sanity-check the tool-calling loop against a fake `fetch` stub (mock DeepSeek/Supabase/Tavily responses) before trusting it against real credentials — the loop logic is easy to get subtly wrong (message accumulation, `tool_call_id` round-tripping, the per-turn `web_search` cap).

## Architecture

**Frontend (`index.html`)**: single `<script>` block — `SERVICES`/`HINTS` (static picker data), API-key panel (single DeepSeek key, saved to `localStorage` under `bd_helper_deepseek_key`, sent per-request, never stored server-side), `sendMessage()` (POSTs to `/api/chat`), and `renderServiceCard()` which builds the reply UI **directly from the backend's typed JSON** (`offices`, `fees`, `documents`, `steps`, `forms`, `online_portals`, `sources`, `search_results`) — there is no bracket-marker prose parsing anymore. `escHtml()` escapes `&<>"'`; `safeUrl()` restricts any URL placed in an `href` to `http(s)` before interpolation — required because `search_results[].url` comes from live Tavily results and is genuinely untrusted, unlike the curated DB rows.

**Backend agent loop (`lib/agent.js`, called from `api/chat.js`)**: standard OpenAI-compatible tool-calling loop against DeepSeek's `/chat/completions` (`lib/deepseek.js`). Capped at 4 tool-calling rounds (falls back to one non-tool completion if exceeded, so the user always gets a reply) and at most one `web_search` call per turn (protects the shared Tavily free-tier quota even if the model requests it twice). `api/chat.js` builds the response from the **raw tool results**, not the model's restatement of them — `answer_text` is the only model-generated field; `offices`/`fees`/`documents`/`steps`/`forms`/`sources` are copied straight from `lib/db.js` query results.

**Tools (`lib/tools/`)**: `list_services`, `get_service_info(service_id)`, `find_nearest_office(service_id, district, upazila?)`, `web_search(query)`. Each file exports `{ schema, handler }`; registered in `lib/tools/index.js`. Adding a tool means adding a file here and one line in the registry — `lib/agent.js` doesn't need to change.

**`lib/systemPrompt.js`**: instructs the model to always call `get_service_info` before stating any fact, to ask the user for their district when the answer depends on location and isn't fully online, to present **both** an online and an in-person path with fee/timing when a service has both (don't silently pick one), and to say "not confirmed" rather than fill a gap with a plausible-sounding guess.

**Database (`db/schema.sql`)**: `services`, `offices` (district/upazila-scoped for `find_nearest_office`), `fees`, `required_documents`, `steps`, `forms`, `online_portals`, all pointing at a `sources` row (`url` + `last_verified_date` + `notes`). Read a seed file's `sources` `notes` column before trusting a figure — several `.gov.bd` fee pages render dynamically or blocked automated fetches during research, so some numbers are cross-referenced from secondary sources rather than confirmed directly, and that's recorded per-row rather than silently smoothed over.

## Key conventions

- **Never state a fact the agent didn't get from a tool result.** This is the whole point of the rebuild (the previous version let the model free-type fees/offices from memory). If you add a new tool or change `systemPrompt.js`, preserve this invariant.
- **DeepSeek key stays user-supplied, per-request, never persisted server-side** — same trust model as the old multi-provider version, just proxied through `/api/chat` now instead of called directly from the browser. Don't add a path that stores it server-side.
- **CSP is `connect-src 'self'`** (`vercel.json`) — the browser only ever talks to same-origin `/api/*` routes. If you add a new external API call, it belongs in `lib/`, called server-side, not from `index.html`.
- **Bilingual by default.** Nearly all user-facing strings exist in both Bengali and English (`name_en`/`name_bn`, `notes_en`/`notes_bn` columns; `.msg-bubble-bn` elements). New user-facing text should follow this pattern.
- **HTML escaping**: any new code path injecting text via `innerHTML` must use `escHtml()`; anything going into an `href` must additionally go through `safeUrl()`.
- **Seed data honesty**: when adding/editing a `db/seed/*.sql` file, cite a real source URL and `last_verified_date` per fact-bearing row, and if a figure isn't independently confirmed, say so in `notes` rather than presenting it as certain — see existing seed files for the pattern.
