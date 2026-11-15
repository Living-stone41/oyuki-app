# Oyuki Vendor (Flutter)

Vendor app for Oyuki: manage incoming orders, your menu, store profile and sales analytics.
Built from the 16 design screens (Home, Orders + filter, Order detail, Menu + search / empty state / actions,
Add/Edit item, Analytics, Settings, Store profile, Notifications, Log-out dialog).

## Run it

Requires Flutter 3.22+ (Dart 3.4+).

```bash
cd oyuki_vendor
./setup.sh          # flutter create (android + ios folders) + flutter pub get
flutter run
```

`flutter create .` keeps the existing `lib/`, `pubspec.yaml`, `assets/` and `test/`.

### iOS only
Add to `ios/Runner/Info.plist` inside the top-level `<dict>` (needed for the photo picker):

```xml
<key>NSCameraUsageDescription</key>
<string>Take photos of your products and store.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose photos of your products and store.</string>
```

Android needs no extra permissions.

## What works

| Area | Behaviour |
|---|---|
| Sign in / log out | Email + password form (validated), session persisted, log-out confirmation dialog |
| Home | Time-based greeting, total sales, order counts, today's sales, live list of active orders, notification bell with unread dot |
| Orders | Grouped by Today / Yesterday / date. Filter (Active / Pending / Completed, tap again to clear). Pending: Accept / Reject (with confirmation). Active: Mark as completed. Tap a card for details |
| Order detail | Customer, address, phone (tap to copy), items, total, same actions |
| Menu | List, search, add (FAB), update / delete (⋯ menu, delete confirmed), empty state |
| Add/Edit item | Up to 5 photos (camera or gallery), name, category, description, prep time, price; validation |
| Analytics | Revenue + % change vs previous period, 7 / 30 day bar chart (tap a bar), top-selling products from real orders |
| Settings | Store status toggle (open/closed), Store profile (photo, hours picker, etc.), Analytics, Support (call / email / WhatsApp / FAQ), Log out |
| Notifications | Created when orders arrive or change status; tap to mark read |

## Important notes

* **There is no backend yet.** Everything is stored on the device (`shared_preferences` + images copied to app
  storage). The first launch is seeded with sample data. All reads/writes go through `lib/state/app_state.dart`,
  which is the single place to swap in real API calls.
* To test the "new order" flow without a server, **long-press the bell icon on Home** - it creates a pending order
  and a notification. Remove that `onLongPress` when you connect a real order feed.
* Push notifications are not wired up (they need a backend / Firebase project).
* Support phone, email and WhatsApp in `lib/config.dart` are placeholders - replace them.
* The seed menu images for "Freshly cut gizzard" and "3 bulb Garlic" were cropped from the design PNGs
  (low resolution); replace `assets/images/*.png` with proper product photos.
* Font is the platform default (Roboto) rather than the Inter used in the designs; add `google_fonts` or a bundled
  Inter font if you want an exact match.
