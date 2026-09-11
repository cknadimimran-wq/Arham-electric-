# Build notes

This source is Android-ready Flutter source. The current environment does not contain Flutter/Android SDK, so I cannot honestly claim an APK was compiled here.

Build on a Flutter/Android machine:
flutter pub get
flutter analyze
flutter build apk --release

The source already contains the requested logo, local product/stock/sales/customer structure and offline database foundation. Production must add secure cloud authentication, shop isolation, activation/license API, sync engine, customer payment history and backups before distributing it to other shopkeepers.
