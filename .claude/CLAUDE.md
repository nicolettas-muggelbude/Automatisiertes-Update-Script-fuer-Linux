# Update-Script Projekt - Claude Kontext

## Projekt-Übersicht
Linux System Update-Script mit Unterstützung für mehrere Distributionen (Debian, Ubuntu, RHEL, Fedora, SUSE, Solus, Arch, Void).

## Aktuelle Version
v1.6.0 - XDG-Konformität & Config-Migration (in Entwicklung)

## Vorherige Versionen
- v1.5.1 - Desktop-Benachrichtigungen & DMA (Released: 2025-12-27)
- v1.5.0 - Upgrade-Check System (Released: 2025-12-27)
- v1.4.0 - ShellCheck-Warnungen behoben, Kernel-Schutz implementiert

## Nächste Version
v1.7.0 - Hooks & Automation (geplant)

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
Letzte Aktualisierung: 2026-01-24
Aktuelle Version: v1.6.0 (In Entwicklung)
Vorherige Version: v1.5.1 (Released: 2025-12-27)
Nächste Versionen: v1.7.0 → v1.8.0 → v2.0.0

## Nächste Schritte (v1.6.0)
- Testing der Config-Migration auf verschiedenen Systemen
- Testing mit verschiedenen Distributionen
- Community-Feedback zu XDG-Implementierung sammeln
- README.md mit neuen Config-Pfaden aktualisieren
- ROADMAP.md Status aktualisieren
