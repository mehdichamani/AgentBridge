#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOUNT_POINT="${SCRIPT_DIR}/mnt"
REMOTE_PATH="/C:/Users/Mehdi/projects/boomban-suite"

# هوشمند: بررسی اولویت تانل وایرگارد (it2)؛ در صورت عدم دسترسی استفاده از اینترنت پابلیک (work)
if ping -c 1 -W 1 192.168.1.100 &>/dev/null; then
    REMOTE_HOST="it2"
    echo "🟢 WireGuard tunnel active. Routing via fast local host: ${REMOTE_HOST} (192.168.1.100)"
else
    REMOTE_HOST="work"
    echo "🟠 WireGuard tunnel unreachable. Routing via public IP host: ${REMOTE_HOST}"
fi

mkdir -p "${MOUNT_POINT}"

if mountpoint -q "${MOUNT_POINT}"; then
    echo "ℹ️  Mount point ${MOUNT_POINT} is already mounted."
    exit 0
fi

echo "🚀 Mounting ${REMOTE_HOST}:${REMOTE_PATH} -> ${MOUNT_POINT} ..."

# پارامترهای بهینه‌شده:
# - reconnect, ServerAlive: حفظ پایداری اتصال
# - kernel_cache, cache=yes, dir_cache=yes: کش کردن خواندن فایل‌ها و متادیتاها
# - cache_timeout=120: جلوگیری از ارسال کوئری‌های مکرر stat روی شبکه
# - auto_cache: مدیریت هوشمند کش هنگام ویرایش فایل
# - Ciphers=chacha20-poly1305@openssh.com: سبک‌ترین و سریع‌ترین الگوریتم رمزنگاری
# - compression=no: کاهش لود CPU با توجه به سریع بودن پردازش متن خام
sshfs "${REMOTE_HOST}:${REMOTE_PATH}" "${MOUNT_POINT}" \
    -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,follow_symlinks \
    -o cache=yes,kernel_cache,auto_cache,dir_cache=yes,cache_timeout=120 \
    -o Ciphers=chacha20-poly1305@openssh.com \
    -o compression=no

if mountpoint -q "${MOUNT_POINT}"; then
    echo "✅ Successfully mounted to ${MOUNT_POINT}"
else
    echo "❌ Mount failed."
    exit 1
fi
