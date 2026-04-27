# Update-Script Projekt - Claude Kontext

## Projekt-Übersicht
Linux System Update-Script mit Unterstützung für mehrere Distributionen (Debian, Ubuntu, RHEL, Fedora, SUSE, Solus, Arch, Void).

## Aktuelle Version
v1.9.1 - fwupd & Bugfixes (Released: 2026-04-27)

## Vorherige Versionen
- v1.9.0 - Netzwerk & Fortschritt (Released: 2026-04-18)
- v1.8.0 - Backup & Optimierung (Released: 2026-04-04)
- v1.7.0 - Hooks & Automation (Released: 2026-03-13)
- v1.6.0 - XDG-Konformität, Config-Migration & NVIDIA Secure Boot (Released: 2026-01-25)
- v1.5.1 - Desktop-Benachrichtigungen & DMA (Released: 2025-12-27)
- v1.5.0 - Upgrade-Check System (Released: 2025-12-27)
- v1.4.0 - ShellCheck-Warnungen behoben, Kernel-Schutz implementiert

## Nächste Version
v2.0.0 - Major Refactoring & Enterprise Features (geplant)

## Projekt-Struktur
```
Update-Script/
├── update.sh              # Hauptscript
├── config.conf            # Konfigurationsdatei
├── lang/                  # Sprachdateien
│   ├── de.lang           # Deutsch
│   └── en.lang           # Englisch
├── ROADMAP.md            # Feature-Planung
├── README.md             # Dokumentation
├── CHANGELOG.md          # Versionshistorie
└── .github/              # GitHub Templates & Workflows
```

## Wichtige Funktionen

### Kernel-Schutz (v1.5.0)
- Verhindert versehentliches Entfernen von Fallback-Kerneln
- Konfigurierbar über `KERNEL_PROTECTION` und `MIN_KERNELS`
- Unterstützt Debian/Ubuntu und RHEL/Fedora
- Implementiert in `safe_autoremove()` Funktion

### Mehrsprachigkeit
- Automatische Sprach-Erkennung basierend auf System-Locale
- Sprachdateien in `lang/` Verzeichnis
- Neue Sprachmeldungen müssen in alle `.lang` Dateien eingefügt werden

### E-Mail-Benachrichtigungen
- Optional über `ENABLE_EMAIL` in config.conf
- Unterstützt `mail` und `sendmail`
- Wird bei Erfolg, Fehler und Neustart-Anforderung gesendet

## Entwicklungs-Richtlinien

### Code-Stil
- ShellCheck-konform (keine Warnungen)
- Funktionen mit sprechenden Namen
- Farbige Ausgabe für bessere UX
- Logging in `/var/log/system-updates/`

### Git-Workflow
- `main` Branch für stabile Releases
- Feature-Branches für neue Funktionen
- Semantic Versioning (MAJOR.MINOR.PATCH)
- Detaillierte Commit-Messages

### Testing
- Manuelle Tests auf verschiedenen Distributionen
- ShellCheck für statische Code-Analyse
- GitHub Actions für automatisierte Checks

## Implementierte Features (v1.5.0)

### Upgrade-Check System
**Status:** ✅ Implementiert (Released: 2025-12-27)

**Features:**
1. ✅ Erkennung verfügbarer Distribution-Upgrades
2. ✅ Automatische Benachrichtigung an User
3. ✅ Optionales automatisches Upgrade
4. ✅ Unterstützung für Solus, Arch, Debian/Ubuntu, Fedora

**Technische Umsetzung:**
- `check_upgrade_available()` - Framework-Funktion
- `check_upgrade_solus()` - Solus-spezifischer Check
- `check_upgrade_arch()` - Arch-spezifischer Check
- `check_upgrade_debian()` - Debian/Ubuntu Release-Check
- `check_upgrade_fedora()` - Fedora Version-Check
- Command-Line Parameter: `--upgrade`
- Config-Parameter: `ENABLE_UPGRADE_CHECK`, `AUTO_UPGRADE`, `UPGRADE_NOTIFY_EMAIL`

## Implementierte Features (v1.5.1)

### Desktop-Benachrichtigungen
**Status:** ✅ Implementiert (Released: 2025-12-27)

**Features:**
1. ✅ Desktop-Notifications mit notify-send
2. ✅ Notifications bei Erfolg, Upgrade verfügbar, Fehler, Neustart
3. ✅ Automatische root-to-user Notification (SUDO_USER Handling)
4. ✅ Unterstützung für alle Desktop-Umgebungen

