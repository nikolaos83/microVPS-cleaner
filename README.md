![Built for Small Servers](https://img.shields.io/badge/Built%20for-Small%20Servers-green?style=flat-square)
![ShellCheck](https://github.com/nikolaos83/microVPS-cleaner/actions/workflows/shellcheck.yml/badge.svg)


# Micro VPS Cleaner Script

A smart, interactive script designed to **clean up and optimize small servers** (like Oracle Cloud Free Tier Micro Instances) by removing unnecessary services, setting up lightweight swap, and ensuring memory remains under control.

---

## 📋 Features

- Detects and suggests removal of unnecessary services
- Guides user with informative prompts before making changes
- Automatically sets up **ZRAM swap** (compressed RAM swap)
- Installs and enables **EarlyOOM** for low-memory protection
- Cleans old packages and limits system log file sizes
- Colorful, easy-to-read output

---

## 🚀 Quick Start

1. SSH into your server

2. Download the script:
```bash
curl -O https://raw.githubusercontent.com/nikolaos83/microVPS-cleaner/main/micro_cleaner.sh
chmod +x micro_cleaner.sh
```

3. Run the script as root:
```bash
sudo ./micro_cleaner.sh
```

4. Follow the on-screen prompts!

---

## 🧠 Requirements

- Ubuntu 20.04 / 22.04 (or similar Debian-based distro)
- `apt`, `systemctl` available
- Minimal system resources (perfect for 1GB RAM servers)

---

## 🖥️ Example Output

```text
🔍 Scanning for unnecessary services...
Detected: snapd - Snap system (heavy, rarely needed)
➔ Do you want to disable and purge snapd? [y/N] y
Removing snapd...
...
🧹 Cleaning up orphaned packages...
🔄 Setting up ZRAM swap...
🧠 Installing EarlyOOM for better memory handling...
🗒️ Configuring journald log size limits...
✅ Cleanup and optimization complete! Reboot recommended.
```

---

## 📜 License

MIT License — Free to use, modify, and share. Please leave credit if you fork! ❤️

---

## 🌱 Why use Micro Cleaner?

Tiny cloud instances (1GB RAM or less) often come bloated with services you don't need. Micro Cleaner gives you control over what stays and what goes, while also tuning the server for **maximum performance with minimal footprint**.

**Built for Small Servers 💾🌿**

---

## ✍️ TODOs for future versions

- [ ] Auto-detect Alpine / Debian / Oracle Linux variants
- [ ] Auto-detect virtualization platform (OCI, AWS, etc)
- [ ] Add "safe mode" for extra cautious operations
- [ ] Automatic backup of configurations before changes

---

Happy Cleaning! 🧹✨

