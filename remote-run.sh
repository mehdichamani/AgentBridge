#!/usr/bin/env bash
# ==============================================================================
# AgentBridge: remote-run.sh
# Execute any command or open an interactive shell in the remote project directory
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

if [ $# -eq 0 ]; then
    # Interactive SSH shell into remote project directory
    echo "🚀 Connecting to interactive shell on ${ACTIVE_HOST}:${REMOTE_PROJECT_DIR}..."
    exec ssh -t "${ACTIVE_HOST}" "cd '${REMOTE_PROJECT_DIR}' && bash --login"
else
    # Execute specific command on remote host
    exec ssh "${ACTIVE_HOST}" "cd '${REMOTE_PROJECT_DIR}' && $*"
fi
