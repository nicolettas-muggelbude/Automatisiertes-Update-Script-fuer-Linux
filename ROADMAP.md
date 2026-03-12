# Roadmap - Linux Update-Script

Geplante Features und Verbesserungen für zukünftige Versionen.

## Version 1.5.0 - Sicherheit & Upgrade-Check

### ✅ Bereits implementiert

#### Kernel-Schutz für autoremove
**Status:** ✅ Implementiert (bereit für v1.5.0)

**Motivation:**
Verhindert versehentliches Entfernen von Fallback-Kerneln, die nach fehlgeschlagenen Updates zum Booten benötigt werden.

**Features:**
- Intelligente Zählung stabiler Kernel-Versionen
- Prüfung vor jedem `autoremove`-Aufruf
- Konfigurierbare Mindestanzahl (Standard: 3 Kernel)
- Unterstützung für Debian/Ubuntu und RHEL/Fedora
- Mehrsprachige Warn- und Info-Meldungen

**Konfiguration:**
```bash
# Kernel-Schutz aktivieren/deaktivieren
KERNEL_PROTECTION=true

# Minimale Anzahl stabiler Kernel
# 3 = aktuell laufend + 2 Fallback-Versionen
MIN_KERNELS=3
```

**Sicherheitsvorteile:**
- ✅ Verhindert Bootprobleme durch fehlende Fallback-Kernel
- ✅ Bewahrt mindestens 2 stabile Kernel-Versionen
- ✅ Überspringt autoremove bei zu wenigen Kerneln
- ✅ Transparentes Logging aller Entscheidungen

---

### ✅ Bereits implementiert

#### Upgrade-Check System
**Status:** ✅ Implementiert (bereit für v1.5.0)

**Motivation:**
Einige Distributionen (besonders Rolling Releases wie Solus) bieten nicht automatisch ein Upgrade auf neue Versionen an. Ein Upgrade-Check informiert Users darüber und ermöglicht optional das Upgrade durchzuführen.

**Implementierte Features:**

#### 1. Upgrade-Check Framework ✅
- Zentrale Funktion `check_upgrade_available()`
- Distributionsspezifische Dispatcher
- Rückgabewerte für verschiedene Szenarien (kein Upgrade, Updates, Major-Upgrade)
- Automatische Prüfung nach regulären Updates

#### 2. Distributionsspezifische Checks ✅

**Solus:**
- `check_upgrade_solus()` - Prüft auf ausstehende Updates
- Hinweis: Solus ist Rolling Release (keine Major-Versions-Upgrades)
- Erkennung via `eopkg list-pending`

**Arch/Manjaro:**
- `check_upgrade_arch()` - Prüft auf verfügbare Updates
- Verwendet `checkupdates` (aus pacman-contrib)
- Rolling Release Support

**Debian/Ubuntu:**
- `check_upgrade_debian()` - Prüft auf neue Release-Versionen
- `do-release-upgrade` Integration
- LTS → Non-LTS Upgrade-Unterstützung
- E-Mail-Benachrichtigung bei verfügbarem Upgrade

**Fedora:**
- `check_upgrade_fedora()` - Prüft auf neue Fedora-Versionen
- `dnf system-upgrade` Integration
- Automatische Version-Erkennung

#### 3. Upgrade-Durchführung ✅
- `perform_upgrade()` - Führt Distribution-Upgrade durch
- Backup-Warnung vor jedem Upgrade
- Benutzer-Bestätigung (außer bei AUTO_UPGRADE)
- Distributionsspezifische Upgrade-Befehle

**Konfiguration (config.conf):**

```bash
# Upgrade-Check aktivieren (true/false)
ENABLE_UPGRADE_CHECK=true

# Automatisches Upgrade durchführen (true/false)
# WARNUNG: Kann Breaking Changes verursachen!
AUTO_UPGRADE=false

# Upgrade-Benachrichtigungen per E-Mail (true/false)
UPGRADE_NOTIFY_EMAIL=true
```

**User-Workflow:**

