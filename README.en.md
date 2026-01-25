# Linux Update Script

[![Version](https://img.shields.io/github/v/release/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux?label=Version)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![ShellCheck](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/actions/workflows/shellcheck.yml)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux?style=social)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/stargazers)

Automated update script for various Linux distributions with optional email notifications and detailed logging.

## Supported Distributions

- **Debian-based**: Debian, Ubuntu, Linux Mint
- **RedHat-based**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-based**: openSUSE (Leap/Tumbleweed), SLES
- **Arch-based**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus**: Solus
- **Void Linux**: Void Linux

## Features

- ✅ **Multi-language Support**: German and English (additional languages via community)
- ✅ **Desktop Notifications**: Popup notifications for updates, upgrades, errors (v1.5.1)
- ✅ **Upgrade Check System**: Automatic detection of available distribution upgrades (v1.5.0)
- ✅ **Kernel Protection**: Prevents accidental removal of fallback kernels (v1.5.0)
- ✅ Automatic distribution detection
- ✅ Fully automated system updates
- ✅ Detailed logging with timestamps
- ✅ Optional email notifications (DMA recommended)
- ✅ Interactive installation script
- ✅ Cron job support for automatic updates
- ✅ Optional automatic reboot
- ✅ Easy configuration via config file

## ⚠️ Important Notes Before Installation

### Always Run Scripts in Terminal

**❌ DO NOT double-click in file manager!**

The scripts must be run in a **terminal**, not by double-clicking in a GUI file manager (Nautilus, Dolphin, Thunar, etc.).

**✅ Correct - Use Terminal:**

```bash
# Open terminal (Ctrl+Alt+T or via application menu)
# Then navigate to the script directory:
cd ~/linux-update-script
./install.sh
```

**❌ Wrong:**
- Double-clicking `install.sh` in file manager
- Running script from wrong directory
- Using old/incorrect script versions

### Correct Directory Structure

After installation, the structure should look like this:

```
~/linux-update-script/          ← Scripts must be here!
├── update.sh                   ← Main update script
├── install.sh                  ← Installation script
├── log-viewer.sh               ← Log viewer
├── config.conf.example         ← Configuration template
├── config.conf                 ← Your configuration (after installation)
└── lang/                       ← Language files
```

**⚠️ Clean up old versions:**

If you already have previous versions or test downloads:

```bash
# Check what's in your directory:
ls -la

# Delete OLD versions (e.g.):
# - system-update.sh        ← Old name, DO NOT use!
# - README_mitMail.md       ← Old docs, DO NOT use!
```

**Only these script names are official:**
- ✅ `update.sh`
- ✅ `install.sh`
- ✅ `log-viewer.sh`

If you see files with other names (e.g. `system-update.sh`), those are **old/unofficial versions**!

---

## Prerequisites

### Installing Git (only for `git clone` method)

**⚠️ Important:** Git is **only required** if you want to download the repository with `git clone`. For the ZIP download method (see below), Git is **not** needed.

**Check if Git is installed:**
```bash
git --version
```

**Install Git (if not present):**

```bash
# Debian/Ubuntu/Mint
sudo apt-get update
sudo apt-get install git

# RHEL/CentOS/Fedora/Rocky/AlmaLinux
sudo dnf install git

# openSUSE/SUSE
sudo zypper install git

# Arch Linux/Manjaro
sudo pacman -S git

# Solus
sudo eopkg install git

# Void Linux
sudo xbps-install -S git
```

## Installation

### 1. Download Repository

**Option A: With Git (recommended for easy updates)**

Installation in home directory:
```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
```

System-wide installation in /opt:
```bash
cd /opt
sudo git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
sudo chown -R $USER:$USER linux-update-script
cd linux-update-script
```

**Advantage:** Easy updates with `git pull`

**Option B: Without Git (ZIP Download)**

If Git is not available or desired:

```bash
# Download as ZIP
cd ~
wget https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip

# Or with curl:
curl -L -o main.zip https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip

# Extract
unzip main.zip
mv Automatisiertes-Update-Script-fuer-Linux-main linux-update-script
cd linux-update-script

# Clean up ZIP file (optional)
rm ~/main.zip
```

**Note:** With ZIP download, you must download and extract the ZIP file again for updates.

### 2. Run Installation Script

**Run without sudo** (as normal user):

```bash
./install.sh
```

> **Note:** The installation script does **not** require root privileges. It only creates the configuration file and optionally sets up a cron job. The actual update script (`update.sh`) will be run with sudo later.

The installation script guides you interactively through setup:

**Step-by-Step:**
1. **Email Notification** enable or disable
   - When enabled: Enter email address
   - Script automatically checks if mail program is installed
   - Shows distribution-specific installation instructions

2. **Automatic Reboot** (optional)
   - System will automatically reboot when updates require it

3. **Log Directory** (optionally change)
   - Default: `/var/log/system-updates`
   - Script creates directory with sudo if needed

4. **Set up Cron Job** (optional)
   - Daily at 3:00 AM
   - Weekly (Sunday, 3:00 AM)
   - Monthly (1st of month, 3:00 AM)
   - Custom
   - Script automatically sets up in root crontab

All steps are confirmed with clear status messages.

### 3. Verify Configuration

After installation, the file `config.conf` is created:

```bash
cat config.conf
```

## Usage

### Running Manual Update

**⚠️ Important: First navigate to the correct directory!**

```bash
# Open terminal (Ctrl+Alt+T)

# Navigate to script directory:
cd ~/linux-update-script

# OR for /opt installation:
cd /opt/linux-update-script

# Now run the update script:
sudo ./update.sh
```

**Common mistake:**
```bash
# ❌ WRONG - without cd to correct directory:
sudo ./update.sh
# Error: ./update.sh: File or directory not found

# ✅ CORRECT - first cd to directory:
cd ~/linux-update-script
sudo ./update.sh
```

The script automatically performs the following steps:
1. Install system updates
2. Check for available distribution upgrades
3. Optional: Send email notification
4. Optional: Show desktop notification

### Performing Distribution Upgrade

**NEW in v1.5.0:** The script can now also detect and perform distribution upgrades.

#### Automatic Upgrade Check

After each successful update, the script automatically checks if a distribution upgrade is available:

```bash
sudo ./update.sh
# [INFO] System update completed successfully
# [INFO] Checking for available distribution upgrades
# [INFO] Upgrade available: Ubuntu 22.04 → Ubuntu 24.04
# [INFO] To upgrade run: sudo ./update.sh --upgrade
```

#### Manual Upgrade

To perform an available distribution upgrade:

```bash
# Navigate to script directory:
cd ~/linux-update-script

# Perform upgrade:
sudo ./update.sh --upgrade
```

The script shows a backup warning and asks for confirmation:

```
[WARNING] Create a backup before upgrading!
Do you want to perform the upgrade? [y/N]: y
[INFO] Starting upgrade to Ubuntu 24.04
[INFO] Distribution upgrade completed successfully
```

#### Supported Distribution Upgrades

- **Debian/Ubuntu**: Detects new release versions (e.g. Ubuntu 22.04 → 24.04)
- **Linux Mint**: Detects new Mint versions with mintupgrade
- **Fedora**: Detects new Fedora versions (e.g. Fedora 39 → 40)
- **Arch/Manjaro**: Checks for important updates (Rolling Release)
- **Solus**: Checks for pending updates (Rolling Release)

### Show Help

```bash
# Navigate to script directory:
cd ~/linux-update-script

# Show help:
sudo ./update.sh --help
```

### Automatic Updates via Cron

During installation, you can set up a cron job. The script automatically sets up the cron job in the **root crontab** (you will be asked for the sudo password once).

**Available options:**
- Daily at 3:00 AM
- Weekly (Sunday, 3:00 AM)
- Monthly (1st of month, 3:00 AM)
- Custom

**View root cron jobs:**
```bash
sudo crontab -l
```

**Edit root cron jobs:**
```bash
sudo crontab -e
```

## Multi-language Support

The script supports multiple languages. Language is automatically detected or can be configured manually.

### Available Languages

- **Deutsch** (de) - German
- **English** (en) - English

Additional languages can be contributed by the community! See `lang/README.md` for instructions.

### Set Language

**Option 1: Automatic Detection (Default)**

The script automatically detects the system language from the `LANG` environment variable.

**Option 2: Manual Setting**

In `config.conf`:
```bash
# Language (auto|de|en)
LANGUAGE=de     # German
LANGUAGE=en     # English
LANGUAGE=auto   # Automatic
```

**Option 3: Temporary for One Run**
```bash
LANGUAGE=en sudo ./update.sh
```

### Installation

During installation (`./install.sh`), you will be asked for your preferred language.

## Configuration

### Config File Location (NEW in v1.6.0)

**XDG-compliant since v1.6.0:**

The configuration file is now located by default in:

```bash
~/.config/linux-update-script/config.conf
```

**Advantages:**
- ✅ **Config persists** during script updates (git pull)
- ✅ **Linux standard compliant** (XDG Base Directory Specification)
- ✅ **Multi-user capable** (each user has their own config)
- ✅ **Clean separation** of code and configuration

**Automatic Migration:**

On first run after updating to v1.6.0, the old config is automatically migrated:

```bash
sudo ./update.sh
# [INFO] Migrating configuration to ~/.config/ (XDG standard)
# [INFO] Configuration successfully migrated to: ~/.config/linux-update-script/config.conf
# [INFO] Old configuration backed up as: config.conf.migrated
```

**Config Paths (Fallback Order):**

1. `~/.config/linux-update-script/config.conf` (preferred)
2. `/etc/linux-update-script/config.conf` (system-wide)
3. `./config.conf` (deprecated, will be removed in v2.0.0)

### Config Options

The configuration file `config.conf` contains the following options:

```bash
# Language (auto|de|en)
LANGUAGE=auto

# Enable email notifications (true/false)
ENABLE_EMAIL=false

# Email recipient
EMAIL_RECIPIENT="admin@domain.com"

# Log directory
LOG_DIR="/var/log/system-updates"

# Automatic reboot if required (true/false)
AUTO_REBOOT=false

# Kernel protection (true/false)
# Prevents autoremove when too few kernels are installed
KERNEL_PROTECTION=true

# Minimum number of stable kernels (default: 3)
MIN_KERNELS=3

# Enable upgrade check (true/false)
# Checks for distribution upgrades after regular updates
ENABLE_UPGRADE_CHECK=true

# Perform automatic upgrade (true/false)
# WARNING: Can cause breaking changes! Only for experienced users
AUTO_UPGRADE=false

# Upgrade notifications via email (true/false)
UPGRADE_NOTIFY_EMAIL=true

# Enable desktop notifications (true/false)
ENABLE_DESKTOP_NOTIFICATION=true

# Notification duration in milliseconds
NOTIFICATION_TIMEOUT=5000
```

### Change Configuration

**Option 1: Run Installation Script Again**
```bash
./install.sh
```

**Option 2: Manually Edit Config File**

From v1.6.0 (XDG-compliant):
```bash
nano ~/.config/linux-update-script/config.conf
```

Before v1.6.0 (deprecated):
```bash
cd ~/linux-update-script
nano config.conf
```

**Note:** After editing the config, no restart is needed - changes will be applied on the next script run.

## Email Notifications

### Overview: Local vs. External

There are **two different types** of email notifications:

| Type | Recipient | Usage | Configuration Effort |
|------|-----------|-------|---------------------|
| **Local** | `nicole`, `root` | Mails stay on the system | ⭐ Minimal (recommended!) |
| **External** | `user@gmail.com` | Mails go out to the internet | ⚙️ Complex (SMTP required) |

**Recommendation for beginners:** Start with **local mails** - simpler, works immediately!

---

## 📬 Local Email Notifications (Recommended)

### What are Local Mails?

Local mails are **not sent to the internet**, but land directly in your **mailbox on the system**.

✅ **Advantages:**
- No external SMTP configuration needed
- Works immediately after installation
- Perfect for system notifications
- No spam problems
- No internet connection required

### Step 1: Installation (automatic via install.sh)

```bash
./install.sh

# At the question:
Email address or username [your-username]: your-username ← Just username!
# Example: If you're logged in as "max" → max
```

This automatically installs:
- ✅ **mailutils** (provides the `mail` command)
- ✅ **DMA** (DragonFly Mail Agent - lightweight MTA)

### Step 2: Reading Local Mails

**Option 1: mail Command (recommended)**

```bash
# Open mailbox
mail

# Output:
# Mail version 8.1.2 01/15/2001.  Type ? for help.
# "/var/mail/max": 3 messages 2 new
# >N  1 max@hostname      Sat Jan 25 10:30  23/699   Linux Update Script - Test
#  N  2 max@hostname      Sat Jan 25 11:15  18/543   System Update Successful
#    3 max@hostname      Sat Jan 25 12:00  21/612   System Update FAILED
```

**Important commands in mail program:**

```bash
# Read first mail
& 1

# Next mail
& n

# Delete mail
& d 1

# Delete multiple mails
& d 1-5

# Delete all mails
& d *

# Exit
& q
```

**Option 2: Look Directly in Mailbox File**

```bash
# Show mailbox (replace $USER with your username)
cat /var/mail/$USER

# Or with pager (scrollable)
less /var/mail/$USER

# Show newest mails
tail -50 /var/mail/$USER
```

**Option 3: Empty Mailbox Completely**

```bash
# Delete all mails (replace $USER with your username)
> /var/mail/$USER

# OR
sudo rm /var/mail/$USER
```

**Option 4: Graphical Mail Client (for desktop users)**

💡 **Recommendation:** For occasional reading, the **`mail` command** (Option 1) is easiest!

If you still want a GUI:

**Thunderbird with ImportExportTools NG:**

```bash
# 1. Install Thunderbird
sudo apt-get install thunderbird
thunderbird
```

**In Thunderbird:**

1. **Install Add-on:**
   - **Menu** (☰) → **Add-ons and Themes**
   - Search: **ImportExportTools NG**
   - **Add to Thunderbird** → Install
   - Restart Thunderbird

2. **Import Mails:**
   - **Right-click** on **Local Folders** (left sidebar)
   - **ImportExportTools NG** → **Import mbox file**
   - Choose file: `/var/mail/$USER` (e.g. `/var/mail/max`)
   - **OK** → Mails are imported! ✓

3. **Automatic Updates (optional):**
   - **Right-click** on the imported folder
   - **ImportExportTools NG** → **Schedule automatic import**
   - Choose `/var/mail/$USER`
   - Interval: e.g. every 5 minutes

**Other Clients:**

**Mutt** (Terminal with better UI than `mail`):
```bash
sudo apt-get install mutt
mutt  # Automatically reads /var/mail/$USER
```

**Evolution** (GNOME), **KMail** (KDE):
Also support local mbox files, but setup is more complex.

**Advantages of graphical clients:**
- Clear GUI
- Search function, sorting
- Manage multiple mails simultaneously

**Disadvantages:**
- Setup required
- Additional software
- Overkill for occasional system mails

💡 **Our tip:** Start with `mail` - if that's not enough, try **Mutt** (terminal with GUI feeling) or **Thunderbird** (full GUI).

### Step 3: Send Test Mail

```bash
# Simple test mail to yourself
echo "This is a test" | mail -s "Test Subject" $USER

# With multi-line text
mail -s "Multi-line Test" $USER << EOF
Line 1
Line 2
Line 3
EOF

# Read mail
mail
```

### Troubleshooting: Local Mails

**Problem: Mails not arriving**

```bash
# 1. Check if mailutils is installed
command -v mail && echo "✓ mail available" || echo "✗ mail missing"

# 2. Check if DMA is installed
dpkg -l | grep dma

# 3. Check DMA queue (pending mails)
sudo mailq

# 4. Check DMA logs
sudo journalctl -u dma -n 50
```

**Problem: Bounce Mails (Delivery Errors)**

If you accidentally used external addresses:

```bash
# Empty queue (delete all pending mails)
sudo rm -rf /var/spool/dma/*

# Delete bounces from mailbox
mail
& d *  # Delete all
& q

# Correct config
nano ~/.config/linux-update-script/config.conf
# EMAIL_RECIPIENT="your-username"  ← Your local username!
```

---

## 🌐 External Email Notifications (Advanced)

If you want to send mails to **external addresses** (Gmail, Outlook, etc.).

⚠️ **Warning:** Much more complex! Only if you really need external mails.

### Prerequisites

1. **Valid SMTP server** (Gmail, Posteo, your provider)
2. **App password** (for Gmail, Outlook) NOT your regular password!
3. **SMTP credentials** (Server, Port, Username, Password)

### Option 1: DMA with SMTP (for advanced users)

```bash
# 1. Edit DMA config
sudo nano /etc/dma/dma.conf
```

For **Gmail** for example:

```bash
# SMTP Server
SMARTHOST smtp.gmail.com
PORT 587

# Authentication
AUTHPATH /etc/dma/auth.conf
SECURETRANSFER
STARTTLS

# Sender domain
MAILNAME gmail.com
```

```bash
# 2. Save credentials
sudo nano /etc/dma/auth.conf
```

Content:
```
your@gmail.com|smtp.gmail.com:your-app-password
```

```bash
# 3. Set permissions
sudo chmod 640 /etc/dma/auth.conf
sudo chown root:mail /etc/dma/auth.conf

# 4. Set mailname
echo "gmail.com" | sudo tee /etc/mailname
```

**Create Gmail App Password:**
1. Google Account → Security
2. Enable 2-Factor Authentication
3. App Passwords → Generate new password
4. Enter password in `/etc/dma/auth.conf`

### Option 2: ssmtp with SMTP (Alternative)

```bash
# 1. Install ssmtp
sudo apt-get install ssmtp

# 2. Configuration
sudo nano /etc/ssmtp/ssmtp.conf
```

For **Gmail**:
```bash
root=your@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=your@gmail.com
AuthPass=your-app-password
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
```

### Test External Mails

```bash
# Test mail to external address
echo "Test from $(hostname)" | mail -s "External Test" your@gmail.com

# Check queue (if mail is waiting)
sudo mailq

# Check logs
sudo tail -f /var/log/mail.log
```

### Troubleshooting: External Mails

**Problem: "Invalid HELO" or "550 Rejected"**

```bash
# MAILNAME must be valid domain!
sudo nano /etc/dma/dma.conf
# MAILNAME gmail.com  ← NOT "hostname.localdomain"!

echo "gmail.com" | sudo tee /etc/mailname
```

**Problem: "Authentication failed"**

```bash
# Check app password (NOT regular password!)
sudo cat /etc/dma/auth.conf

# Format must be:
# user@gmail.com|smtp.gmail.com:16-digit-app-password
```

**Problem: Mails Stuck in Queue**

```bash
# Show queue
sudo mailq

# Process queue manually (DMA)
sudo dma -q

# Or empty queue completely (WARNING: deletes all pending mails!)
sudo rm -rf /var/spool/dma/*
```

---

## 📋 Summary: What Should I Use?

### For regular home users:
```
✅ Local mails (your-username, root)
✅ mailutils + DMA
✅ No SMTP configuration needed
✅ Read mails with "mail"
```

### For advanced users with external mails:
```
⚙️ External mails (user@gmail.com)
⚙️ DMA or ssmtp with SMTP
⚙️ Set up app passwords
⚙️ Configure MAILNAME
```

### Quick-Start for Beginners:

```bash
# 1. Installation
./install.sh
# For email: Enter your username (e.g. max, anna, peter)
# Tip: Current username is automatically suggested!

# 2. Send test mail (replace with your username)
echo "Test" | mail -s "Test" $USER

# 3. Read mails
mail

# Done! ✓
```

## Desktop Notifications

**NEW in v1.5.1:** The script shows popup notifications for important events!

### Features

Desktop notifications are displayed for:
- ✅ **Update successful**: Green notice after completed update
- ✅ **Upgrade available**: Info about new distribution version
- ✅ **Update failed**: Critical warning on error
- ✅ **Reboot required**: Notice when reboot is needed

### Prerequisites

```bash
# Debian/Ubuntu/Mint
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify

# Arch Linux
sudo pacman -S libnotify

# openSUSE
sudo zypper install libnotify-tools
```

### Supported Desktop Environments

- GNOME
- KDE Plasma
- XFCE
- Cinnamon
- MATE
- LXQt
- Budgie

### Configuration

```bash
# In config.conf

# Enable desktop notifications
ENABLE_DESKTOP_NOTIFICATION=true

# Notification duration (milliseconds)
NOTIFICATION_TIMEOUT=5000
```

**Note:** Works automatically even when script is run as `sudo` - notifications are shown for the actual user.

## Logging

All updates are saved in log files with timestamps:

```
/var/log/system-updates/update_YYYY-MM-DD_HH-MM-SS.log
```

### View Logs

**Interactive Log Viewer (recommended):**

```bash
# Navigate to script directory:
cd ~/linux-update-script

# Start log viewer:
./log-viewer.sh
```

The log viewer offers the following options:
1. Show entire latest log file
2. Last 50 lines of newest log
3. List all log files
4. Search for errors in logs
5. Exit

**Manual Log Display:**

Show entire latest log file:
```bash
cat /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)
```

Last 50 lines:
```bash
tail -n 50 /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)
```

List all log files:
```bash
ls -lth /var/log/system-updates/
```

## Troubleshooting

### Problem: "Permission denied"

**Solution:** Script must be run as root
```bash
sudo ./update.sh
```

### Problem: "Cannot detect distribution"

**Solution:** Check if `/etc/os-release` exists
```bash
cat /etc/os-release
```

### Problem: Email Not Sent

**Error message: "Cannot start /usr/sbin/sendmail"**

This means no MTA (Mail Transfer Agent) is installed.

**Solution:**
```bash
# Option 1: Simple MTA (ssmtp for Gmail, etc.)
sudo apt install ssmtp
sudo nano /etc/ssmtp/ssmtp.conf

# Option 2: Full-featured MTA
sudo apt install postfix
# During installation: Select "Internet Site"
```

**Checks:**
1. Is `mailutils` or `mailx` installed?
   ```bash
   which mail
   which sendmail
   ```

2. Is an MTA installed?
   ```bash
   systemctl status postfix
   # or
   dpkg -l | grep ssmtp
   ```

3. Is the email address correct in `config.conf`?
   ```bash
   cat config.conf | grep EMAIL
   ```

4. Is email enabled?
   ```bash
   cat config.conf | grep ENABLE_EMAIL
   ```

5. Send test email:
   ```bash
   echo "Test" | mail -s "Test" your@email.com
   # Check /var/log/mail.log for errors
   ```

### Problem: Cannot Create Log Directory

**Solution:** Run script as root the first time
```bash
sudo ./update.sh
```

Or manually create log directory:
```bash
sudo mkdir -p /var/log/system-updates
sudo chown $USER:$USER /var/log/system-updates
```

### Problem: Cron Job Not Working

**Checks:**

1. Is the cron job correctly entered?
   ```bash
   crontab -l
   ```

2. Check cron logs:
   ```bash
   tail -f /var/log/cron.log
   # or
   tail -f /var/log/system-updates/cron.log
   ```

3. Specify script path absolutely:
   ```bash
   # Example for home directory installation:
   0 3 * * * /home/USERNAME/linux-update-script/update.sh

   # Example for /opt installation:
   0 3 * * * /opt/linux-update-script/update.sh
   ```

   **Note:** Replace `USERNAME` with your actual username or use the absolute path to your installation.

## Script Updates

The update script itself can be updated to new versions. The method depends on how you installed it.

### Update with Git (if installed with `git clone`)

**Advantage:** Simplest update procedure, config is automatically preserved

```bash
# Navigate to script directory
cd ~/linux-update-script

# Or for /opt installation:
cd /opt/linux-update-script

# Get latest version
git pull

# On first run after update to v1.6.0+, config is automatically migrated
sudo ./update.sh
```

**Your config is preserved!** Since v1.6.0, the config is in `~/.config/linux-update-script/` and is not overwritten by `git pull`.

### Update without Git (for ZIP installation)

If you downloaded the script as a ZIP:

```bash
# IMPORTANT: First back up config (only needed for v1.5.1 or earlier)
# Since v1.6.0, config is in ~/.config/ and doesn't need to be backed up
cp ~/linux-update-script/config.conf ~/config.conf.backup 2>/dev/null || true

# Delete old version
rm -rf ~/linux-update-script

# Download new version
cd ~
wget https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip
unzip main.zip
mv Automatisiertes-Update-Script-fuer-Linux-main linux-update-script

# Restore old config (only for v1.5.1 or earlier)
# Since v1.6.0, config is in ~/.config/ and is automatically found
if [ -f ~/config.conf.backup ]; then
    cp ~/config.conf.backup ~/linux-update-script/config.conf
    rm ~/config.conf.backup
fi

# Clean up
rm main.zip
```

**Tip:** For regular updates, the Git method is much easier!

### Check Which Installation Method You're Using

```bash
cd ~/linux-update-script

# If this command shows a Git repository, you installed with git clone:
git status

# If error "not a git repository", you used ZIP download
```

### Check Current Version

The version is displayed in the script or can be checked in the files:

```bash
# In CHANGELOG.md (first lines)
head -20 ~/linux-update-script/CHANGELOG.md | grep "##"
```

## Kernel Protection

**NEW in v1.5.0:** The script automatically protects against accidental removal of fallback kernels.

### How It Works

- Counts installed stable kernel versions before `autoremove`
- Skips `autoremove` if fewer than `MIN_KERNELS` are present
- Default: At least 3 kernels (currently running + 2 fallback versions)
- Supports Debian/Ubuntu and RHEL/Fedora

### Example

```bash
sudo ./update.sh
# [INFO] Checking installed kernel versions
# [INFO] Found: 5 stable kernel versions
# [INFO] Currently running: 6.5.0-28-generic
# [INFO] Sufficient kernels available, running autoremove
```

When too few kernels are present:

```bash
# [WARNING] Only 2 kernels found, skipping autoremove for safety
# [INFO] Minimum required: 3 stable kernels (current + fallbacks)
# [INFO] Kernel protection active: At least 2 stable kernels will be kept
```

### Configuration

```bash
# Disable kernel protection (not recommended)
KERNEL_PROTECTION=false

# Change minimum number
MIN_KERNELS=5  # Keeps more fallback kernels
```

## NVIDIA-Kernel Compatibility Check

**NEW in v1.6.0:** The script automatically checks NVIDIA driver compatibility BEFORE kernel updates!

### Problem

Proprietary NVIDIA drivers must be recompiled after kernel updates (DKMS). Without working drivers, the system may not start properly after reboot:
- Black screen
- No X11/Wayland
- System boots to text mode

### Solution

The script checks **before the update**:
1. If NVIDIA drivers are installed
2. Which kernel is available in the update
3. If DKMS modules exist for the new kernel
4. Offers automatic DKMS rebuild

### How It Works

```bash
sudo ./update.sh

# [INFO] NVIDIA driver detected: 535.129.03
# [INFO] Checking NVIDIA driver compatibility
# [INFO] Kernel update available: 6.5.0-35-generic
# [INFO] Checking DKMS status for kernel 6.5.0-35-generic
```

**If DKMS modules are missing:**

```bash
# [WARNING] DKMS modules need to be rebuilt for new kernel
# Do you want to rebuild DKMS modules now? [y/N]: y
# [INFO] Running DKMS autoinstall...
# [INFO] DKMS modules successfully rebuilt
```

**If DKMS rebuild fails:**

```bash
# [ERROR] Error rebuilding DKMS modules
# [WARNING] Continue with update anyway? [y/N]: n
# [INFO] Update cancelled - please update NVIDIA driver
```

### Automatic DKMS Rebuild

For servers/automated environments, you can automate the rebuild:

```bash
# In config.conf:
NVIDIA_AUTO_DKMS_REBUILD=true
```

The script then runs `dkms autoinstall` automatically, without asking.

### Secure Boot Support

When **Secure Boot** is active, NVIDIA modules must be signed after DKMS build:

```bash
# [INFO] Secure Boot is active
# [INFO] Checking MOK (Machine Owner Key) status
# [INFO] MOK key found
# [INFO] Signing NVIDIA modules with MOK
# [INFO] Modules successfully signed
```

**Enroll MOK keys** (required once):

```bash
# Generate MOK key (if not present)
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der

# On next reboot: Use MOK Management Utility
# Enter password and enroll key
```

**Automatic signing:**

```bash
# In config.conf:
NVIDIA_AUTO_MOK_SIGN=true
```

### Kernel Hold on Incompatibility (NEW!)

**Problem:** NVIDIA sometimes doesn't support new kernel versions yet.

**Default behavior (safe mode):**

The script tests DKMS build **before** the update. On incompatibility:

```bash
# [WARNING] NVIDIA driver 535.129.03 doesn't support kernel 6.8.0-40 yet
# [WARNING] Kernel update will be held back (safe mode)
# [INFO] Kernel successfully held: linux-image-generic
# [INFO] Kernel will NOT be updated until NVIDIA driver is ready
# [INFO] Release later with: sudo apt-mark unhold linux-image-generic
```

The update **continues** and installs all other packages - only the kernel is skipped!

**Release kernel later:**

```bash
# Debian/Ubuntu
sudo apt-mark unhold linux-image-generic linux-headers-generic

# RHEL/Fedora
sudo dnf versionlock delete kernel kernel-core kernel-modules

# openSUSE
sudo zypper removelock kernel-default

# Arch (manual /etc/pacman.conf editing)
# Remove: IgnorePkg = linux linux-headers
```

### Power-User Mode (⚠️ Risky!)

For **experienced users** who want to try an update despite officially unsupported kernel:

```bash
# In config.conf:
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=true
```

**Warning during update:**

```bash
# [WARNING] Power-user mode: Attempting update despite warning
# [WARNING] WARNING: Risk of instability or black screen
# Do you want to rebuild DKMS modules now? [y/N]: y
```

**⚠️ Risks:**
- System won't boot anymore (black screen)
- No GUI, only text mode
- NVIDIA features don't work
- Instability and crashes

**Recommendation:** Only enable if you know what you're doing and have fallback kernels available!

### Configuration (Overview)

```bash
# Completely disable NVIDIA check (not recommended)
NVIDIA_CHECK_DISABLED=true

# Automatic DKMS rebuild without asking
NVIDIA_AUTO_DKMS_REBUILD=true

# Power-user mode: Allow unsupported kernels (risky!)
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=false  # Default: false = safe

# Automatic MOK signing for Secure Boot
NVIDIA_AUTO_MOK_SIGN=false
```

### Prerequisites

For automatic DKMS rebuild:
```bash
# Debian/Ubuntu
sudo apt-get install dkms

# RHEL/Fedora
sudo dnf install dkms

# Arch Linux
sudo pacman -S dkms
```

### Supported Distributions

The NVIDIA check works on **all supported distributions**:
- ✅ Debian/Ubuntu/Mint (apt-cache)
- ✅ RHEL/Fedora/CentOS/Rocky/AlmaLinux (dnf/yum)
- ✅ Arch Linux/Manjaro/EndeavourOS/Garuda/ArcoLinux (pacman)
- ✅ openSUSE/SLES (zypper)
- ✅ Solus (eopkg)
- ✅ Void Linux (xbps-query)

### Manual DKMS Rebuild

If you want to rebuild DKMS manually:

```bash
# For all NVIDIA modules
sudo dkms autoinstall

# For specific kernel
sudo dkms autoinstall -k 6.5.0-35-generic
```

## Security Notes

- The script requires root privileges for system updates
- **Backup recommended** before distribution upgrades
- Configuration file contains no sensitive data
- Email passwords are not stored in the script
- Logs may contain sensitive system information
- Kernel protection prevents boot problems from missing fallback kernels

## Uninstallation

### Remove Cron Job

```bash
crontab -e
# Delete line with update.sh
```

### Remove Files

**For home directory installation:**
```bash
rm -rf ~/linux-update-script
sudo rm -rf /var/log/system-updates
```

**For /opt installation:**
```bash
sudo rm -rf /opt/linux-update-script
sudo rm -rf /var/log/system-updates
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Support

For problems or questions:
1. Check the log files
2. Verify the configuration
3. Ensure all prerequisites are met

## Changelog

The complete version history can be found in the [CHANGELOG.md](CHANGELOG.md) file.

### Current Version: 1.6.0 (2026-01-25) - XDG Compliance & NVIDIA Secure Boot

**Highlights:**
- ✅ **NEW: XDG Compliance** - Config files now in standard directory
- ✅ **NEW: NVIDIA Secure Boot Support** - MOK signing for NVIDIA drivers
- ✅ **NEW: Kernel Hold Mechanism** - Safe defaults for NVIDIA incompatibility
- ✅ **NEW: User-Friendly Defaults** - Automatic installation, better defaults
- ✅ **NEW: Comprehensive Documentation** - Email setup explained for beginners
- ✅ Desktop Notifications (v1.5.1)
- ✅ Upgrade Check System (v1.5.0)
- ✅ Kernel Protection (v1.5.0)
- ✅ ShellCheck-compliant (zero warnings)

**Version 1.5.1:**
- ✅ Desktop Notifications
- ✅ DMA Recommendation

**Version 1.4.0:**
- ✅ ShellCheck warnings fixed
- ✅ Code quality improved

**Version 1.3.0:**
- ✅ Solus support (Community contribution by @mrtoadie)
- ✅ Void Linux support (Community contribution by @tbreswald)
- ✅ GitHub repository professionally set up

**See [CHANGELOG.md](CHANGELOG.md) for all details**
