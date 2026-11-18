# Oyuki Backend Integration Guide

This guide describes how a backend developer should connect the Django/API backend to the Oyuki buyer and vendor Flutter apps.

## 1. Current implementation status

The frontend is currently using a hybrid of local/demo data:

- **Buyer authentication** is implemented in memory in `oyuki_app/lib/user_session.dart` and `oyuki_app/lib/screens/auth_screens.dart`. It is not yet persistent or server-backed.
- **Buyer API support** already exists in `oyuki_app/lib/services/api_client.dart`. The default API prefix is `http://127.0.0.1:8000/api/v1`.
- **Vendor authentication and data** are stored locally using `shared_preferences` and the app documents directory in `oyuki_vendor/lib/state/app_state.dart`. The backend must replace these local operations.
- **Buyer products, stores, categories, cart, and tracking** currently use hard-coded UI data and assets.
- The API client supports bearer-token authentication, JSON requests, 20-second timeouts, and basic JSON error decoding.

## 2. Recommended backend stack

A REST backend should provide:

- Django REST Framework or Django Ninja
- PostgreSQL
- JWT or secure session authentication
- Django Channels or WebSockets for live order/tracking updates
- Object storage or Django media storage for images
- Celery/Redis for notifications and asynchronous work
- Django admin for moderation and operations

## 3. API configuration

Set the Flutter API base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Base URL rules:

- Android emulator: `http://10.0.2.2:8000/api/v1`
- iOS simulator: `http://127.0.0.1:8000/api/v1`
- Physical mobile device: `http://<computer-LAN-IP>:8000/api/v1`
- Production: `https://api.example.com/api/v1`

Do not expose secrets in `--dart-define`. Configuration values are visible in the compiled application.

For web development, configure Django CORS for the Flutter web origin and use HTTPS in production.

## 4. Authentication contract

### Buyer and vendor registration