1. **Automatischer Check während Update:** ✅
   ```bash
   sudo ./update.sh
   # [INFO] System-Update abgeschlossen
   # [INFO] Prüfe auf verfügbare Distribution-Upgrades
   # [INFO] Upgrade verfügbar: Ubuntu 22.04 → Ubuntu 24.04
   # [INFO] Für Upgrade ausführen: sudo ./update.sh --upgrade
   ```

2. **Manuelles Upgrade:** ✅
   ```bash
   sudo ./update.sh --upgrade
   # [WARNUNG] Erstelle ein Backup vor dem Upgrade!
   # Möchtest du das Upgrade durchführen? [j/N]:
   # [INFO] Starte Upgrade zu Ubuntu 24.04
   # [INFO] Distribution-Upgrade erfolgreich abgeschlossen
   ```

3. **Automatisches Upgrade (Config):** ✅
   ```bash
   # AUTO_UPGRADE=true in config.conf
   sudo ./update.sh
   # Führt automatisch Upgrade durch wenn verfügbar
   ```

4. **Hilfe anzeigen:** ✅
   ```bash
   sudo ./update.sh --help
   # Linux System Update-Script
   # Verwendung: ./update.sh [OPTIONEN]
   # Optionen:
   #   --upgrade    Führt Distribution-Upgrade durch (falls verfügbar)
   #   --help, -h   Zeigt diese Hilfe an
   ```

**Sicherheitsaspekte:**

- ✅ **Backup-Warnung** vor jedem Upgrade
- ✅ **Benutzer-Bestätigung** (außer bei AUTO_UPGRADE)
- ✅ **Rollback-Information** in Logs
- ✅ **Opt-in** (standardmäßig nur Benachrichtigung)
- ✅ **ShellCheck-konform** (keine Warnungen)

**E-Mail-Benachrichtigung:** ✅

```
Betreff: Distribution-Upgrade verfügbar

Ein Upgrade für die Distribution ist verfügbar

Aktuelle Version: Ubuntu 22.04
Neue Version: Ubuntu 24.04

Für Upgrade ausführen:
sudo /pfad/zum/update.sh --upgrade

WARNUNG: Erstelle ein Backup vor dem Upgrade!
```

**Mehrsprachigkeit:** ✅
- Alle Upgrade-Messages in Deutsch und Englisch
- Automatische Spracherkennung
- Konsistente Message-Keys in allen Sprachdateien

### 🔄 Weitere Verbesserungen für v1.5.0

- [ ] Testing auf echten Systemen (Solus, Arch, Debian, Fedora)
- [ ] README.md aktualisieren mit Upgrade-Check Dokumentation
- [ ] CHANGELOG.md für v1.5.0 vorbereiten
- [ ] Release Notes verfassen

---

## Version 1.5.1 - Desktop-Benachrichtigungen & DMA

### ✅ Bereits implementiert

#### Desktop-Benachrichtigungen
**Status:** ✅ Implementiert (Released: 2025-12-27)

**Motivation:**
Desktop-User profitieren von visuellen Popup-Benachrichtigungen, besonders bei manueller Ausführung oder verfügbaren Upgrades.

**Implementierte Features:**
- ✅ Zentrale `send_notification()` Funktion
- ✅ Automatische SUDO_USER-Erkennung für root-Kontext
- ✅ DISPLAY=:0 und DBUS_SESSION_BUS_ADDRESS Setup
- ✅ Graceful Degradation ohne libnotify
- ✅ Unterstützung für alle Desktop-Umgebungen (GNOME, KDE, XFCE, Cinnamon, MATE, LXQt, Budgie)

**Konfiguration (config.conf):**
```bash
ENABLE_DESKTOP_NOTIFICATION=true
NOTIFICATION_TIMEOUT=5000
```

**Implementierte Notification-Szenarien:**

- ✅ Nach erfolgreichem Update
- ✅ Bei verfügbarem Upgrade
- ✅ Bei Fehlern (critical urgency)
- ✅ Neustart erforderlich

**Icons:**
- `software-update-available` (Update-Erfolg)
- `system-software-update` (Upgrade verfügbar)
- `dialog-error` (Fehler)
- `system-reboot` (Neustart)

