#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOUNT_POINT="${SCRIPT_DIR}/mnt"

if ! mountpoint -q "${MOUNT_POINT}"; then
    echo "ℹ️  Mount point ${MOUNT_POINT} is not mounted."
    exit 0
fi

echo "🛑 Unmounting ${MOUNT_POINT} ..."
if fusermount -u "${MOUNT_POINT}"; then
    echo "✅ Successfully unmounted ${MOUNT_POINT}"
else
    echo "⚠️  Standard unmount failed, attempting lazy unmount..."
    fusermount -uz "${MOUNT_POINT}"
    echo "✅ Force unmounted."
fi
