#!/usr/bin/env bash
# ==============================================================================
# AgentBridge: mount.sh
# Mount remote project directory into local workspace using optimized SSHFS
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/load-env.sh"

ACTIVE_HOST="$(resolve_active_host)"

if [ -z "${REMOTE_PROJECT_DIR}" ]; then
    echo "❌ Error: REMOTE_PROJECT_DIR is not configured in .env" >&2
    exit 1
fi

mkdir -p "${MOUNT_POINT}"

if mountpoint -q "${MOUNT_POINT}"; then
    echo "ℹ️  Mount point ${MOUNT_POINT} is already mounted."
    exit 0
fi

if ! command -v sshfs &>/dev/null; then
    echo "❌ Error: 'sshfs' command is not installed on this local system." >&2
    echo "👉 Install with: sudo pacman -S sshfs (Arch) OR sudo apt install sshfs (Debian/Ubuntu)" >&2
    exit 1
fi

echo "🚀 Mounting ${ACTIVE_HOST}:${REMOTE_PROJECT_DIR} -> ${MOUNT_POINT} ..."

# Optimized SSHFS Mount Parameters:
# - reconnect, ServerAlive: Auto reconnect on intermittent network drops
# - cache=yes, kernel_cache, auto_cache: Accelerate file reads & metadata checks
# - cache_timeout=120: Avoid frequent stat queries across the network
# - Ciphers=chacha20-poly1305@openssh.com: High speed, low latency cipher
# - compression=no: Lower CPU overhead for local text/code editing
sshfs "${ACTIVE_HOST}:${REMOTE_PROJECT_DIR}" "${MOUNT_POINT}" \
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
