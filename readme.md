# 🇧🇩 BD Document Helper — সরকারি কাগজ সহায়তা

An AI-powered bilingual assistant that guides Bangladeshi citizens through government document processes — NID, passport, birth certificate, BRTA, education certificates, customs, and more.

---

## ✨ Features

- **12 Services** — NID, Birth Certificate, Passport, BRTA, SSC/HSC, Land, Trade License, TIN, Police Clearance, Export/Import/Customs
- **Bilingual** — Bengali + English UI and AI responses
- **AI-Powered** — Uses Claude API for accurate, personalized step-by-step guidance
- **Zero Tout** — Empowers citizens with exact fees, forms, offices, and document lists
- **Demo Mode** — Works without API key (with pre-built responses for common queries)

---

## 🚀 Deploy on Vercel — Step by Step

### Method 1: Vercel CLI (Fastest, ~2 minutes)

**Step 1: Install Vercel CLI**
```bash
npm install -g vercel
```

**Step 2: Login to Vercel**
```bash
vercel login
```
(Opens browser to authenticate with GitHub/Google/Email)

**Step 3: Deploy**
```bash
cd bd-doc-helper
vercel
```

Answer the prompts:
- `Set up and deploy?` → **Y**
- `Which scope?` → Select your account
- `Link to existing project?` → **N**
- `Project name` → `bd-document-helper` (or any name)
- `In which directory is your code?` → **./** (current)
- `Want to override settings?` → **N**

**Step 4: Done!**
Vercel gives you a live URL like: `https://bd-document-helper.vercel.app`

To deploy to production:
```bash
vercel --prod
```

---

### Method 2: GitHub + Vercel Dashboard (Recommended for Teams)

**Step 1: Push to GitHub**
```bash
git init
git add .
git commit -m "Initial commit — BD Document Helper"
git remote add origin https://github.com/YOUR_USERNAME/bd-doc-helper.git
git push -u origin main
```

**Step 2: Connect to Vercel**
1. Go to [vercel.com](https://vercel.com) → Sign in
2. Click **"Add New Project"**
3. Click **"Import Git Repository"**
4. Select your `bd-doc-helper` repo
5. Click **"Deploy"** (no build settings needed — it's static HTML)

**Step 3: Your site is live!**
You get:
- `https://bd-doc-helper.vercel.app` — preview URL
- Auto-deploys on every `git push`

---

### Method 3: Vercel Dashboard Drag & Drop

1. Go to [vercel.com/new](https://vercel.com/new)
2. Drag and drop the `bd-doc-helper` folder onto the page
3. Click **Deploy**
4. Done in ~30 seconds ✅

---

## 🔑 Setting Up the Gemini API Key

The app uses **Gemini 2.0 Flash** — Google's fast, capable model. The API is **free** for moderate usage.

**Get your free API key:**
1. Go to [aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key (starts with `AIza...`)

**Use in the app:**
- Open the deployed app
- Paste your Gemini API key in the banner at the top
- Click **"Save Key & Activate"**
- The key is stored only in your browser's localStorage

**Free tier limits (as of 2024):**
- 15 requests/minute
- 1 million tokens/day
- No credit card required

---

## 📁 Project Structure

```
bd-doc-helper/
├── index.html      ← Complete app (single file, no build needed)
├── vercel.json     ← Vercel deployment config + security headers
└── README.md       ← This file
```

---

## 🛠 Customization

### Add a new service
In `index.html`, find the `SERVICES` array and add:
```js
{ id:'newservice', icon:'📄', en:'Service Name', bn:'সেবার নাম', dept:'Ministry Name' }
```

### Add hint chips
Find the `HINTS` array and add Bengali/English prompts users can tap.

### Change AI behavior
Find `SYSTEM_PROMPT` and edit the instructions to change how the AI responds.

### Change the model
Find `gemini-2.0-flash` in the fetch URL and replace with:
- `gemini-2.0-flash` — fast, free tier (default)
- `gemini-1.5-pro` — most capable, larger context
- `gemini-1.5-flash` — budget option

---

## 🌐 Custom Domain (Optional)

After deploying on Vercel:
1. Go to your project → **Settings** → **Domains**
2. Add your domain e.g. `kagojsahajata.com.bd`
3. Update DNS records as shown by Vercel
4. Free SSL included automatically

---

## 📋 Government Services Covered

| Service | Office | Online Portal |
|---------|--------|---------------|
| NID | EC NID Wing | nidw.gov.bd |
| Birth Certificate | Local Govt | bdris.gov.bd |
| Passport | Dept of Immigration | dip.gov.bd |
| Driving License | BRTA | brta.gov.bd |
| SSC/HSC Certificate | Education Board | educationboardresults.gov.bd |
| Land/Deed | Sub-Registrar | land.gov.bd |
| Trade License | City Corp | citycorporation.gov.bd |
| TIN / Income Tax | NBR | nbr.gov.bd |
| Police Clearance | Bangladesh Police | police.gov.bd |
| Export/Import | NBR Customs | customs.gov.bd |

---

## ⚠️ Disclaimer

This tool provides general guidance based on publicly available information. Always verify current requirements with the respective government office. Government fees and processes may change. The app is not affiliated with any government body.

---

Built with ❤️ for the people of Bangladesh · Powered by Claude AI