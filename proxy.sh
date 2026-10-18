#!/usr/bin/env bash
# Creates a SOCKS5 proxy via the remote host for local browsers or tools (curl, proxychains)
PORT="${1:-1080}"
REMOTE_HOST="work"

echo "🌐 Starting SOCKS5 dynamic proxy on 127.0.0.1:${PORT} through ${REMOTE_HOST}..."
echo "💡 You can configure your browser/tools to use socks5://127.0.0.1:${PORT}"
echo "Press Ctrl+C to terminate."
exec ssh -N -D "${PORT}" "${REMOTE_HOST}"