**Mehrsprachigkeit:**
- ✅ 8 neue Sprachmeldungen in Deutsch und Englisch
- ✅ NOTIFICATION_UPDATE_SUCCESS / NOTIFICATION_UPDATE_SUCCESS_BODY
- ✅ NOTIFICATION_UPDATE_FAILED / NOTIFICATION_UPDATE_FAILED_BODY
- ✅ NOTIFICATION_UPGRADE_AVAILABLE / NOTIFICATION_UPGRADE_AVAILABLE_BODY
- ✅ NOTIFICATION_REBOOT_REQUIRED / NOTIFICATION_REBOOT_REQUIRED_BODY

**Installation:**
```bash
# Debian/Ubuntu
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

---

#### DMA - Empfohlene MTA-Lösung
**Status:** ✅ Dokumentiert (Released: 2025-12-27)

**Community-Feedback:**
Ein User empfahl DMA (DragonFly Mail Agent) als einfachere Alternative zu postfix/ssmtp für lokale E-Mail-Benachrichtigungen.

**Warum DMA?**
- ✅ Keine Konfiguration nötig - einfach installieren und es funktioniert
- ✅ Kein laufender Dienst im Hintergrund
- ✅ Kein offener Port (25)
- ✅ Keine Queue
- ✅ Perfekt für lokale Mails (cron, mail)

**Installation:**
```bash
sudo apt-get install dma
# Das war's - DMA funktioniert sofort!
```

**Dokumentation:**
- ✅ DMA als empfohlene Lösung in README.md
- ✅ Alternative MTAs weiterhin dokumentiert (ssmtp, postfix)
- ✅ Einfachere Installationsanleitung

---

## Version 1.6.0 - XDG-Konformität, Config-Migration & NVIDIA-Prüfung

### 📁 XDG Base Directory Specification

**Status:** ✅ Implementiert (2026-01-24)

### 🎮 NVIDIA-Kernel-Kompatibilitätsprüfung

**Status:** ✅ Implementiert (2026-01-24)

**Motivation:**
Proprietäre NVIDIA-Treiber erfordern nach Kernel-Updates oft ein DKMS-Rebuild. Ohne funktionierende Treiber kann das System nach dem Neustart nicht mehr richtig starten (kein X11/Wayland). Die Prüfung VOR dem Update verhindert Probleme.

**Features:**
1. ✅ Erkennung ob NVIDIA-Treiber installiert sind
   - Prüfung via `nvidia-smi`, `lsmod`, `lspci`
   - Erkennung der installierten Treiberversion

2. ✅ Abfrage der pending Kernel-Version
   - Distributionsspezifische Abfrage für ALLE unterstützten Distributionen:
     * Debian/Ubuntu/Mint (apt-cache)
     * RHEL/Fedora/CentOS/Rocky/AlmaLinux (dnf/yum)
     * Arch/Manjaro/EndeavourOS/Garuda/ArcoLinux (pacman)
     * openSUSE/SLES (zypper)
     * Solus (eopkg)
     * Void Linux (xbps-query)
   - Erkennung welcher Kernel im Update verfügbar ist

3. ✅ DKMS-Status-Prüfung
   - Prüfung ob DKMS installiert ist
   - Prüfung ob NVIDIA DKMS-Module existieren
   - Prüfung ob Module für neuen Kernel bereits gebaut sind

4. ✅ Automatischer DKMS-Rebuild
   - Interaktive Nachfrage ob Rebuild durchgeführt werden soll
   - Optional: Automatischer Rebuild (CONFIG: `NVIDIA_AUTO_DKMS_REBUILD=true`)
   - `dkms autoinstall` für neuen Kernel

5. ✅ Warnung bei Inkompatibilität
   - User-Frage ob Update trotzdem durchgeführt werden soll
   - Option zum Abbrechen des Updates
   - Empfehlung NVIDIA-Treiber zu aktualisieren

6. ✅ Secure Boot Support (MOK-Signierung)
   - Automatische Erkennung von Secure Boot Status
   - Prüfung ob MOK (Machine Owner Key) enrollt ist
   - Automatische Signierung von DKMS-Modulen nach Rebuild
   - Unterstützung für verschiedene MOK-Pfade
   - Erkennung von sign-file Tools (kernel-headers, kbuild, kmodsign)
   - Optional: Automatische Signierung (CONFIG: `NVIDIA_AUTO_MOK_SIGN=true`)

7. ✅ Kernel-Hold-Mechanismus (Sicherer Default-Modus)
   - **Default-Verhalten**: Test DKMS-Build VOR Update
   - Bei Inkompatibilität: Kernel-Update wird automatisch ausgeschlossen
   - Kernel wird "gehalten" (apt-mark hold, dnf versionlock, zypper addlock)
   - Rest des Systems wird normal aktualisiert
   - User erhält Info wie Kernel später freigegeben werden kann
   - Distribution-spezifische Hold-Befehle für alle 6 Distributionsfamilien
   - Verhindert "schwarzen Bildschirm" durch fehlgeschlagene Kernel-Updates

8. ✅ Power-User-Modus (Opt-in)
   - Optional: Nicht unterstützte Kernel trotzdem zulassen
   - CONFIG: `NVIDIA_ALLOW_UNSUPPORTED_KERNEL=true`
   - Explizite Warnung über Risiken (Instabilität, schwarzer Bildschirm)
   - DKMS-Rebuild wird trotz offiziell nicht unterstützter Kernel-Version versucht
   - Mit Secure Boot Support kombinierbar
   - Für erfahrene Benutzer mit Fallback-Optionen

**Konfiguration (config.conf):**
```bash
# NVIDIA-Prüfung deaktivieren (default: false)
NVIDIA_CHECK_DISABLED=false

