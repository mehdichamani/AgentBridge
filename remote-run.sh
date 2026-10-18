#!/usr/bin/env bash
# Runs any command directly on the remote Windows host inside the project folder

# اولویت اتصال سریع با تانل وایرگارد (it2)؛ در غیر اینصورت اینترنت پابلیک (work)
if ping -c 1 -W 1 192.168.1.100 &>/dev/null; then
    REMOTE_HOST="it2"
else
    REMOTE_HOST="work"
fi

PROJECT_DIR="C:/Users/Mehdi/projects/boomban-suite"

if [ $# -eq 0 ]; then
    # Interactive SSH shell into remote project directory
    exec ssh -t "${REMOTE_HOST}" "cd '${PROJECT_DIR}' ; cmd.exe /k"
else
    # Execute specific command on remote host
    exec ssh "${REMOTE_HOST}" "cd '${PROJECT_DIR}' && $*"
fi
