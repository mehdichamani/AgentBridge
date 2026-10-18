#!/usr/bin/env bash
# ==============================================================================
# AgentBridge Environment Loader & Helper
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
ENV_EXAMPLE="${SCRIPT_DIR}/.env.example"

if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
elif [ -f "${ENV_EXAMPLE}" ]; then
    echo "⚠️ Warning: .env not found. Falling back to .env.example defaults." >&2
    # shellcheck disable=SC1090
    source "${ENV_EXAMPLE}"
else
    echo "❌ Error: Neither .env nor .env.example found." >&2
    exit 1
fi

# Set defaults if not provided
REMOTE_HOST="${REMOTE_HOST:-work}"
LOCAL_MOUNT_DIR="${LOCAL_MOUNT_DIR:-mnt}"
MOUNT_POINT="${SCRIPT_DIR}/${LOCAL_MOUNT_DIR}"
DEFAULT_PROXY_PORT="${DEFAULT_PROXY_PORT:-1080}"

# Resolve active host dynamically based on ping/healthcheck
resolve_active_host() {
    if [ -n "${FAST_HOST}" ] && [ -n "${FAST_HOST_PING}" ]; then
        if ping -c 1 -W 1 "${FAST_HOST_PING}" &>/dev/null; then
            echo "${FAST_HOST}"
            return 0
        fi
    fi
    echo "${REMOTE_HOST}"
}