# Automatischer DKMS-Rebuild ohne Nachfrage (default: false)
NVIDIA_AUTO_DKMS_REBUILD=false

# Power-User Modus: Nicht unterstützte Kernel erlauben (default: false)
# WARNUNG: Risikoreich! Nur für erfahrene Benutzer mit Fallback-Optionen
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=false

# Automatische MOK-Signierung für Secure Boot (default: false)
NVIDIA_AUTO_MOK_SIGN=false
```

**Technische Umsetzung:**
- `is_nvidia_installed()` - Erkennt NVIDIA-Treiber
- `get_pending_kernel_version()` - Ermittelt pending Kernel (alle 6 Distributionen)
- `check_nvidia_dkms_status()` - Prüft DKMS-Status
- `is_secureboot_enabled()` - Erkennt Secure Boot (mokutil, bootctl, EFI vars)
- `check_mok_keys()` - Prüft MOK-Schlüssel
- `sign_nvidia_modules()` - Signiert DKMS-Module mit MOK
- `hold_kernel_update()` - Hält Kernel-Update zurück (distributionsspezifisch)
- `test_dkms_build()` - Testet DKMS-Build ohne Installation
- `handle_secureboot_signing()` - Post-Build Secure Boot Handling
- `check_nvidia_compatibility()` - Hauptfunktion mit Safe/Power-User Modi

**Ablauf:**
1. Script startet
2. Distribution erkennen
3. **NVIDIA-Prüfung durchführen** ← VOR dem Update!
4. Falls Probleme: User-Interaktion
5. Update durchführen

**Sicherheitsvorteile:**
- ✅ Verhindert "schwarzer Bildschirm" nach Kernel-Update
- ✅ Proaktive Warnung vor Problemen
- ✅ Automatischer Fix verfügbar (DKMS rebuild)
- ✅ Kernel-Hold als sicherer Default (keine Frage mehr nötig!)
- ✅ Secure Boot vollständig unterstützt
- ✅ User behält Kontrolle (Power-User Opt-in möglich)
- ✅ Conservative Defaults, Power-User Optionen vorhanden

**Mehrsprachigkeit:**
- ✅ 41 neue Sprachmeldungen (DE/EN)
- ✅ Alle NVIDIA-bezogenen Messages übersetzt
- ✅ Secure Boot Messages
- ✅ Kernel-Hold Messages
- ✅ Power-User Warnungen

---

### 📁 XDG Base Directory Specification (Details)

**Motivation:**
Community-Feedback (@tbreswald): Config-Dateien sollten Linux-Standard-konform in `~/.config/` liegen, nicht im Script-Ordner.

**Ziele:**
- ✅ XDG-konform: Config nach `~/.config/linux-update-script/`
- ✅ Automatische Migration von alter Config
- ✅ Backwards-kompatibel (keine Breaking Changes)
- ✅ Config bleibt bei Script-Updates erhalten

#### 1. Neue Config-Location

**Aktuell (v1.5.1):**
```bash
~/linux-update-script/config.conf          # Im Script-Ordner
```

**Neu (v1.6.0):**
```bash
~/.config/linux-update-script/config.conf  # XDG-konform
```

**System-weite Installation:**
```bash
/etc/linux-update-script/config.conf       # System-Config
~/.config/linux-update-script/config.conf  # User-Override (optional)
```

#### 2. Automatische Migration

**Migrations-Logik beim Script-Start:**

```bash
migrate_config() {
    local old_config="${SCRIPT_DIR}/config.conf"
    local new_config="${HOME}/.config/linux-update-script/config.conf"
    local new_dir="${HOME}/.config/linux-update-script"

    # Neue Location bereits vorhanden? → nutzen
    if [ -f "$new_config" ]; then
        return 0
    fi

    # Alte Config vorhanden? → migrieren
    if [ -f "$old_config" ]; then
        log_info "Migriere Config nach ~/.config/ (XDG-Standard)"

        # Verzeichnis erstellen
        mkdir -p "$new_dir"

        # Config kopieren
        cp "$old_config" "$new_config"

        # Alte Config umbenennen (als Backup)
        mv "$old_config" "${old_config}.migrated"

        log_info "Config erfolgreich migriert nach: $new_config"
        log_info "Alte Config gesichert als: ${old_config}.migrated"
        return 0
    fi

    # Keine Config vorhanden → install.sh verwenden
    log_warning "Keine Config gefunden. Bitte install.sh ausführen."
    return 1
}
```

**Migrations-Ablauf:**
1. Script prüft zuerst: `~/.config/linux-update-script/config.conf`
2. Falls nicht vorhanden: Prüfe `./config.conf` (alter Pfad)
3. Falls alte Config vorhanden:
   - Erstelle `~/.config/linux-update-script/`
   - Kopiere Config in neuen Pfad
   - Benenne alte Config um zu `.migrated` (Backup)
   - Info-Meldung ausgeben
4. Nutze Config von neuer Location

#### 3. install.sh Anpassungen

**Neue Installations-Location:**
```bash
# install.sh erstellt Config direkt in ~/.config/
CONFIG_DIR="${HOME}/.config/linux-update-script"
CONFIG_FILE="${CONFIG_DIR}/config.conf"

