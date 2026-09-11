# আরহাম ইলেকট্রিক — Android App

এটি Flutter ভিত্তিক Android দোকান-ম্যানেজমেন্ট অ্যাপের source project।

## বর্তমানে থাকা ফিচার
- পণ্য যোগ ও খোঁজা
- ক্রয়মূল্য, বিক্রয়মূল্য ও স্টক
- বিক্রয় রেকর্ড
- নগদ/বাকি পেমেন্ট নির্বাচন
- কাস্টমার যোগ ও খোঁজা
- রিপোর্ট/ড্যাশবোর্ড
- লোকাল SQLite ডেটাবেস
- আরহাম ইলেকট্রিক লোগো
- লগইন স্ক্রিনের প্রাথমিক কাঠামো

## গুরুত্বপূর্ণ
এই source-টি prototype/working starter। অন্য দোকানদারদের জন্য commercial release করার আগে server-side login, shop/tenant isolation, activation/license server, secure password hashing, cloud sync, customer-linked due/payment ledger, backup এবং audit log যোগ করতে হবে। APK-তে secret activation code hard-code করবেন না।

## মোবাইল দিয়ে APK বানানো
সবচেয়ে সহজ পথ: GitHub + Codemagic।

1. ফোনের Chrome থেকে GitHub-এ account খুলুন/লগইন করুন।
2. নতুন একটি repository তৈরি করুন, যেমন `arham-electric`।
3. এই ZIP extract করে ভিতরের ফাইলগুলো repository-তে upload করুন।
4. repository-তে `pubspec.yaml`, `lib/`, `assets/`, `codemagic.yaml` root level-এ থাকতে হবে।
5. Codemagic-এ লগইন করে Add application করুন।
6. GitHub connect করে `arham-electric` repository নির্বাচন করুন।
7. Flutter project হিসেবে add করুন।
8. `codemagic.yaml` থাকলে সেটি build workflow হিসেবে ব্যবহার হবে।
9. Start new build চাপুন।
10. Build সফল হলে Artifacts থেকে `.apk` ফাইল download করুন।
11. ফোনে APK খুলে Install দিন। Android নিরাপত্তা অনুমতি চাইলে আপনার browser/file manager-এর জন্য “Install unknown apps” অনুমতি দিতে হতে পারে।

## APK build command
Cloud builder-এ মূল command:

    flutter build apk --release

## পরের production ধাপ
- Supabase/Firebase বা নিজস্ব API backend
- Username/password authentication
- দোকানভিত্তিক data isolation
- Owner activation/license API
- Offline outbox + automatic sync
- Conflict/idempotency handling
- Customer due/payment history
- Cash/capital ledger
- Backup/restore
- Release signing/keystore

এই কাজগুলো ছাড়া বর্তমান source-কে বহু দোকানে commercial deployment হিসেবে ব্যবহার করা উচিত নয়।