**Technische Umsetzung:**
- `send_notification()` - Zentrale Notification-Funktion
- Automatisches DISPLAY=:0 und DBUS_SESSION_BUS_ADDRESS Setup
- Graceful Degradation wenn notify-send nicht verfügbar
- Config-Parameter: `ENABLE_DESKTOP_NOTIFICATION`, `NOTIFICATION_TIMEOUT`
- Icons: software-update-available, system-software-update, dialog-error, system-reboot

### DMA - Empfohlene MTA-Lösung
**Status:** ✅ Dokumentiert (Released: 2025-12-27)

**Community-Feedback implementiert:**
- DMA (DragonFly Mail Agent) als empfohlene Lösung für E-Mail-Benachrichtigungen
- Keine Konfiguration nötig
- Kein laufender Dienst, kein offener Port, keine Queue
- Perfekt für lokale Mails (cron, mail)
- Alternative Lösungen (ssmtp, postfix) weiterhin dokumentiert

## Implementierte Features (v1.6.0)

### XDG-Konformität & Config-Migration
**Status:** ✅ Implementiert (2026-01-24)

**Features:**
1. ✅ Config-Migration nach `~/.config/linux-update-script/`
2. ✅ Automatische Migration von alter Config
3. ✅ Backwards-kompatibel (Fallback-Mechanismus)
4. ✅ Community-Feedback implementiert (@tbreswald)

**Technische Umsetzung:**
- `migrate_config()` - Automatische Migration
- `find_config_file()` - Fallback XDG → System → Old
- XDG_CONFIG_HOME Support
- Backup der alten Config als `.migrated`

### NVIDIA-Kernel-Kompatibilitätsprüfung
**Status:** ✅ Vollständig implementiert (2026-01-25)

**Features:**
1. ✅ NVIDIA-Treiber-Erkennung (nvidia-smi, lsmod, lspci)
2. ✅ Pending-Kernel-Abfrage (alle 6 Distributionsfamilien)
3. ✅ DKMS-Status-Prüfung
4. ✅ Automatischer DKMS-Rebuild (optional)
5. ✅ **Secure Boot Support** (MOK-Signierung)
6. ✅ **Kernel-Hold-Mechanismus** (Sicherer Default)
7. ✅ **Power-User-Modus** (Opt-in, risikoreich)

**Secure Boot Features:**
- `is_secureboot_enabled()` - 3 Detection-Methoden (mokutil, bootctl, EFI vars)
- `check_mok_keys()` - MOK-Schlüssel-Prüfung
- `sign_nvidia_modules()` - Automatische Modul-Signierung
- `handle_secureboot_signing()` - Post-Build Secure Boot Handling
- Config: `NVIDIA_AUTO_MOK_SIGN` (default: false)

**Kernel-Hold Features:**
- Test DKMS-Build **VOR** Update
- Bei Inkompatibilität: Kernel automatisch zurückhalten
- Distribution-spezifische Hold-Befehle:
  * Debian/Ubuntu: `apt-mark hold`
  * RHEL/Fedora: `dnf versionlock`
  * openSUSE: `zypper addlock`
  * Arch: `pacman.conf IgnorePkg` (manuell)
  * Solus/Void: linux-lts empfohlen
- Rest des Systems wird normal aktualisiert
- Info wie Kernel später freigegeben werden kann

**Power-User-Modus:**
- Config: `NVIDIA_ALLOW_UNSUPPORTED_KERNEL=true`
- Erlaubt Updates trotz nicht unterstützter Kernel
- Explizite Risiko-Warnungen
- DKMS-Rebuild wird trotzdem versucht
- Für erfahrene Benutzer mit Fallback-Optionen

**Technische Umsetzung:**
- `is_nvidia_installed()` - NVIDIA-Treiber-Erkennung
- `get_pending_kernel_version()` - Pending Kernel (6 Distributionen)
- `check_nvidia_dkms_status()` - DKMS-Status
- `test_dkms_build()` - Pre-Build-Test
- `hold_kernel_update()` - Kernel zurückhalten
- `check_nvidia_compatibility()` - Hauptfunktion mit Safe/Power-User Modi

**Konfiguration:**
- `NVIDIA_CHECK_DISABLED` (default: false)
- `NVIDIA_AUTO_DKMS_REBUILD` (default: false)
- `NVIDIA_ALLOW_UNSUPPORTED_KERNEL` (default: false) - **NEU!**
- `NVIDIA_AUTO_MOK_SIGN` (default: false) - **NEU!**

