# omano — ابزار چک پروکسی مخصوص OpenBullet 2

چکر پروکسی که **دقیقاً مثل OpenBullet 2** تست می‌کنه: یه GET واقعی HTTPS می‌زنه و پروتکل درست (HTTP / SOCKS4 / SOCKS4a / SOCKS5) رو خودکار تشخیص میده و خروجی رو با فرمت آماده‌ی OB2 تحویل میده: `(socks5)host:port`

---

## 📦 نصب (یک دستور)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mikamikaloti-blip/omano/main/install.sh)
```

اسکریپت نصب خودش:
- آخرین نسخه رو دانلود می‌کنه (~۷۵ مگ)
- توی `~/.local/bin` نصب می‌کنه
- PATH رو تنظیم می‌کنه
- تست می‌کنه که اجرا میشه

> نیازی به توکن یا حساب گیت‌هاب نیست — ولی **بدون لایسنس هیچ دستوری اجرا نمیشه**.

---

## 🔓 فعال‌سازی لایسنس (اجباری)

بدون لایسنس، ابزار **هیچ دستوری** رو اجرا نمی‌کنه.

**۱. شناسه دستگاه خودت رو بگیر و برای فروشنده بفرست:**
```bash
omano lic machine-id
# خروجی مثلاً: dd5b3ecd2ebaf79f2c186c9c7afe1660
```

**۲. کلیدی که فروشنده برات فرستاده رو فعال کن:**
```bash
omano lic activate eyJleHBpcmVzIjoiMjAy...
```

**۳. وضعیت لایسنت رو ببین:**
```bash
omano lic status
```

> ⏱ لایسنس‌ها **محدود به زمان** هستن (مثلاً ۴۸ ساعت). بعد از انقضا باید از فروشنده کلید جدید بگیری. تاریخ دقیق انقضا رو `lic status` نشون میده.

---

## 🚀 استفاده

```bash
# دانلود پروکسی از آرشیو checker.net (رایگان)
omano download --days 1            # آخرین روز
omano download 2026-09-01          # تاریخ خاص
omano download --days 7 --merge    # هفته اخیر + ادغام در یک فایل

# چک کردن پروکسی‌ها (به سبک OpenBullet 2)
omano check proxies.txt                        # هدف پیش‌فرض: google.com
omano check proxies.txt --workers 100          # ۱۰۰ چک همزمان
omano check proxies.txt -n 500                 # فقط ۵۰۰ تای اول
omano check proxies.txt --url https://instagram.com --key "insta"

# ادغام و آمار
omano merge file1.txt file2.txt -o merged.txt
omano stats proxies.txt
```

## 📤 خروجی

برای هر چک، این فایل‌ها ساخته میشن:
- `ob2_working.txt` — همه پروکسی‌های سالم با فرمت OB2
- `ob2_working_http.txt` — فقط HTTP
- `ob2_working_socks5.txt` — فقط SOCKS5
- `ob2_working_socks4.txt` — فقط SOCKS4

فرمت آماده‌ی ایمپورت مستقیم توی **OpenBullet 2 → Proxies → Import from text/file**.

---

## ❓ رفع اشکال

| مشکل | راه‌حل |
|------|--------|
| `command not found: omano` | ترمینال جدید باز کن یا `source ~/.bashrc` |
| `No license found` | `omano lic activate <KEY>` |
| `License expired` | از فروشنده کلید جدید بگیر |
| `License is bound to a different machine` | لایسنس برای سیستم دیگه‌ست — machine-id خودت رو بفرست |
| دانلود ریلیز fail میشه | اینترنت قطعه — دوباره امتحان کن |
| `System clock was rolled back` | ساعت سیستم رو درست تنظیم کن و دوباره امتحان کن |

---

## 🔒 امنیت

- لایسنس با امضای رمزنگاری Ed25519 محافظت میشه — جعل عملاً غیرممکنه
- هر لایسنس فقط روی **یک دستگاه** کار می‌کنه
- برگردوندن ساعت سیستم باعث تعلیق لایسنس میشه
