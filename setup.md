# setup.sh — Raspberry Pi NAS Setup Script

> *This file explains what the `setup.sh` script does in the raspberrypi-nas-setup project.*

## 🧰 Purpose

This script automates the configuration of a Raspberry Pi as a basic NAS (Network-Attached Storage) with:
- A **Time Machine-compatible** backup share
- A general **shared folder**
- A **single user account**, created interactively

---

## 🔍 What It Does

### 1. 📦 Installs Required Software

It installs:
- `samba` — the service that shares folders over the network
- `avahi-daemon` — allows the Pi to appear in the macOS Finder (Bonjour/zeroconf)

```bash
sudo apt update
sudo apt install -y samba samba-common-bin avahi-daemon
```

---

### 2. 👤 Creates a User

It prompts you for a username and password. The user is created on both the system and Samba:

```bash
useradd -m <username>
chpasswd
smbpasswd -a <username>
```

---

### 3. 📂 Sets Up Folders

Creates two directories:
- `/mnt/samsung/timemachine`
- `/mnt/samsung/shared`

And sets permissions so that the new user has full control.

---

### 4. ⚙️ Updates Samba Configuration

Appends two share definitions to `/etc/samba/smb.conf`:

- `[timemachine]`: Time Machine-compatible share using `fruit:` options
- `[shared]`: A general file share

The user you created is allowed access to both.

---

### 5. 🔁 Restarts Samba

Applies the new configuration with:
```bash
sudo systemctl restart smbd
```

---

## ✅ Result

You can now connect from a Mac via Finder or Time Machine:

```smb
smb://pi-nas.local/shared
smb://pi-nas.local/timemachine
```

Use the credentials of the user you created.

---

## 🚨 Warnings

- Running this script modifies `/etc/samba/smb.conf`. It makes a backup first.
- You should run this on a clean setup or after reviewing the script contents.

---

Happy file sharing! 🎉