mkdir -p "$CONFIG_DIR"
# ... Config erstellen in $CONFIG_FILE
```

**Alte Installation erkennen:**
```bash
# Falls alte Config existiert, anbieten zu migrieren
if [ -f "${SCRIPT_DIR}/config.conf" ]; then
    print_info "Alte Config-Datei gefunden"
    print_info "Migration nach ~/.config/ empfohlen"
    # ... Migration durchführen
fi
```

#### 4. Vorteile

**Für User:**
- ✅ Config bleibt beim Script-Update (git pull) erhalten
- ✅ Alle Configs an einem Standard-Ort (`~/.config/`)
- ✅ Keine manuellen Schritte nötig (Auto-Migration)
- ✅ Alte Config als Backup erhalten

**Für Entwicklung:**
- ✅ Standard-konform (XDG Base Directory Specification)
- ✅ Saubere Trennung: Code vs. Konfiguration
- ✅ Multi-User-fähig (jeder User eigene Config)
- ✅ Vorbereitung für v2.0.0 (weitere XDG-Konformität)

#### 5. Backwards-Kompatibilität

**Fallback-Mechanismus:**
```bash
# Suche Config in dieser Reihenfolge:
1. ~/.config/linux-update-script/config.conf  (neu, bevorzugt)
2. /etc/linux-update-script/config.conf       (system-weit)
3. ./config.conf                               (alt, deprecated)
```

**Warnung bei alter Location:**
```bash
if [ -f "./config.conf" ] && [ ! -f "~/.config/linux-update-script/config.conf" ]; then
    log_warning "Config im alten Pfad gefunden"
    log_warning "Migration wird beim nächsten Start durchgeführt"
