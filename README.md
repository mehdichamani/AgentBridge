# 🌉 AgentBridge

> **Zero-Lag Remote Workspace Bridge for AI Coding Agents & Developers**  
> Seamlessly edit, search, and collaborate on remote codebases using local AI agents (Antigravity, Cursor, Claude Code, etc.) without IDE lag, heavy remote daemon crashes, or Git freezes over network filesystems.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![AI-Ready](https://img.shields.io/badge/AI--Ready-Antigravity%20%7C%20Cursor%20%7C%20Claude-purple.svg)](#)

---

## ⚡ The Problem AgentBridge Solves

Developing on remote workstations, cloud VMs, or air-gapped lab servers often presents difficult trade-offs:
- **VS Code Remote-SSH / JetBrains Gateway:** Heavy background server processes consume immense memory/CPU and crash over unstable connections.
- **Traditional SSHFS / NFS Mounts:** Running local Git commands or IDE indexing over network filesystems freezes your editor due to thousands of round-trip stat queries.
- **AI Coding Agents Limitations:** Modern AI agents run best locally on your machine, but they need to inspect files and execute commands on a remote host without getting confused or stalling the session.

**AgentBridge** provides an elegant, lightweight architecture:
1. **Local-Speed Editing:** Mount remote source code via tuned SSHFS with kernel caching and chacha20 encryption.
2. **Zero-Lag Git & Execution:** Remote commands (`npm`, `pytest`, `cargo`, `git`) execute natively on the remote host via `remote-run.sh`.
3. **Agent Directives (`AGENTS.md`):** Out-of-the-box instructions teach AI agents how to inspect local mounts while delegating execution to the remote host.
4. **Dynamic Dual-Routing:** Automatically detects LAN / VPN / WireGuard tunnels and switches between low-latency local paths and public fallback IPs.

---

## 🏗️ Architecture

```text
┌────────────────────────────────────────────────────────┐
│                      LOCAL HOST                        │
│                                                        │
│   ┌─────────────────────┐    ┌─────────────────────┐   │
│   │   AI Coding Agent   │    │      Local IDE      │   │
│   │ (Antigravity/Cursor)│    │   (VS Code / VSC)   │   │
│   └──────────┬──────────┘    └──────────┬──────────┘   │
│              │                          │              │
│       Execution Bridge           Local Mount (mnt/)    │
│       (remote-run.sh)            (Read/Write Files)    │
│              │                          │              │
└──────────────┼──────────────────────────┼──────────────┘
               │ SSH Command Pipe         │ Tuned SSHFS
               ▼                          ▼
┌────────────────────────────────────────────────────────┐
│                     REMOTE HOST                        │
│                                                        │
│   ┌────────────────────────────────────────────────┐   │
│   │               Target Project Dir               │   │
│   │          (Source, Compiler, Native Git)        │   │
│   └────────────────────────┬───────────────────────┘   │
│                            │ (Optional Jump Host)      │
│                            ▼                           │
│              Edge Devices / Internal Mesh              │
└────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. Prerequisites
- **Local Machine:** Linux or macOS with `bash`, `ssh`, and `sshfs` (`sudo pacman -S sshfs` or `sudo apt install sshfs`)
- **Remote Machine:** Any Linux, macOS, or Windows host with OpenSSH server running

### 2. Setup Configuration
Clone the repository and copy the environment template:
```bash
git clone https://github.com/your-username/agent-bridge.git
cd agent-bridge
cp .env.example .env
```

Edit `.env` with your remote host details:
```bash
# Primary SSH host alias (defined in ~/.ssh/config)
REMOTE_HOST="my-remote-server"

# Fast/LAN/WireGuard fallback (optional)
FAST_HOST="my-lan-server"
FAST_HOST_PING="192.168.1.100"

# Target project directory on remote machine
REMOTE_PROJECT_DIR="/home/ubuntu/projects/my-app"
```

### 3. Mount & Start Working
Mount the remote codebase locally:
```bash
./mount.sh
```
Open this workspace in your favorite IDE:
```bash
code .
```
You can now edit files inside `mnt/` with zero lag!

---

## 🛠️ CLI Toolkit Reference

| Command | Description |
| :--- | :--- |
| `./mount.sh` | Mounts remote project to `mnt/` using tuned SSHFS cache flags |
| `./unmount.sh` | Safely unmounts `mnt/` with lazy-unmount fallback |
| `./remote-run.sh [cmd]` | Runs command inside the remote project directory (or opens shell if empty) |
| `./proxy.sh [port]` | Establishes a dynamic SOCKS5 tunnel for browsing remote internal services |

### Examples:
```bash
# Run remote tests
./remote-run.sh pytest -v

# Run remote package manager
./remote-run.sh npm run build

# Check remote git status
./remote-run.sh git status

# Start SOCKS5 proxy on port 1080
./proxy.sh 1080
```

---

## 🤖 AI Agent Integration

AgentBridge includes a pre-configured `AGENTS.md` file. When you open this workspace in AI agents like **Antigravity**, **Cursor**, or **Claude Code**:
- The agent reads instructions and immediately understands that `mnt/` is a remote mount.
- The agent knows **not** to run local `git` inside `mnt/`, preventing freezes.
- The agent autonomously dispatches terminal runs through `./remote-run.sh "<command>"`.

---

## 🔒 Security & Safe Git Ignore

AgentBridge is pre-configured with a comprehensive `.gitignore` ensuring that:
- The `mnt/` mount point and its contents are never tracked locally.
- Sensitive SSH configs and secrets (`.env`, `devices.toml`, `*.pem`, `*.key`) are completely excluded from commits.

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
