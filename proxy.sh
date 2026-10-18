#!/usr/bin/env bash
# ==============================================================================
# AgentBridge: proxy.sh
# Establish a dynamic SOCKS5 tunnel through remote host for local browsers/tools
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/load-env.sh"

ACTIVE_HOST="$(resolve_active_host)"
PORT="${1:-${DEFAULT_PROXY_PORT}}"

echo "🌐 Starting SOCKS5 dynamic proxy on 127.0.0.1:${PORT} through ${ACTIVE_HOST}..."
echo "💡 You can configure your local browser or CLI tools to use socks5://127.0.0.1:${PORT}"
echo "Press Ctrl+C to terminate."
exec ssh -N -D "${PORT}" "${ACTIVE_HOST}"
