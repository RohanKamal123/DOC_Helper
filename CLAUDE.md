# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

BD Document Helper (সরকারি কাগজ সহায়তা) — a bilingual (Bengali/English) AI chat assistant that guides Bangladeshi citizens through government document processes (NID, birth certificate, passport, BRTA, land, TIN, police clearance, etc.). It's a single static HTML file with no backend, no build system, and no dependencies.

## Repository structure

```
index.html    ← the entire app: markup, CSS, and JS all in one file (~1270 lines)
vercel.json   ← Vercel static deployment config + security headers (CSP, X-Frame-Options, etc.)
readme.md     ← user-facing deployment/setup instructions
```

There is no `package.json`, no build tooling, and no test suite.

## Development workflow

- **Run locally**: just open `index.html` in a browser, or serve it with any static file server (e.g. `python3 -m http.server`). No build/compile step exists.
- **Deploy**: Vercel, using `vercel.json` (`@vercel/static` build of `index.html`). Auto-deploys on push if the repo is connected to a Vercel project.
- **No lint/test/build commands** — none are configured in this repo.
- When editing, keep everything inside `index.html`: there is intentionally no bundler, so don't introduce imports, npm packages, or a multi-file build unless explicitly asked to restructure the project.

## Architecture (all inside `index.html`)

The file has three parts in document order: `<style>` (CSS custom properties for theming, in `:root`), the HTML body (header, hero, services grid, chat UI), and a single `<script>` block containing all app logic. Key pieces of the script, top to bottom:

- **`PROVIDERS`** (~line 591): config for each supported LLM backend — Gemini, OpenAI, Claude/Anthropic, Mistral, Groq, OpenRouter, DeepSeek. Each entry declares its input `fields` (API key, model), a `call` function, and a `statusLabel`. Adding a new provider means adding an entry here plus a matching `callX(cfg, history, systemPrompt)` function.
- **State** (~line 691): plain top-level `let`/`const` variables — `currentLang`, `selectedServices`, `activeProvider`, `apiConfigs`, `chatHistory`. No framework/reactivity; UI updates happen via direct DOM manipulation (`innerHTML` rewrites) inside `render*()` functions.
- **`SERVICES`** (~line 698): the 12 government services shown as selectable chips (id, icon, English/Bengali labels, department).
- **`HINTS`** (~line 713): example prompts shown as tappable chips in the chat input.
- **`SYSTEM_PROMPT`** (~line 722): the instruction sent to whichever LLM is active. It defines the required bilingual response format using bracket section markers: `[FORM] [OFFICE] [DOCUMENTS] [FEE] [STEPS] [TIME] [ONLINE] [WARNING]`. `formatResponse()`/`extract()` (~line 1147/1216) parse those markers back out of the model's reply to render structured cards (fee badges, numbered steps, warning box, etc.) — so changes to the prompt's section markers must stay in sync with `extract()`'s regex and `formatResponse()`'s rendering.
- **`callGemini` / `callOpenAI` / `callAnthropic` / `callMistral` / `callGroq` / `callOpenRouter` / `callDeepSeek`** (~lines 1018-1144): one function per provider, each calling that provider's chat completion API directly from the browser via `fetch`, using the user-supplied API key.
- **`buildDemoResponse()`** (~line 1227): canned fallback answer (currently only handles NID queries) used when no API key is configured, per the "Demo Mode" feature described in the readme.

## Key conventions

- **No backend, no secrets in the repo.** API keys are entered by the end user in the browser and persisted only in `localStorage` (`bd_helper_api_configs`, `bd_helper_active_provider`). Never hardcode API keys, and don't add a server component to proxy them unless explicitly asked.
- **Bilingual by default.** Nearly all user-facing strings exist in both Bengali and English (e.g. `s.en`/`s.bn` on service objects, `.msg-bubble-bn` elements). New user-facing text should follow this pattern rather than being English-only.
- **CSP is strict** (`vercel.json`): `connect-src` is currently allow-listed only for `https://generativelanguage.googleapis.com` (Gemini). If you wire up calls to another provider's API from the deployed site, `vercel.json`'s CSP `connect-src` must be updated to include that provider's domain or requests will be blocked in production even though they work when opening the file locally.
- **HTML escaping**: user input and model output are inserted via `innerHTML`, so any new code path that injects text must go through `escHtml()` (~line 1222) to avoid XSS — see existing usage in `addMessage()`/`formatResponse()`.
