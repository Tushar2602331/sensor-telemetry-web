# Sensor Telemetry Dashboard

Live sensor dashboard with real auth and a real database — sign in, and
simulated temperature/humidity/distance readings are written to your own
Supabase Postgres database and charted in real time.

## 1. Push to GitHub

```bash
git init
git add .
git commit -m "sensor telemetry dashboard"
git remote add origin https://github.com/<your-username>/<repo-name>.git
git branch -M main
git push -u origin main
```

## 2. Set up Supabase

1. Go to [supabase.com](https://supabase.com) → **New Project** → set a name,
   database password, and region → wait ~1 minute for it to provision
2. Open **SQL Editor** → **New query** → paste the entire contents of
   `supabase-schema.sql` from this repo → **Run**
3. Go to **Authentication → Providers** and confirm **Email** is enabled
   (it is by default)
4. Go to **Settings → API** and copy:
   - **Project URL**
   - **anon public** key

## 3. Configure the app

Open `index.html`, find this block near the top of the `<script>` tag:

```js
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

Replace both with the values you copied. The anon key is safe to ship in
client-side code — it's a public key by design, and Row Level Security
(from the schema you just ran) is what actually restricts access.

Commit and push the change:
```bash
git add index.html
git commit -m "add supabase config"
git push
```

## 4. Deploy on Vercel

1. Go to [vercel.com](https://vercel.com) → sign in with GitHub
2. **Add New… → Project** → select this repo
3. Framework preset: **Other** (no build step needed)
4. Click **Deploy** — live in under a minute at `<project>.vercel.app`
5. Every future `git push` to `main` redeploys automatically

## 5. (Optional) Add your Vercel URL to Supabase

Authentication → URL Configuration → add
`https://<project>.vercel.app` as a **Redirect URL**, so email
confirmation links work correctly after deploy.

## How it works

- On load, if you're not signed in you see an email/password sign
  in/sign up screen (Supabase Auth)
- Once signed in, a background loop writes a new simulated reading for
  each sensor to the `readings` table every 3 seconds
- The dashboard queries that table directly: latest value per sensor,
  a time-windowed history for the charts, and MIN/MAX/AVG/COUNT for the
  stats table
- Row Level Security means each account only ever sees its own data,
  even though everyone shares the same database and table

## Swapping in a real sensor

Replace the `insertTick()` function's random-walk logic with data read
from a real Arduino (e.g. over `pyserial` on a small companion script
that calls the Supabase REST API), or point at any other data source —
nothing else in the app needs to change.