**Sprachdateien:**
- +25 Nachrichten in lang/de.lang (Secure Boot, MOK, Kernel-Hold)
- +25 Nachrichten in lang/en.lang (Secure Boot, MOK, Kernel-Hold)
- Gesamt: 41 neue Sprachmeldungen für NVIDIA-Features

### Desktop-Benachrichtigungen in install.sh
**Status:** ✅ Implementiert (2026-01-24)

**Features:**
1. ✅ Interaktive Frage nach Desktop-Benachrichtigungen
2. ✅ Automatische libnotify-Erkennung
3. ✅ Installation-Angebot für alle 6 Distributionsfamilien
4. ✅ Config-Generation mit ENABLE_DESKTOP_NOTIFICATION

**Technische Umsetzung:**
- libnotify-Detection in install.sh
- Distribution-spezifische Installation:
  * Debian/Ubuntu: `libnotify-bin`
  * RHEL/Fedora: `libnotify`
  * Arch: `libnotify`
  * openSUSE: `libnotify-tools`
  * Solus: `libnotify`
  * Void: `libnotify`

## Wichtige Hinweise

### Sicherheit
- Immer Root-Rechte prüfen
- Backup-Warnungen vor kritischen Operationen
- Kernel-Schutz standardmäßig aktiviert
- Opt-in für automatische Upgrades

### Kompatibilität
- Unterstützte Distributionen in ROADMAP.md dokumentiert
- Distribution-Detection über `/etc/os-release`
- Fallback-Mechanismen für fehlende Tools

### Community
- Feature-Requests via GitHub Issues
- Priorisierung nach Community-Nachfrage
- Open-Source (MIT License)

## Aktueller Status

### v1.6.1 (In Entwicklung: 2026-01-25)
🔧 **Bugfixes & Hybrid-Config System**

**Kritische Bugfixes:**
1. ✅ **AUTO_REBOOT Fix** - Funktioniert jetzt korrekt
   - Problem: Config wurde nicht geladen (XDG-Pfad bei sudo falsch)
   - Lösung: Hybrid-Config System implementiert
   - Robuste Boolean-Prüfung: `[ "$AUTO_REBOOT" = "true" ] || [ "$AUTO_REBOOT" = true ]`

2. ✅ **Linux Mint Upgrade Support** - mintupgrade Workflow
   - Problem: Mint verwendet mintupgrade statt do-release-upgrade
   - Lösung: 4-Schritt-Workflow (check → --dry-run → download → upgrade)
   - Automatische mintupgrade Installation

3. ✅ **Dry-Run für alle Distributionen**
   - Mint: `mintupgrade --dry-run`
   - Debian/Ubuntu: `do-release-upgrade -c`
   - Fedora: `dnf system-upgrade download --assumeno`
   - openSUSE: `zypper dup --dry-run`

**Neue Features:**

#### Hybrid-Config System
**Problem gelöst:**
- Cron-Jobs: Keine $SUDO_USER Variable → Config nicht gefunden
- Multi-User: Verschiedene User-Präferenzen
- XDG-Standard vs. System-Kompatibilität

**Lösung: Hybrid-Ansatz**
```
1. System-Config:  /etc/linux-update-script/config.conf
   → Primär, funktioniert immer (auch Cron)

2. User-Override:  ~/.config/linux-update-script/config.conf
   → Optional, nur bei sudo-Aufruf

3. Legacy:         ./config.conf
   → Fallback, deprecated
```

**Technische Umsetzung:**
- `load_config()` - Hybrid-Loading mit System + User Override
- `getent passwd $SUDO_USER` - Ermittelt echtes User-Home
- Automatische Config-Migration in install.sh
- System-Config-Erstellung mit `sudo tee`

**Änderungen:**
- 2 Dateien geändert (update.sh, install.sh)
- +150 / -80 Zeilen
- 1 neue Funktion (`load_config()`)
- 20+ neue Sprachmeldungen (Mint Upgrade, Dry-Run)
- ShellCheck: 0 Fehler, 0 Warnungen

**Vorteile:**
✅ Cron-sicher (funktioniert ohne $SUDO_USER)
✅ Multi-User freundlich (jeder User eigene Präferenzen)
✅ Power-User freundlich (persönliche Overrides)
✅ Automatisch (install.sh macht alles)
✅ Abwärtskompatibel (Legacy-Config als Fallback)

