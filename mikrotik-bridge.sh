#!/usr/bin/env bash
# ==============================================================================
# mikrotik-bridge.sh - Boomban Remote MikroTik Bridge CLI
# ==============================================================================
# واسط خط فرمان کاربری و ایجنت در محیط ریموت لینوکس جهت ارتباط مستقیم با تجهیزات میکروتیک
# این اسکریپت دستور را به اسکریپت agent_core/mikrotik_bridge.py روی هاست ریموت ویندوز ارسال می‌کند.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# بررسی مانت بودن پوشه mnt در صورت نیاز
if [ ! -d "${SCRIPT_DIR}/mnt" ]; then
    echo "[-] Error: Remote mount directory not found." >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    exec "${SCRIPT_DIR}/remote-run.sh" "python agent_core/mikrotik_bridge.py list"
else
    # اجرای دستور با حفظ ساختار آرگومان‌ها
    exec "${SCRIPT_DIR}/remote-run.sh" "python agent_core/mikrotik_bridge.py $*"
fi
