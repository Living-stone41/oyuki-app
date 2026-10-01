# Oyuki Backend — Handoff Guide

## Base URL
Local dev: `http://127.0.0.1:8000/api/v1/`
Interactive docs: `http://127.0.0.1:8000/api/docs/`
Raw OpenAPI schema: `docs/openapi-schema.yaml`
Postman collection: `docs/Oyuki-API.postman_collection.json`

## Auth flow
1. `POST /accounts/register/` — creates a PENDING user, sends an OTP to their email (console backend in dev; real SMTP not yet configured).
2. `POST /accounts/verify-otp/` — activates the account, returns `access` + `refresh` tokens.
3. `POST /accounts/login/` — returns the same token pair for an already-active account.
4. Every protected request needs: `Authorization: Bearer <access_token>`.
5. Access tokens expire after 15 minutes; use `refresh` against SimpleJWT's standard `/api/token/refresh/` pattern — **note:** a dedicated refresh endpoint hasn't been wired into `urls.py` yet; this is a known gap, see "Known gaps" below.
6. `POST /accounts/logout/` — blacklists the refresh token server-side. Call this on logout in the app, not just a local token wipe.

## Response envelope
Every response (success or error) is JSON-wrapped the same way, regardless of endpoint:
```json
{ "status": "success", "message": "...", "data": { } }
```
or on failure:
```json
{ "status": "error", "message": "...", "data": null }
```
Validation errors from DRF serializers appear inside `data` with field names as keys.

## Pagination
Any list endpoint accepts `?page=` and `?page_size=` (max 100). Paginated responses nest results as:
```json
{ "status": "success", "message": "...", "data": { "count": 1, "next": null, "previous": null, "results": [ ] } }
```

## Role → endpoint access matrix

| Endpoint group | CUSTOMER | SELLER | ADMIN | ACCOUNT_OFFICER | LOGISTICS_ADMIN | RIDER |
|---|---|---|---|---|---|---|
| Auth (register/login/OTP/reset) | Public | Public | Public | Public | Public | Public |
| `/marketplace/products/`, `/categories/`, `/states/`, `/lgas/`, `/markets/` (read) | Public | Public | Public | Public | Public | Public |
| `/marketplace/my-products/*` | — | Own only | — | — | — | — |
| `/marketplace/wishlist/*` | Own only | — | — | — | — | — |
| `/cart/*` | Own only | Own only | — | — | — | — |
| `/orders/checkout/`, `/orders/my-orders/*` | Own only | — | — | — | — | — |
| `/orders/seller-orders/*` | — | Own only | — | — | — | — |
| `/orders/admin-orders/*`, `/assign-rider/` | — | — | Yes | — | Yes | — |
| `/orders/rider-orders/*` | — | — | — | — | — | Own only |
| `/payments/initiate/`, `/my-payments/`, `/upload-proof/` | Own only | — | — | — | — | — |
| `/payments/admin-payments/*`, `/review/` | — | — | Yes | Yes | — | — |
| `/notifications/*`, `/devices/*` | Own only | Own only | Own only | Own only | Own only | Own only |
| `/accounts/admin-ping/` | — | — | Yes | — | — | — |

**MARKET_AGENT, MARKET_SUPERVISOR, and MARKETER** exist as valid roles (auth and registration accept them, and `accounts/permissions.py` already has `IsMarketAgent`, `IsMarketSupervisor`, `IsMarketer` ready to use) but **no dedicated endpoints exist for them yet** — this was out of scope for the phases built so far. Flag this explicitly to whoever picks this up next.

## Known gaps (be upfront about these)
- No dedicated JWT refresh endpoint wired into `urls.py` yet (SimpleJWT supports it; just needs a `path()` added).
- Real email delivery not configured — OTPs print to the server console (`EMAIL_BACKEND` in settings).
- Real push notifications not configured — `notifications/services.py`'s `send_push()` logs instead of calling Firebase; needs a Firebase project + service account key.
- No endpoints yet for MARKET_AGENT / MARKET_SUPERVISOR / MARKETER roles.
- Delivery fee is hardcoded to 0 in checkout — no real delivery pricing logic yet.
- Local dev database is SQLite; production will run against the migrated original MySQL database (Phase 15, not yet done).

## Running the project
```bash
python manage.py migrate
python manage.py runserver
python manage.py test   # full suite, 62 tests
```