# Kitchen Crew — Mock Server (Dart + shelf)

Minimal, **in-memory** mock API for the Kitchen Crew Flutter app. No database; all state
lives in `Map`s seeded at boot (`lib/store.dart`) and resets on restart. The mock lives
here in the server so the Flutter app talks to real HTTP endpoints and stays unaware it
is mocked. To move to a real backend later, the app swaps its data-source implementation
— this server can be discarded.

It shares DTOs with the app via the `contracts` package (`../packages/contracts`), so the
JSON the server emits and the JSON the app parses can never drift apart.

## Run

```bash
dart pub get
dart run bin/server.dart
# auto-restart on change (optional): dart run --enable-vm-service or use `dart_frog`/watcher;
# simplest: re-run after edits.
```

Listens on `http://localhost:3000` (override with `PORT`, e.g. `PORT=4000 dart run bin/server.dart`).

- Android emulator reaches the host at `http://10.0.2.2:3000`.
- iOS simulator / macOS / web use `http://localhost:3000`.

## Auth

Fake JWT (base64 `header.payload.sig`, not cryptographically signed — for local dev only).
Send `Authorization: Bearer <token>` on protected routes. Get a token from
`POST /auth/login` or `POST /auth/register`.

## Endpoints

```
GET  /health

POST /auth/register            { name, email, phone, password }
POST /auth/login               { email, password }   (any seeded user; password ignored)
POST /auth/otp/request         { phone }              -> { otp }  (returned for dev)
POST /auth/otp/verify          { phone, otp }
POST /auth/forgot-password     { email }              -> { resetCode }  (returned for dev)
POST /auth/reset-password      { email, resetCode, newPassword }
POST /push/register-token      (auth) { token, platform }   -> store device token (targeting)
GET  /auth/me                  (auth)

GET  /home                     banners + featured stores
GET  /categories
GET  /products                 ?categoryId= &veg= &q=
GET  /products/:id
GET  /products/:id/addons

GET  /cart                     (auth)
POST /cart/items               (auth) { productId, qty, selectedAddons:[optionId], notes }
PATCH/cart/items/:lineId       (auth) { qty }
DELETE /cart/items/:lineId     (auth)
POST /cart/coupon              (auth) { code }
DELETE /cart/coupon            (auth)

GET  /addresses                (auth)
POST /addresses                (auth) { title, address, phone, coordinates, isDefault }
PATCH/addresses/:id            (auth)
DELETE /addresses/:id          (auth)
POST /delivery/check-zone      { latitude, longitude } -> { serviceable, zone }

POST /orders                   (auth) { addressId, deliveryTime, paymentMethod, ... }
GET  /orders                   (auth)
GET  /orders/:id               (auth)
POST /orders/:id/cancel        (auth) { reason }   -> full-order cancel
POST /orders/:id/help          (auth) { topic, message }   -> "Contact the Crew" ticket
POST /orders/:id/advance       (auth)   -> dev: move status to next stage
POST /orders/:id/feedback      (auth) { rating, comment }   -> post-delivery rating

GET  /crisps
GET  /crisps/:id

GET  /notifications            (auth)
POST /notifications/:id/read   (auth)
POST /notifications/test-push  (auth) { type } -> simulate a push payload
```