**Testing:**
- ShellCheck: update.sh (0 Fehler), install.sh (0 Fehler)
- Config-Loading Logik getestet
- Hybrid-Pfade verifiziert
- Migration-Logik implementiert

**Status:** ✅ Implementiert, bereit zum Testen

### v1.6.0 (Released: 2026-01-25)
✅ **Vollständig implementiert und veröffentlicht**

**Änderungen:**
- 6 Dateien geändert
- +588 / -54 Zeilen
- 10 neue Funktionen (Secure Boot, Kernel-Hold, DKMS-Test)
- 4 neue Konfigurationsparameter
- 50 neue Sprachmeldungen (DE/EN)
- ShellCheck: 0 Warnungen

**Commits:**
- 9c92c40: XDG-Konformität & Config-Migration
- e07c8f6: Git-Installation-Dokumentation
- 2b83db3: Desktop-Notifications in install.sh
- 6ba412b: NVIDIA-Kernel-Kompatibilitätsprüfung
- be982f4: NVIDIA-Prüfung für alle 6 Distributionen
- 74dd97c: NVIDIA Secure Boot & Kernel-Hold-Mechanismus

**Release:**
- Git Tag: v1.6.0
- GitHub Release: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases/tag/v1.6.0
- Release Notes: RELEASE_NOTES_v1.6.0.md

### v1.5.1 (Released: 2025-12-27)
✅ **Vollständig implementiert und veröffentlicht**

**Änderungen:**
- 6 Dateien geändert
- +244 / -19 Zeilen
- 1 neue Funktion (`send_notification()`)
- 2 neue Konfigurationsparameter
- 8 neue Sprachmeldungen (DE/EN)
- ShellCheck: 0 Warnungen

**Release:**
- Git Tag: v1.5.1
- GitHub Release: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases/tag/v1.5.1
- Release Notes: RELEASE_NOTES_v1.5.1.md

### v1.5.0 (Released: 2025-12-27)
✅ **Upgrade-Check System vollständig implementiert**

**Neue Funktionen:**
- `check_upgrade_available()` - Hauptfunktion für Upgrade-Check
- `check_upgrade_solus()` - Solus-spezifischer Check
- `check_upgrade_arch()` - Arch-spezifischer Check
- `check_upgrade_debian()` - Debian/Ubuntu Release-Check
- `check_upgrade_fedora()` - Fedora Version-Check
- `perform_upgrade()` - Upgrade-Durchführung mit Bestätigung

**Command-Line Interface:**
- `--upgrade` - Führt Distribution-Upgrade durch
- `--help` / `-h` - Zeigt Hilfe an

**Konfiguration:**
- `ENABLE_UPGRADE_CHECK` (default: true)
- `AUTO_UPGRADE` (default: false)
- `UPGRADE_NOTIFY_EMAIL` (default: true)

**Rückgabewerte:**
- `0` - Kein Upgrade verfügbar
- `1` - Fehler oder nicht unterstützt
- `2` - Updates verfügbar (Rolling Release)
- `3` - Major-Upgrade verfügbar

## Roadmap - Geplante Versionen

### v1.6.0 - XDG-Konformität & Config-Migration
**Status:** ✅ In Entwicklung (2026-01-24)

**Implementierte Features:**

#### 1. XDG Base Directory Specification ✅
- Neue Config-Location: `~/.config/linux-update-script/config.conf`
- Respektiert `$XDG_CONFIG_HOME` Umgebungsvariable
- Config bleibt bei Script-Updates (git pull) erhalten
- Multi-User-fähig (jeder User eigene Config)
- System-weite Config: `/etc/linux-update-script/config.conf`

#### 2. Automatische Config-Migration ✅
- `migrate_config()` - Automatische Migration beim ersten Start
- Alte Config wird als `.migrated` Backup gesichert
- Vollständig backwards-kompatibel
- Keine manuellen Schritte nötig

#### 3. Fallback-Mechanismus ✅
- `find_config_file()` - Intelligente Config-Suche
- Reihenfolge: XDG → System → Alt (deprecated)
- Warnung bei Verwendung alter Location
- Info-Logging über verwendete Config

#### 4. install.sh Anpassungen ✅
- Erstellt Config direkt in `~/.config/linux-update-script/`
- Zeigt neuen Config-Pfad während Installation
- Bietet Migration alter Config an (falls vorhanden)
- `load_existing_config()` unterstützt alte und neue Location

