# শুধু মোবাইল দিয়ে APK বানানোর ধাপ

## যা লাগবে
- Android ফোন
- Chrome browser
- GitHub account
- Codemagic account
- এই project ZIP

## ধাপ ১ — ZIP extract
ফোনের Files/File Manager দিয়ে ZIP extract করুন।

## ধাপ ২ — GitHub repository
Chrome খুলে github.com এ যান → New repository → নাম দিন `arham-electric` → Create repository।

## ধাপ ৩ — ফাইল upload
Repository-তে Add file → Upload files নির্বাচন করুন। Extract করা project-এর ফাইল upload করুন।

Root-এ অবশ্যই থাকতে হবে:
- pubspec.yaml
- codemagic.yaml
- lib/main.dart
- lib/db.dart
- assets/arham_logo.png

## ধাপ ৪ — Codemagic
codemagic.io এ যান → Sign in → Add application → GitHub → `arham-electric` নির্বাচন করুন → Flutter project নির্বাচন করুন।

## ধাপ ৫ — Build
`codemagic.yaml` root-এ থাকলে workflow স্বয়ংক্রিয়ভাবে সেটি ব্যবহার করবে। Build শুরু করুন। Workflow প্রথমে Android platform files তৈরি করবে (যদি source-এ না থাকে), package install করবে, analyze করবে এবং release APK তৈরি করবে।

## ধাপ ৬ — APK নেওয়া
Build সফল হলে Artifacts অংশে APK পাবেন। সেটি ফোনে download করে Install করুন।

## যদি build fail হয়
প্রথমে Build log-এর শেষ 20–30 লাইন দেখুন। সাধারণত ভুল file location, dependency বা YAML configuration-এর কারণে failure হয়।
