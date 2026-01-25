# Release Notes - Automatisiertes Linux Update-Script

**Aktuelle Version:** v1.6.1 (2026-01-25)

---

## 🔥 Neueste Version: v1.6.1 - Bugfixes & Hybrid-Config

**Release-Datum:** 2026-01-25

### Highlights

Dies ist ein **kritisches Bugfix-Release**:

1. 🔧 **AUTO_REBOOT Fix** - Funktioniert endlich korrekt!
2. 🐧 **Linux Mint Upgrade Support** - mintupgrade Workflow
3. ✅ **Dry-Run für alle Distributionen** - Sicheres Upgrading
4. 🔀 **Hybrid-Config System** - Cron-sicher, Multi-User-fähig

### Kritische Bugfixes

- **AUTO_REBOOT:** Config wurde nicht geladen → Hybrid-Config System implementiert
- **Linux Mint:** mintupgrade 4-Schritt-Workflow (check → dry-run → download → upgrade)
- **Dry-Run:** Alle Distributionen prüfen jetzt Konflikte vor Upgrades

### Hybrid-Config System

**Neue Config-Struktur:**
```
/etc/linux-update-script/config.conf       → System (Cron)
~/.config/linux-update-script/config.conf  → User Override
```

**Vorteile:**
- ✅ Cron-sicher (funktioniert ohne $SUDO_USER)
- ✅ Multi-User (jeder eigene Präferenzen)
- ✅ Power-User (persönliche Overrides)

👉 **[Vollständige Release Notes v1.6.1](RELEASE_NOTES_v1.6.1.md)**

---

## 📦 Alle Versionen

### [v1.6.1](RELEASE_NOTES_v1.6.1.md) - Bugfixes & Hybrid-Config (2026-01-25)
- 🔧 AUTO_REBOOT Fix
- 🐧 Linux Mint Upgrade Support
- 🔀 Hybrid-Config System
- ✅ Dry-Run für alle Distributionen

### [v1.6.0](RELEASE_NOTES_v1.6.0.md) - XDG-Konformität & NVIDIA Secure Boot (2026-01-25)
- ✅ XDG Base Directory Specification
- 🔒 NVIDIA Secure Boot Support (MOK-Signierung)
- 🛡️ Kernel-Hold-Mechanismus
- 🎯 Benutzerfreundliche Defaults

### [v1.5.1](RELEASE_NOTES_v1.5.1.md) - Desktop-Benachrichtigungen & DMA (2025-12-27)
- 🔔 Desktop-Benachrichtigungen mit notify-send
- 📧 DMA als empfohlene MTA-Lösung
- ⚙️ SUDO_USER Handling für Notifications

### [v1.5.0](RELEASE_NOTES_v1.5.0.md) - Upgrade-Check System (2025-12-27)
- 📈 Distribution-Upgrade Erkennung
- 🔄 Automatische Benachrichtigungen
- 🎯 Unterstützung für 6 Distributionsfamilien

### v1.4.0 - Mehrsprachigkeit (2025-12-24)
- 🌍 Vollständige i18n (Deutsch/Englisch)
- ✅ ShellCheck-Warnungen behoben
- 📝 Sprachdateien für Community

---

## 🚀 Installation

### Neu-Installation

```bash
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git
cd Automatisiertes-Update-Script-fuer-Linux
sudo ./install.sh
```

### Update von bestehender Installation

```bash
cd ~/linux-update-script  # oder wo auch immer installiert
git pull origin main
sudo ./install.sh  # Config neu erstellen (empfohlen für v1.6.1!)
```

**Wichtig für v1.6.1:**
- install.sh erstellt automatisch `/etc/linux-update-script/config.conf`
- Alte Configs werden automatisch migriert
- Optional: User-Override in `~/.config/linux-update-script/config.conf`

---

## 🐛 Bekannte Issues

Keine bekannten kritischen Issues in v1.6.1.

**Probleme melden:**
- [GitHub Issues](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)

---

## 📚 Dokumentation

- **[README.md](README.md)** - Vollständige Dokumentation
- **[CHANGELOG.md](CHANGELOG.md)** - Detaillierte Änderungshistorie
- **[ROADMAP.md](ROADMAP.md)** - Geplante Features
- **[lang/README.md](lang/README.md)** - Übersetzungsanleitung

---

## 🌍 Unterstützte Distributionen

**6 Distributionsfamilien:**

- **Debian-Familie:** Debian, Ubuntu, Linux Mint, Pop!_OS
- **RedHat-Familie:** RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-Familie:** openSUSE (Leap/Tumbleweed), SLES
- **Arch-Familie:** Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus:** Solus
- **Void Linux:** Void Linux

---

## 🎯 Features

- ✅ Automatische Updates für alle gängigen Linux-Distributionen
- ✅ E-Mail-Benachrichtigungen (DMA/ssmtp/postfix)
- ✅ Desktop-Benachrichtigungen (notify-send)
- ✅ Kernel-Schutz (verhindert Entfernen von Fallback-Kerneln)
- ✅ NVIDIA-Kompatibilitätsprüfung (inkl. Secure Boot)
- ✅ Distribution-Upgrade Check & Durchführung
- ✅ Hybrid-Config System (Cron + Multi-User)
- ✅ Mehrsprachigkeit (Deutsch/Englisch)
- ✅ Cron-Job Integration
- ✅ Umfangreiches Logging

---

## 🔮 Roadmap

### v1.7.0 - Hooks & Automation (geplant)
- Pre/Post-Update Hooks
- Custom Scripts vor/nach Updates
- Service-Management

### v1.8.0 - Backup & Optimierung (geplant)
- Automatische Snapshots (LVM/Btrfs/ZFS)
- Backup-Integration
- Low-Load-Detection

### v2.0.0 - Major Refactoring (geplant)
- Modulare Architektur
- Test-Framework (bats-core)
- Container-Support
- Multi-System Management

Siehe **[ROADMAP.md](ROADMAP.md)** für Details.

---

## 🤝 Contributing

Wir freuen uns über Beiträge!

- **Bugs melden:** [GitHub Issues](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)
- **Neue Sprachen:** Siehe [lang/README.md](lang/README.md)
- **Code beitragen:** [Contributing Guide](CONTRIBUTING.md)
- **Feedback geben:** Issues oder Pull Requests

---

## 📝 Lizenz

**MIT License**

Copyright (c) 2025-2026 nicolettas-muggelbude

Siehe [LICENSE](LICENSE) für Details.

---

## 🔗 Links

- [GitHub Repository](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux)
- [Issues](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)
- [Pull Requests](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/pulls)
- [Releases](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases)

---

**Viel Erfolg mit dem automatisierten Update-Script!** 🚀

*Letzte Aktualisierung: 2026-01-25*

