# AgentBridge: AI Coding Agent Guidelines for Remote Workspaces

This repository is an **AgentBridge Workspace** — a lightweight, zero-lag bridge connecting local AI coding agents (Antigravity, Cursor, Claude Code, Copilot, etc.) and developers to remote servers, remote repositories, and edge devices.

---

## 🧭 1. Core Operating Directives

### 1.1 Remote-First Execution Directive
- **Code & Repository State:** The real development workspace lives on the remote host (configured in `.env`).
- **Local View ([mnt/](file:///mnt)):** Remote files are mounted locally via SSHFS for instant reading, searching, and editing.
- **Remote Commands:** Never run build scripts, tests, servers, or environment-dependent commands locally. Always use:
  ```bash
  ./remote-run.sh "<command>"
  ```

### 1.2 Remote Git Protocol (CRITICAL / DO NOT VIOLATE)
- ⛔ **RED LINE:** Never execute `git` commands (`git status`, `git commit`, `git add`, `git diff`) or file indexing tools inside the mounted `mnt/` folder from the local shell. Network filesystems (SSHFS/FUSE) are not optimized for traversal of deep `.git` trees and will freeze the IDE and network socket.
- ✅ **Standard Procedure:** All Git operations for the remote project must be run directly on the remote host:
  ```bash
  ./remote-run.sh "git status"
  ./remote-run.sh "git diff"
  ./remote-run.sh "git add . && git commit -m '<commit-message>'"
  ./remote-run.sh "git push origin <branch>"
  ```
- *Note:* The local `AgentBridge` workspace itself has its own independent `.git` repository, which only tracks bridge scripts, templates, and configurations while strictly ignoring `mnt/` and secrets.

### 1.3 Read-Only Safety First
- Do not modify production configurations, network interfaces, or critical services on remote hosts without explicit user confirmation.

---

## 🛠️ 2. Bridge Tooling Reference

| Tool / Script | Purpose | Example Usage |
| :--- | :--- | :--- |
| `./remote-run.sh [cmd]` | Executes commands or opens shell inside remote project directory | `./remote-run.sh pytest` or `./remote-run.sh "npm run build"` |
| `./mount.sh` | Mounts remote project via performance-optimized SSHFS | `./mount.sh` |
| `./unmount.sh` | Safely unmounts SSHFS with lazy-unmount fallback | `./unmount.sh` |
| `./proxy.sh [port]` | Spawns a background SOCKS5 proxy via remote host | `./proxy.sh 1080` |
| `load-env.sh` | Common environment loader for hosts, routing, and paths | Sourced automatically by scripts |

---

## 🌐 3. Network & Edge Device Bridges (If Enabled)

When working in environments that manage switches, routers, or IoT nodes:
- Consult local inventory files (`devices.toml` or custom configs).
- Use designated bridge helpers (e.g. `./cisco-bridge.sh`, `./mikrotik-bridge.sh`) to query or dispatch commands through the remote jump host rather than attempting direct connections.
