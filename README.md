# Kitchen Crew — Deployable Mock Server

Standalone, Docker-deployable copy of the Kitchen Crew mock API (Dart + `shelf`),
extracted from the app monorepo for hosting on [Render](https://render.com).

Contains exactly what the image needs to build:

```
Dockerfile          2-stage build (dart:stable → AOT exe → scratch, ~16 MB)
.dockerignore
render.yaml         Render Blueprint (one-click deploy)
server/             the shelf mock API (in-memory, resets on restart)
packages/contracts/ shared DTOs — server depends on this via a path dependency
```

The build context is the repo root because `server/` imports `packages/contracts`
(`../packages/contracts`); both must be present for `dart pub get` to resolve.

## Deploy

**Full runbook:** [`server/DEPLOYMENT.md`](server/DEPLOYMENT.md).

Quick version — Render → **New +** → **Blueprint** → pick this repo → **Apply**.
Then verify:

```bash
curl https://<your-service>.onrender.com/health
```

## Build & run locally

```bash
docker build -t kitchen-crew-server .
docker run --rm -e PORT=8080 -p 8080:8080 kitchen-crew-server
curl http://localhost:8080/health
```

> ⚠️ State is **in-memory** — every restart (incl. Render free-tier idle spin-down)
> resets all data to the seed. This is a demo/mock backend, not a persistent one.