`POST /auth/register/`

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "strong-password",
  "role": "buyer"
}
```

Suggested response:

```json
{
  "access": "jwt-access-token",
  "refresh": "jwt-refresh-token",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "buyer"
  }
}
```

For vendors, add a vendor/store creation step after registration.

### Login

`POST /auth/login/`

```json
{
  "identifier": "john@example.com",
  "password": "strong-password"
}
```

The backend must reject a vendor login on the buyer app or enforce role restrictions with `403` when needed.

### Refresh token

`POST /auth/refresh/`

```json
{
  "refresh": "jwt-refresh-token"
}
```

Response:

```json
{
  "access": "new-access-token",
  "refresh": "new-refresh-token"
}
```

### Password recovery

Recommended endpoints:

- `POST /auth/password/forgot/`
- `POST /auth/password/verify-otp/`
- `POST /auth/password/reset/`

Never return an OTP or password-reset token in API responses outside a verified development environment.

## 5. Required authorization headers

Protected requests must use:

```http
Authorization: Bearer <access-token>
Content-Type: application/json
```

The existing Flutter API client already adds this header when `authenticated` is enabled.

## 6. Core data resources

### Categories

`GET /categories/`

Return the categories used by the frontend:

- Dairy
- Meat
- Seafoods
- Spices
- Oils
- Flours & Grains
- Vegetables
- Roots and Tubers
- Fruits

Suggested category fields:

```json
{
  "id": "vegetables",
  "name": "Vegetables",
  "icon": "eco",
  "image": "https://.../vegetables.jpg",
  "sort_order": 7
}
```

### Stores

- `GET /stores/`
- `GET /stores/{store_id}/`
- `PATCH /vendors/me/store/`
- `POST /vendors/me/store/open/`

Store response:

```json
{
  "id": 10,
  "name": "James and Co. Farmhouse",
  "description": "Fresh farm produce",
  "address": "Lagos, Nigeria",
  "rating": 4.5,
  "open_minutes": 540,
  "close_minutes": 1440,
  "is_open": true,
  "image": "https://.../store.jpg"
}
```

### Products/menu items

- `GET /products/?category=vegetables&search=tomato&store=10`
- `GET /products/{product_id}/`
- `GET /vendors/me/menu/`
- `POST /vendors/me/menu/`
- `PATCH /vendors/me/menu/{item_id}/`
- `DELETE /vendors/me/menu/{item_id}/`

Product payload:

```json
{
  "id": 42,
  "name": "Fresh Tomatoes",
  "description": "Fresh locally grown tomatoes",
  "category": "Vegetables",
  "store_id": 10,
  "price": 4500,
  "prep_minutes": 30,
  "unit": "kg",
  "stock": 100,
  "images": ["https://.../tomatoes.jpg"]
}
```

Use integer prices representing the smallest currency unit or document that all prices are Nigerian naira. The frontend currently expects display strings such as `₦4,500`.

### Buyer profile and delivery details

- `GET /users/me/`
- `PATCH /users/me/`
- `GET /users/me/addresses/`
- `POST /users/me/addresses/`
- `PATCH /users/me/addresses/{address_id}/`
- `DELETE /users/me/addresses/{address_id}/`

Address payload:

```json
{
  "label": "Home",
  "recipient_name": "John Doe",
  "phone": "+234...",
  "address": "Olanrewaju Street, Allen, Ikeja, Lagos",
  "latitude": 6.6018,
  "longitude": 3.3515,
  "is_default": true
}
```

### Cart and checkout

- `GET /cart/`
- `POST /cart/items/`
- `PATCH /cart/items/{item_id}/`
- `DELETE /cart/items/{item_id}/`
- `POST /checkout/`

Checkout payload:

```json
{
  "address_id": 5,
  "payment_method": "wallet",
  "items": [
    {"product_id": 42, "quantity": 2}
  ]
}
```

The backend must perform:

- Server-side stock validation
- Server-side price calculation
- Delivery fee calculation
- Payment verification
- Order creation in a transaction
- Stock reservation or decrement
- Coupon/discount validation
- Idempotency protection

### Orders

Buyer endpoints:

- `GET /orders/`
- `GET /orders/{order_id}/`
- `POST /orders/{order_id}/cancel/`

Vendor endpoints:

- `GET /vendors/me/orders/`
- `POST /vendors/me/orders/{order_id}/accept/`
- `POST /vendors/me/orders/{order_id}/reject/`
- `POST /vendors/me/orders/{order_id}/complete/`

Order status values should match:

- `pending`
- `active`
- `rejected`
- `completed`
- `cancelled`

A status transition must be enforced by the backend. Vendor code in `oyuki_vendor/lib/state/app_state.dart` currently expects these statuses.

### Live tracking

Recommended WebSocket channel:

```text
ws://<host>/ws/orders/{order_id}/
```

Recommended events:

```json
{
  "event": "rider_location",
  "order_id": 1001,
  "latitude": 6.6051,
  "longitude": 3.3499,
  "estimated_arrival": "2026-11-18T15:45:00+01:00",
  "status": "active"
}
```

Status events should be broadcast to buyer and vendor only after authorization.

## 7. Payments and wallet

For Flutter and Django payment integration:

- Never put the payment gateway secret in Flutter.
- Create payments on the backend.
- Verify webhook signatures before changing wallet or order state.
- Use idempotency keys for checkout and webhook processing.
- Store provider payment references.
- Use database transactions for wallet debit/credit operations.
- Implement refund or reversal behavior for failed orders.

Wallet endpoints:

- `GET /wallet/`
- `POST /wallet/fund/`
- `POST /wallet/withdraw/`
- `GET /wallet/transactions/`

## 8. Notifications

Recommended notification endpoints:

- `GET /notifications/`
- `PATCH /notifications/{notification_id}/read/`
- `POST /notifications/read-all/`

Notification payload:

```json
{
  "id": 21,
  "kind": "order",
  "title": "New Order Received",
  "body": "Order #1001 is waiting for your response",
  "created_at": "2026-11-18T13:30:00Z",
  "read": false
}
```

Use Firebase Cloud Messaging or a similar service for app background notifications. Create an endpoint to register and remove device tokens.

## 9. Image uploads

Use `multipart/form-data` for image uploads:

- Store profile and menu images using media/object storage.
- Generate optimized thumbnails.
- Validate MIME type and file size.
- Reject executable and non-image files.
- Use signed URLs for private resources if needed.
- Return absolute or CDN image URLs.

The vendor app may send multiple menu photos. The backend should normalize them into a product image collection.

## 10. Error response format

The current Flutter API client reads `message` from an error JSON object. Every endpoint should follow this structure:

```json
{
  "message": "Not enough stock available.",
  "code": "insufficient_stock",
  "details": {
    "product_id": ["Stock is currently 0."]
  }
}
```

Use consistent HTTP status codes:

- `400` invalid input
- `401` missing or invalid authentication
- `403` insufficient permissions
- `404` resource not found
- `409` conflicting state or duplicate request
- `422` validation failure
- `429` rate limit exceeded
- `500` internal server error

Do not return stack traces or database details to clients.

## 11. Pagination and search

Use this response structure:

```json
{
  "count": 64,
  "next": "https://api.example.com/api/v1/products/?page=2",
  "previous": null,
  "results": []
}
```

Common query parameters:

- `page`
- `page_size`
- `search`
- `category`
- `store`
- `ordering`
- `latitude`
- `longitude`

Do not allow unbounded page sizes. Add database indexes for category, store, search, status, and created date fields.

## 12. Database recommendations

At minimum, create models for:

- User
- UserRole
- VendorStore
- Category
- Product
- ProductImage
- Address
- Cart
- CartItem
- Order
- OrderItem
- OrderStatusHistory
- Payment
- Wallet
- WalletTransaction
- Rider
- RiderLocation
- Notification
- DeviceToken
- Referral
- CardToken

Avoid storing raw card numbers or CVV values. Store only payment-provider card tokens.

## 13. Security requirements

- Use HTTPS only in production.
- Hash passwords using Django's configured password hasher.
- Enable CSRF protection for browser-based endpoints.
- Use short-lived access tokens and rotating refresh tokens.
- Enforce role permissions on every vendor and admin endpoint.
- Validate all IDs and ownership.
- Add request throttling and brute-force login protection.
- Configure CORS to explicit origins.
- Sanitize uploaded filenames and avoid serving uploads as executable types.
- Log security events without passwords or tokens.
- Mask payment and personal data in logs.
- Use environment variables for secrets.
- Run migrations automatically in deployment only after review and backup.

## 14. Flutter integration steps

### Buyer app

Replace demo authentication in:

- `oyuki_app/lib/screens/auth_screens.dart`
- `oyuki_app/lib/user_session.dart`

Recommended buyer API client calls:

- Register: `ApiClient.post('/auth/register/', body: ...)`
- Login: `ApiClient.post('/auth/login/', body: ...)`
- Load profile: `ApiClient.get('/users/me/', authenticated: true)`
- Load categories: `ApiClient.get('/categories/')`
- Search products: `ApiClient.get('/products/?search=...')`
- Load cart: `ApiClient.get('/cart/', authenticated: true)`
- Create checkout: `ApiClient.post('/checkout/', body: ..., authenticated: true)`

Call `UserSession.setTokens(...)` after login and refresh.

Do not keep production credentials in local static variables. Buyer app state will need secure local persistence for tokens.

### Vendor app

Replace local persistence and demo mutations in:

- `oyuki_vendor/lib/state/app_state.dart`
- `oyuki_vendor/lib/screens/login_screen.dart`
- `oyuki_vendor/lib/screens/item_form_screen.dart`
- `oyuki_vendor/lib/screens/order_detail_screen.dart`
- `oyuki_vendor/lib/screens/orders_screen.dart`
- `oyuki_vendor/lib/screens/store_profile_screen.dart`
- `oyuki_vendor/lib/screens/notifications_screen.dart`

Before changing the UI, retain the existing `AppState` public methods so screens continue working. Internally, each method should call the API, then update `ChangeNotifier` state only after confirmation.

For menu items and store profile images, upload files first or use multipart requests supported by the screen's selected image paths.

## 15. Backend development order

1. Create Django project and PostgreSQL database.
2. Implement user, role, and JWT authentication.
3. Implement categories and stores.
4. Implement products and menu CRUD.
5. Implement addresses and cart.
6. Implement transactional checkout and payments.
7. Implement orders and vendor status transitions.
8. Implement wallet and transaction ledger.
9. Implement notifications and live tracking.
10. Connect and test both Flutter apps.
11. Add tests, monitoring, backups, and deployment configuration.

## 16. Minimum test coverage

Backend tests should cover:

- Registration and login
- Role and ownership authorization
- Duplicate and expired OTP handling
- Category filtering and product search
- Cart price and stock consistency
- Checkout idempotency
- Payment verification and webhooks
- Order status transitions
- Wallet debit/credit consistency
- Store/menu authorization
- Address access control
- Notification read state
- Tracking data authorization
- Pagination and invalid input

## 17. Local development setup

Run the backend on a LAN-accessible address:

```bash
python manage.py runserver 0.0.0.0:8000
```

Example Django settings:

```python
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = [
    "http://localhost:51234",
]

ALLOWED_HOSTS = ["127.0.0.1", "localhost", "10.0.2.2", "<LAN-IP>"]
```

For physical devices, allow the computer firewall to permit port `8000` and run Flutter with the computer's LAN IP.

## 18. Production deployment

Before launch:

- Serve the API over HTTPS.
- Restrict CORS origins.
- Configure CDN and media storage.
- Configure email/SMS providers.
- Configure payment gateway webhooks.
- Configure a map/routing provider.
- Configure push notifications.
- Add health checks and structured logging.
- Set up database backups and migration rollbacks.
- Add rate limiting and monitoring.
- Use environment-specific API URLs in Flutter builds.

## 19. Acceptance criteria

The integration is complete when:

- A buyer can register, verify, and log in.
- A vendor can register and manage a store.
- Categories return real products from the database.
- Search and category filters work across both apps.
- Checkout creates real orders and deducts stock correctly.
- Vendors receive and can update orders.
- Buyers can view order status and tracking.
- Wallet balances and transactions are consistent.
- Images load through backend/CDN URLs.
- Unauthorized users cannot access protected resources.
- Refresh tokens and logout behave correctly.