fi
```

#### 6. Dokumentation

**README.md Update:**
- Neue Config-Location dokumentieren
- Migration automatisch erklärt
- Manuelle Migration optional zeigen

**CHANGELOG.md:**
- Breaking Change: Nein (Auto-Migration)
- Feature: XDG-Konformität
- Migration: Automatisch beim ersten Start

---

### 🔔 Weitere Desktop-Notification-Verbesserungen

**Status:** 📋 Geplant (niedrigere Priorität)

**Hinweis:** Basis-Desktop-Notifications bereits in v1.5.1 implementiert.

**Optionale Erweiterungen:**
- [ ] Notification-Sound-Support
- [ ] Custom Icons für Distributionen
- [ ] Notification-Historie/Log
- [ ] Click-Action für Notifications

---

## Version 1.7.0 - Hooks & Automation ✅

**Status:** ✅ Implementiert (Released: 2026-03-13)

### 🪝 Pre/Post-Update Hooks

**Implementierte Features:**
- `run_single_hook()` - Einzelnen Hook ausführen (mit Timeout)
- `run_hooks()` - Alle Hooks in einem Verzeichnis (alphabetisch)
- `run_pre_update_hooks()` - Führt Pre-Hooks vor Update aus
- `run_post_update_hooks()` - Führt Post-Hooks nach Update aus
- Hook-Verzeichnisse: `/etc/update-hooks/pre.d/` und `/etc/update-hooks/post.d/`
- Alphabetische Ausführung (10-... vor 20-... vor 90-...)
- Timeout-Unterstützung (Standard: 300 Sekunden)
- `HOOKS_ABORT_ON_ERROR` - Optionaler Abbruch bei Pre-Hook-Fehler
- Graceful: nicht ausführbare Dateien werden übersprungen
- Vollständiges Logging

**Konfiguration:**
```bash
ENABLE_HOOKS=true
HOOKS_DIR="/etc/update-hooks"
HOOKS_ABORT_ON_ERROR=false
HOOKS_TIMEOUT=300
```

**Beispiel-Hooks:**
```bash
# /etc/update-hooks/pre.d/10-stop-services.sh
systemctl stop myapp.service

# /etc/update-hooks/post.d/90-start-services.sh
systemctl start myapp.service
```

### 🐧 Fix: Nativer Debian-Upgrade-Support (Issue #8)

**Problem:** Debian-Nutzer sahen fälschlicherweise `[WARNUNG] do-release-upgrade nicht gefunden` — ein Ubuntu-Tool das auf Debian nicht existiert.

**Lösung:** Debian und Ubuntu/MX vollständig getrennt geroutet. Debian bekommt eigene native Funktionen:

- `check_upgrade_debian_native()` — prüft anhand der Codename-Liste ob ein Upgrade verfügbar ist
- `perform_upgrade_debian_native()` — automatisierter Upgrade-Ablauf:
  1. Backup `/etc/apt/sources.list.bak.DATUM`
  2. Codename in `sources.list` + `sources.list.d/` ersetzen (`.list` und `.sources` Formate)
  3. `apt-get update` (Rollback bei Fehler)
  4. `apt-get dist-upgrade --simulate` (Dry-Run, Rollback auf Wunsch)
  5. `DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y`
  6. `safe_autoremove`

```bash
DEBIAN_CODENAMES_ORDERED="buster bullseye bookworm trixie"
# Pending: forky (Debian 14, erwartet ~2027)
```

---

## Version 1.8.0 - Backup & Optimierung

### 💾 Backup-Integration

**Motivation:**
Automatische Backups vor kritischen Updates erhöhen die Sicherheit.

**Features:**
- Snapshot-Support für LVM, Btrfs, ZFS
- Rsync-basierte Backups
- Backup vor Distribution-Upgrades
- Konfigurierbare Backup-Ziele
- Automatische Backup-Rotation

**Konfiguration:**
```bash
# Backup vor Updates (true/false)
ENABLE_BACKUP=true

