# Deploying the Kitchen Crew mock server to Render (Docker)

The server is a Dart `shelf` app with **all state in memory**. It containerizes and
deploys trivially. This doc is the full runbook.

> ⚠️ **State is ephemeral.** Everything (registered users, carts, orders, addresses)
> lives in RAM and is re-seeded on every boot. Any restart — including Render's free-tier
> spin-down after ~15 min idle — wipes runtime data back to the seed. That's fine for a
> demo/mock; it is *not* a persistent backend.

---

## Why this works out of the box

The server already does everything a container platform needs — no code changes required:

| Requirement                        | Where it's handled                                              |
| ---------------------------------- | -------------------------------------------------------------- |
| Read the injected `PORT`           | `bin/server.dart`: `int.tryParse(Platform.environment['PORT'])`|
| Bind all interfaces (not loopback) | `io.serve(handler, InternetAddress.anyIPv4, port)` → `0.0.0.0` |
| Health check endpoint              | `GET /health` → `{"ok": true, ...}`                            |
| CORS for the web app               | `_cors()` middleware, `Access-Control-Allow-Origin: *`         |

## The one gotcha: build context

The server has a **path dependency** on `packages/contracts` (`../packages/contracts`).
So the Docker **build context must be the repo root**, not `server/` — both directories
have to be visible to the build. The files are set up for exactly this:

```
pranit/
  Dockerfile          <- builds the server; context = repo root
  .dockerignore       <- trims the context to server/ + packages/contracts/
  render.yaml         <- Render Blueprint (optional one-click path)
  server/  packages/contracts/
```

---

## Deploy — Option A: Blueprint (recommended, one click)

The repo ships a `render.yaml`. Render reads it and provisions the service for you.

1. Push these files (`Dockerfile`, `.dockerignore`, `render.yaml`) to GitHub.
2. In Render: **New +** → **Blueprint** → select this repo → **Apply**.
3. Render builds the Docker image and deploys. First build ~3–5 min (SDK pull + AOT compile).
4. When live you get a URL like `https://kitchen-crew-server.onrender.com`. Confirm:
   ```bash
   curl https://kitchen-crew-server.onrender.com/health
   # {"ok":true,"service":"kitchen-crew-mock","ts":...}
   ```

## Deploy — Option B: Manual web service (no Blueprint)

1. Render: **New +** → **Web Service** → connect the repo.
2. Set:
   - **Runtime / Language:** `Docker`
   - **Dockerfile Path:** `./Dockerfile`
   - **Docker Build Context Directory:** `.`  ← must be repo root (the contracts gotcha)
   - **Health Check Path:** `/health`
   - **Instance Type:** `Free` (or paid to avoid idle spin-down)
3. Leave `PORT` alone — Render injects it and the server reads it. **Create Web Service.**

> Don't hardcode a `PORT` env var. Render sets it (typically `10000`); the server honors it.

---

## Point the Flutter app at the deployed server

`AppConfig` already supports an override — no code change:

```bash
# Web build against the deployed server
flutter build web --dart-define=API_BASE_URL=https://kitchen-crew-server.onrender.com

# Or run locally against it
flutter run -d macos --dart-define=API_BASE_URL=https://kitchen-crew-server.onrender.com
```

Without the flag the app falls back to `http://localhost:4000` for local dev.

---

## Build & run the image locally (optional sanity check)

Run from the **repo root** (context matters):

```bash
docker build -t kitchen-crew-server .
docker run --rm -e PORT=8080 -p 8080:8080 kitchen-crew-server
curl http://localhost:8080/health
```

## How the image is built

Multi-stage (`Dockerfile`):

1. **build stage** (`dart:stable`) — copy pubspecs (cached layer), `dart pub get`, then
   `dart compile exe bin/server.dart` → a self-contained native executable.
2. **runtime stage** (`scratch`) — copy only `/runtime/` (minimal Dart shared libs, shipped
   by the official image) + the binary. **Final image ≈ 16 MB**, near-instant cold start.

Verified locally via full `docker build` + `docker run`: image builds, container honors
`PORT`, and returns `200` on `/health` (and serves `/home`). The heavy `dart:stable` SDK
(~1.2 GB) from the build stage is discarded — none of it ships.

---

## Operational notes

- **Cold starts (free tier):** after idle spin-down the first request waits ~30–60 s while
  the container wakes. Upgrade the instance type to keep it warm.
- **Data resets** on every deploy/restart/spin-down (see the warning up top). The seeded
  demo user always returns via `seedDemoUser()`.
- **Auth is a fake base64 JWT** — no real crypto. Fine for a demo; never treat as secure.
- **Logs:** the `logRequests()` middleware prints every request to stdout → visible in
  Render's **Logs** tab.
- **Auto-deploy:** `render.yaml` sets `autoDeploy: true`, so pushes to the tracked branch
  redeploy automatically. Flip to `false` to deploy manually.
