# راهنمای استخراج و مشاهده زنده مکالمات Antigravity IDE / Agy در Obsidian

این مستند راهکار بی‌دردسر، تمیز و بدون مشکل بهم‌ریختگی حروف فارسی برای مشاهده، ذخیره و ثبت تمام مکالمات و پاسخ‌های **Antigravity IDE / Agy** داخل محیط **Obsidian** را تشریح می‌کند.

---

## 💡 ساختار و ریشه داده‌ها

تمامی مکالمات، پرامپت‌های کاربر و پاسخ‌های هوش مصنوعی (همراه با کدهای Markdown و جداول) به‌صورت خودکار و تمیز در مسیر زیر ذخیره می‌شوند:

* **مسیر لاگ‌های کامل سشن فعلی:**
  `~/.gemini/antigravity-ide/brain/<session-id>/.system_generated/logs/transcript_full.jsonl`

این لاگ‌ها شامل متن خالص (Clean Text) هستند و کدهای کنترلی/گرافیکی ترمینال (ANSI escape codes) روی آن‌ها اعمال نشده است.

---

## 🛠️ اسکریپت تبدیل زنده به مارک‌داون (`live-export`)

برای تبدیل داده‌های `jsonl` لاگ‌ها به یک فایل مارک‌داون (`.md`) کاملاً مرتب، خوانا و با فونت فارسی عالی در ابسیدین:

### ۱. دستور مستقیم تبدیل:

```bash
python3 -c "
import json, re

transcript_path = '/home/unreal/.gemini/antigravity-ide/brain/5ee478b7-f49d-4754-8640-7519fe1bf6da/.system_generated/logs/transcript_full.jsonl'
output_md = '/home/unreal/Notes/live_session.md'

with open(transcript_path, 'r', encoding='utf-8') as f, open(output_md, 'w', encoding='utf-8') as out:
    out.write('# 🤖 لاگ زنده مکالمه با Antigravity / Agy\n\n---\n\n')
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
            step_type = data.get('type')
            content = data.get('content', '')
            if step_type == 'USER_INPUT':
                clean_content = re.sub(r'<ADDITIONAL_METADATA>.*?</ADDITIONAL_METADATA>', '', content, flags=re.DOTALL)
                clean_content = re.sub(r'<USER_SETTINGS_CHANGE>.*?</USER_SETTINGS_CHANGE>', '', clean_content, flags=re.DOTALL).strip()
                out.write(f'## 🧑‍💻 کاربر:\n\n{clean_content}\n\n---\n\n')
            elif step_type == 'PLANNER_RESPONSE':
                if content:
                    out.write(f'### 🤖 ایجنت:\n\n{content}\n\n---\n\n')
        except Exception as e:
            pass
"
```

---

## 🔄 نحوه فعال‌سازی سینک خودکار و همزمان (Auto-Sync Daemon)

برای اینکه با هر پاسخ جدید ایجنت، فایل `live_session.md` در **Obsidian** به صورت لحظه‌ای آپدیت شود، می‌توانید یک `inotifywait` یا دیمن ساده در پس‌زمینه اجرا کنید تا تغییرات فایل `transcript_full.jsonl` را نظارت کرده و به‌روزرسانی کند:

```bash
while inotifywait -e modify /home/unreal/.gemini/antigravity-ide/brain/*/system_generated/logs/transcript_full.jsonl; do
    # اجرای اسکریپت به‌روزرسانی
    python3 -c "...(اسکریپت بالا)..."
done
```

---

## 🎯 مزایای این روش نسبت به سایر راهکارها

1. **کیفیت کامل فونت و راست‌به‌چپ (RTL):** متون در ابسیدین با موتور رندر مرورگر نمایش داده شده و حروف فارسی کاملاً چسبیده و درست رندر می‌شوند.
2. **عدم درگیر شدن با ترمینال:** نیازی به تنظیمات WezTerm، SSHFS یا کدهای پیچیده ANSI Terminal نیست.
3. **حفظ حالت تعاملی `agy`:** کاربر می‌تواند به طور کامل از توانایی‌های تعاملی ایجنت در شل استفاده کند، در حالی که خروجی تر و تمیز برای بازبینی طولانی‌مدت در ابسیدین ثبت می‌شود.