# Backup-Methode (lvm|btrfs|zfs|rsync)
BACKUP_METHOD="btrfs"

# Backup-Ziel
BACKUP_TARGET="/backup/snapshots"

# Backup-Rotation (Anzahl zu behaltender Backups)
BACKUP_RETENTION=3
```

### ⚙️ Weitere Optimierungen

- **Update-Schedule**: Intelligente Update-Zeitpunkte (Low-Load-Detection)
- **Bandwidth-Limit**: Download-Geschwindigkeit begrenzen
- **Delta-Updates**: Nur Unterschiede laden (wenn unterstützt)
- **Progress-Anzeige**: Fortschrittsbalken für lange Updates

---

## Version 2.0.0 - Major Refactoring & Enterprise Features

⚠️ **Breaking Changes:** Version 2.0.0 ist eine Major-Version mit Breaking Changes zur Codebasis-Modernisierung.

### 🏗️ Code-Architektur Refactoring (Priority)

**Motivation:**
Nach v1.8.0 wird `update.sh` voraussichtlich >1000 Zeilen haben. Für Enterprise-Features (Container, Multi-System) ist eine modulare Architektur erforderlich.

#### 1. Neue modulare Struktur

**Aktuell (v1.5.0 - v1.8.0):**
```
update-script/
├── update.sh              # Monolithisch (~1200 Zeilen nach v1.8)
├── config.conf
└── lang/
```

**Neu (v2.0.0):**
```
update-script/
├── update.sh              # Hauptscript (klein, nur Orchestrierung)
├── config.conf            # Konfiguration
├── lib/                   # Modulare Bibliotheken
│   ├── core.sh           # Basis-Funktionen (logging, colors, etc.)
│   ├── distros.sh        # Distribution-Updates
│   ├── upgrades.sh       # Upgrade-Check System
│   ├── kernel.sh         # Kernel-Schutz
│   ├── notifications.sh  # E-Mail & Desktop-Notifications
│   ├── hooks.sh          # Pre/Post-Update Hooks
│   ├── backup.sh         # Backup-Integration
│   ├── containers.sh     # Container-Support (neu)
│   └── remote.sh         # Multi-System Management (neu)
├── lang/                  # Sprachdateien (bleibt unverändert)
└── tests/                 # Unit-Tests (neu!)
    ├── test_core.sh
    ├── test_distros.sh
    ├── test_upgrades.sh
    └── test_notifications.sh
```

#### 2. Test-Framework

**Framework:** [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System)

**Beispiel Test:**
```bash
# tests/test_upgrades.sh
@test "check_upgrade_debian detects available upgrade" {
  # Mock do-release-upgrade output
  function do-release-upgrade() {
    echo "New release '24.04' available."
  }
  export -f do-release-upgrade

  run check_upgrade_debian
  [ "$status" -eq 3 ]  # Return code 3 = Upgrade available
}
```

**Ziel:** >80% Test-Coverage

#### 3. Migration-Strategie

**Backwards-Compatibility:**
- `update.sh` bleibt Haupteinstiegspunkt
- Alte `config.conf` wird automatisch konvertiert
- Migration-Script: `migrate-to-v2.sh`

**Migration-Guide:**
```bash
# Automatische Migration
sudo ./migrate-to-v2.sh