#### 5. Mehrsprachigkeit ✅
- 8 neue Sprachmeldungen (DE/EN)
- MSG_CONFIG_MIGRATE_* - Migrations-Meldungen
- MSG_CONFIG_LOCATION - Info über verwendete Config
- MSG_CONFIG_OLD_DEPRECATED - Deprecation-Warnung

**Technische Details:**
- ShellCheck-konform (0 Warnungen)
- Keine Breaking Changes
- Community-Feedback: @tbreswald implementiert

**Deprecation Notice:**
- Alte Config-Location `./config.conf` ist deprecated
- Funktioniert weiterhin (Fallback)
- Wird in v2.0.0 entfernt

### v1.7.0 - Hooks & Automation
**Status:** 📋 Konzeptphase

**Fokus:**
- Pre-Update Hooks (Scripts vor Update ausführen)
- Post-Update Hooks (Scripts nach Update ausführen)
- Hook-Verzeichnisse: `/etc/update-hooks/pre.d/` und `/etc/update-hooks/post.d/`
- Exit-Code-Handling und Timeouts

**Use Cases:**
- Services vor Update stoppen
- Backups vor Update erstellen
- Monitoring pausieren
- Custom Cleanup nach Update

### v1.8.0 - Backup & Optimierung
**Status:** 📋 Konzeptphase

**Fokus:**
- Backup-Integration (LVM, Btrfs, ZFS, Rsync)
- Automatische Snapshots vor Distribution-Upgrades
- Backup-Rotation
- Update-Schedule (Low-Load-Detection)
- Bandwidth-Limit
- Progress-Anzeige

### v2.0.0 - Major Refactoring & Enterprise Features
**Status:** 📋 Konzeptphase

**Breaking Changes:** Major-Version mit Code-Architektur Refactoring

**Primär-Fokus: Code-Architektur**
- 🏗️ Modulare Struktur (lib/ Verzeichnis)
- 🏗️ Test-Framework (bats-core, >80% Coverage)
- 🏗️ Migration-Script für v1.x User
- 🏗️ CI/CD für automatische Tests

**Enterprise-Features:**
- Container-Support (Docker, LXC, Podman)
- Multi-System Management (SSH-basiert)
- Advanced Notifications (Webhooks, Matrix, Telegram)
- Dashboard für Status-Übersicht

**Strategie:**
- v1.5.0 - v1.8.0: Monolithisch (stabil, einfach)
- v2.0.0: Großes Refactoring (Breaking Changes erlaubt)
- Support für v1.x: 6 Monate nach v2.0.0

Siehe ROADMAP.md für vollständige Details aller Versionen.

---
Letzte Aktualisierung: 2026-01-25
Aktuelle Version: v1.6.1 (In Entwicklung - Bugfixes)
Vorherige Version: v1.6.0 (Released: 2026-01-25)
Nächste Versionen: v1.7.0 → v1.8.0 → v2.0.0

## Nächste Schritte (v1.6.1)

### Sofort testen:
1. **install.sh ausführen:**
   ```bash
   sudo ./install.sh
   ```
   - Prüft ob System-Config erstellt wird
   - Testet Config-Migration
   - Verifiziert AUTO_REBOOT Setting

2. **Update-Test mit Config-Debugging:**
   ```bash
   sudo ./update.sh
   ```
   - Log prüfen auf "Config-Debugging"
   - Verifizieren dass Config geladen wird
   - Prüfen ob AUTO_REBOOT erkannt wird

3. **Cron-Kompatibilität testen:**
   - Cron-Job einrichten
   - Prüfen ob /etc/linux-update-script/config.conf verwendet wird

### Vor Release:
- [ ] Testing auf Debian/Ubuntu/Mint
- [ ] Testing mit Cron-Jobs
- [ ] mintupgrade Workflow testen (auf Mint)
- [ ] AUTO_REBOOT testen (mit Kernel-Update)
- [ ] Dry-Run für Fedora/openSUSE testen
- [ ] README.md mit Hybrid-Config aktualisieren
- [ ] CHANGELOG.md für v1.6.1 schreiben

### Bekannte Issues:
- Keine bekannten Issues

### Community-Feedback:
- AUTO_REBOOT Bug gemeldet und gefixt
- Mint Upgrade Support nachträglich hinzugefügt
- Dry-Run für alle Distributionen implementiert
