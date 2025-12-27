# Update-Script Projekt - Claude Kontext

## Projekt-Übersicht
Linux System Update-Script mit Unterstützung für mehrere Distributionen (Debian, Ubuntu, RHEL, Fedora, SUSE, Solus, Arch, Void).

## Aktuelle Version
v1.4.0 - ShellCheck-Warnungen behoben, Kernel-Schutz implementiert

## Nächste Version
v1.5.0 - Upgrade-Check System (in Arbeit)

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

## Aktuelle Entwicklung (v1.5.0)

### Upgrade-Check System
**Status:** In Implementierung

**Ziele:**
1. Erkennung verfügbarer Distribution-Upgrades
2. Automatische Benachrichtigung an User
3. Optionales automatisches Upgrade
4. Unterstützung für Solus (Priorität), Arch, Debian/Ubuntu, Fedora

**Technische Umsetzung:**
- `check_upgrade_available()` - Framework-Funktion
- `check_upgrade_solus()` - Solus-spezifischer Check
- `check_upgrade_arch()` - Arch-spezifischer Check
- `check_upgrade_debian()` - Debian/Ubuntu Release-Check
- `check_upgrade_fedora()` - Fedora Version-Check
- Command-Line Parameter: `--upgrade`
- Config-Parameter: `ENABLE_UPGRADE_CHECK`, `AUTO_UPGRADE`

**Neue Sprachmeldungen benötigt:**
- MSG_UPGRADE_AVAILABLE
- MSG_UPGRADE_NO_UPGRADE
- MSG_UPGRADE_START
- MSG_UPGRADE_SUCCESS
- MSG_UPGRADE_FAILED
- MSG_UPGRADE_BACKUP_WARNING
- MSG_UPGRADE_CONFIRM
- EMAIL_SUBJECT_UPGRADE
- EMAIL_BODY_UPGRADE

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

## Nächste Schritte (aktuelle Session)

1. ✅ claude.md erstellen
2. ✅ Upgrade-Check für Solus implementieren
3. ✅ Framework für andere Distributionen
4. ✅ Command-Line Parameter --upgrade
5. ✅ Config-Erweiterung
6. ✅ Sprachdateien erweitern
7. ✅ E-Mail-Benachrichtigungen
8. ✅ Testing & Dokumentation (ROADMAP aktualisiert)

## Implementierungsdetails v1.5.0

### Neue Funktionen
- `check_upgrade_available()` - Hauptfunktion für Upgrade-Check
- `check_upgrade_solus()` - Solus-spezifischer Check
- `check_upgrade_arch()` - Arch-spezifischer Check
- `check_upgrade_debian()` - Debian/Ubuntu Release-Check
- `check_upgrade_fedora()` - Fedora Version-Check
- `perform_upgrade()` - Upgrade-Durchführung mit Bestätigung

### Command-Line Interface
- `--upgrade` - Führt Distribution-Upgrade durch
- `--help` / `-h` - Zeigt Hilfe an

### Konfiguration
- `ENABLE_UPGRADE_CHECK` (default: true)
- `AUTO_UPGRADE` (default: false)
- `UPGRADE_NOTIFY_EMAIL` (default: true)

### Workflow
1. Normales Update läuft
2. Nach erfolgreichem Update: Upgrade-Check
3. Wenn Upgrade verfügbar (Return-Code 3): Benachrichtigung
4. Optional: AUTO_UPGRADE führt Upgrade direkt durch
5. E-Mail-Benachrichtigung bei verfügbarem Upgrade

### Rückgabewerte
- `0` - Kein Upgrade verfügbar
- `1` - Fehler oder nicht unterstützt
- `2` - Updates verfügbar (Rolling Release)
- `3` - Major-Upgrade verfügbar

### ShellCheck
✅ Alle Checks bestanden - keine Warnungen

### Status
🎉 **Upgrade-Check System vollständig implementiert und bereit für v1.5.0**

Noch zu tun:
- Testing auf echten Systemen
- README.md aktualisieren
- CHANGELOG.md vorbereiten
- Release Notes

## Roadmap - Geplante Versionen

### v1.6.0 - Desktop-Benachrichtigungen
**Status:** 🔄 Geplant

**Fokus:**
- Desktop-Benachrichtigungen mit notify-send
- 4 Notification-Szenarien (Erfolg, Upgrade, Fehler, Neustart)
- Konfiguration: ENABLE_DESKTOP_NOTIFICATION, NOTIFICATION_TIMEOUT
- Unterstützung für GNOME, KDE, XFCE, Cinnamon, MATE, etc.

**Herausforderung:** Script läuft als root, Notification für User
**Lösung:** `sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=...`

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
Letzte Aktualisierung: 2025-12-27
Version: v1.5.0 (Released)
Nächste Versionen: v1.6.0 → v1.7.0 → v1.8.0 → v2.0.0
