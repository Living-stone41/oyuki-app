# Oyuki

This repository contains two separate Flutter applications for the Oyuki marketplace:

- Buyer app: `oyuki_app/`
- Vendor app: `oyuki_vendor/`

## Project structure

- Root project folder: `oyuki/`
- Buyer app folder: `oyuki_app/`
- Vendor app folder: `oyuki_vendor/`
- Buyer app entry point: `oyuki_app/lib/main.dart`
- Vendor app entry point: `oyuki_vendor/lib/main.dart`

## How to run each app

Buyer app:

```bash
cd oyuki_app
flutter pub get
flutter run
```

Vendor app:

```bash
cd oyuki_vendor
flutter pub get
flutter run
```

## Notes

The buyer app is the customer-facing marketplace, while the vendor app is the seller/admin side for managing store operations.
