# BigHeads

اپ پیام‌رسان با Flutter — پشتیبانی از زبان فارسی و انگلیسی.

## پیش‌نیازها

- **Flutter** نصب باشد ([flutter.dev](https://flutter.dev))
- **Dart** نسخه ≥ 3.11

## نحوه اجرا

### ۱. اپ Flutter (موبایل)

```bash
cd bighead
flutter pub get
flutter run
```

یا برای اندروید:

```bash
flutter run -d android
```

یا برای iOS (فقط macOS):

```bash
flutter run -d ios
```

### ۲. بکند (برای چت از طریق سرور)

برای استفاده از قابلیت چت از طریق سرور، باید بکند را اجرا کنید:

```bash
cd bighead
dart run backend/server.dart 8080
```

سرور روی `http://0.0.0.0:8080` بالا می‌آید.

در صفحه لاگین اپ، آدرس سرور را تنظیم کنید (مثلاً `http://192.168.1.10:8080` با IP واقعی ماشین شما).

## بیلد APK

```bash
cd bighead
flutter build apk --release
```

فایل APK در مسیر زیر ذخیره می‌شود:

`build/app/outputs/flutter-apk/app-release.apk`
