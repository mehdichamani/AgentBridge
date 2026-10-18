#!/usr/bin/env bash
# ==============================================================================
# AgentBridge: unmount.sh
# Safely unmount remote SSHFS project directory
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/load-env.sh"

if ! mountpoint -q "${MOUNT_POINT}"; then
    echo "ℹ️  Mount point ${MOUNT_POINT} is not mounted."
    exit 0
fi

echo "🛑 Unmounting ${MOUNT_POINT} ..."
if fusermount -u "${MOUNT_POINT}"; then
    echo "✅ Successfully unmounted ${MOUNT_POINT}"
else
    echo "⚠️  Standard unmount failed (busy), attempting lazy unmount..."
    fusermount -uz "${MOUNT_POINT}"
    echo "✅ Force/lazy unmounted."
fi