# Manuelle Migration
cp config.conf config.conf.backup
./update.sh --migrate-config
```

#### 4. Vorteile der neuen Architektur

**Entwicklung:**
- ✅ Modulare Entwicklung (Contributors arbeiten parallel)
- ✅ Unit-Tests für jedes Modul
- ✅ Wiederverwendbare Komponenten
- ✅ Klare Verantwortlichkeiten (SoC - Separation of Concerns)

**Wartung:**
- ✅ Einfacheres Debugging
- ✅ Bessere Code-Navigation
- ✅ Weniger Merge-Konflikte
- ✅ Schnellere Feature-Entwicklung

**Qualität:**
- ✅ Höhere Test-Coverage
- ✅ Bessere Dokumentation pro Modul
- ✅ ShellCheck pro Datei
- ✅ Code-Reviews fokussierter

#### 5. Breaking Changes

**Was ändert sich für User:**
- ⚠️ Installation erfordert `lib/` Verzeichnis
- ⚠️ Custom-Scripts müssen angepasst werden (wenn sie update.sh sourcen)
- ⚠️ Neue Abhängigkeit: bats-core (optional, nur für Tests)

**Was bleibt gleich:**
- ✅ `sudo ./update.sh` funktioniert weiterhin
- ✅ `config.conf` Format bleibt kompatibel
- ✅ Alle Features bleiben erhalten
- ✅ Logs im gleichen Format

#### 6. Implementierungs-Roadmap

**Phase 1:** Planung & Design (vor v2.0.0 Beta)
- Modul-Grenzen definieren
- API-Schnittstellen dokumentieren
- Test-Strategie ausarbeiten

**Phase 2:** Refactoring (v2.0.0 Beta 1)
- Funktionen in Module aufteilen
- Tests schreiben
- CI/CD für Tests einrichten

**Phase 3:** Testing & Migration (v2.0.0 Beta 2)
- Community-Testing
- Migration-Script entwickeln
- Dokumentation aktualisieren

**Phase 4:** Release (v2.0.0 Stable)
- Migration-Guide veröffentlichen
- Breaking Changes dokumentieren
- Support für v1.x für 6 Monate

---

### 🐳 Container-Support

**Nach Refactoring implementiert in `lib/containers.sh`**

- Docker Container Updates
- LXC Container Updates
- Podman Integration
- Container-Erkennung und automatische Updates

### 🌐 Multi-System Management

**Nach Refactoring implementiert in `lib/remote.sh`**

- Mehrere Systeme zentral verwalten
- SSH-basiertes Remote-Update
- Dashboard für Status-Übersicht
- Parallele Updates über mehrere Hosts

### 📢 Advanced Notifications

**Nach Refactoring erweitert in `lib/notifications.sh`**

- Webhook-Support (Slack, Discord, etc.)
- Matrix/Element Benachrichtigungen
- Telegram Bot Integration
- Custom Notification-Backends

---

## Community-Requests

Features die von der Community gewünscht wurden können hier gesammelt werden.

### Eingereichete Ideen:
- [x] Upgrade-Check System (Solus Priority) - @User Request - ✅ Implementiert in v1.5.0
- [ ] ...

### Wie Ideen einreichen?
1. GitHub Issue öffnen mit Label `feature-request`
2. Beschreibung der Idee
3. Use-Case erklären
4. Optional: Implementation-Vorschlag

---

## Priorisierung

Features werden priorisiert nach:
1. **Community-Nachfrage** (Issues, Upvotes)
2. **Sicherheitsrelevanz**
3. **Wartbarkeit**
4. **Aufwand/Nutzen-Verhältnis**

---

**Hinweis:** Diese Roadmap ist nicht final und kann sich ändern basierend auf Community-Feedback und Ressourcen.

## Versions-Übersicht

- **v1.5.0** ✅ - Upgrade-Check System & Kernel-Schutz (Released: 2025-12-27)
- **v1.5.1** ✅ - Desktop-Benachrichtigungen & DMA (Released: 2025-12-27)
- **v1.6.0** ✅ - **XDG-Konformität, Config-Migration & NVIDIA-Prüfung** (Implementiert: 2026-01-24)
- **v1.7.0** ✅ - Hooks & Automation (Pre/Post-Update Hooks) (Released: 2026-03-13)
- **v1.8.0** 📋 - Backup-Integration & Optimierungen
- **v2.0.0** 🏗️ - **Major Refactoring** + Container-Support + Multi-System Management

### Architektur-Strategie

**v1.5.0 - v1.8.0:** Monolithische Architektur beibehalten
- ✅ Aktuell überschaubar und stabil
- ✅ Einfach für Contributors
- ✅ Community-Feedback sammeln
- ✅ Features etablieren

**v2.0.0:** Modulare Architektur
- 🏗️ Großes Refactoring (Breaking Changes erlaubt)
- 🏗️ Test-Framework (bats-core, >80% Coverage)
- 🏗️ Migration-Script für User
- 🏗️ 6 Monate Support für v1.x

Letzte Aktualisierung: 2026-03-13
