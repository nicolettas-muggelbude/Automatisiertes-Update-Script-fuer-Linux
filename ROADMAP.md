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

## Version 1.8.0 - Backup & Optimierung ✅

**Status:** ✅ Implementiert (Released: 2026-04-04)

### 💾 Backup-Integration

**Implementierte Features:**

#### Backup-Methoden
- ✅ `backup_lvm()` - LVM-Snapshot des Root-Volumes (`lvcreate -s`)
- ✅ `backup_btrfs()` - Btrfs-Subvolume-Snapshot (`btrfs subvolume snapshot`)
- ✅ `backup_zfs()` - ZFS-Snapshot des Root-Datasets (`zfs snapshot`)
- ✅ `backup_rsync()` - Vollständiges Dateisystem-Backup (mit Standardausschlüssen)
- ✅ `rotate_backups()` - Automatische Rotation alter Backups
- ✅ `run_backup()` - Orchestrierung: Methoden-Dispatch + Rotation

#### System-Last-Prüfung
- ✅ `check_system_load()` - Prüft `/proc/loadavg` gegen `UPDATE_MAX_LOAD`
- ✅ Update-Abbruch bei zu hoher Last (optional, standardmäßig deaktiviert)

#### Konfiguration
```bash
ENABLE_BACKUP=false           # Backup aktivieren
BACKUP_METHOD="rsync"         # lvm | btrfs | zfs | rsync
BACKUP_TARGET="/backup/system" # Zielverzeichnis
BACKUP_RETENTION=3            # Anzahl zu behaltender Backups
BACKUP_BEFORE_UPGRADE=true    # Backup vor Dist-Upgrade erzwingen

UPDATE_LOAD_CHECK=false       # Load-Check aktivieren
UPDATE_MAX_LOAD="2.0"         # Maximale 1-Minuten-Last
```

#### Ablauf
```
1. Root-Check
2. Load-Check (wenn UPDATE_LOAD_CHECK=true)
3. Distribution erkennen
4. NVIDIA-Kompatibilität prüfen
5. Pre-Hooks ausführen
6. Backup erstellen (wenn ENABLE_BACKUP=true)
7. Update/Upgrade durchführen
8. Post-Hooks ausführen
```

---

## Version 1.9.0 - Netzwerk & Fortschritt ✅

**Status:** ✅ Implementiert (Released: 2026-04-18)

### 🌐 Automatische Bandbreitenmessung & -limitierung

- ✅ `detect_bandwidth()` – misst Bandbreite via `curl` vor jedem Update (max. 5 Sek)
- ✅ `get_bandwidth_test_url()` – wählt distro-spezifischen Mirror automatisch
- ✅ Natives Limit: apt (`Acquire::http::Dl-Limit`), dnf/yum (`--setopt=throttle`)
- ✅ `run_with_trickle()` – Fallback für Arch, openSUSE, Void, Solus
- ✅ 3 Modi: `auto` (Standard), `""` (volle Bandbreite), fester KB/s-Wert

**Konfiguration:**
```bash
BANDWIDTH_LIMIT="auto"       # auto | "" | "500" (KB/s)
BANDWIDTH_LIMIT_PERCENT=80   # Prozent der gemessenen Bandbreite
BANDWIDTH_TEST_URL=""        # leer = automatisch per Distro
```

### 📊 Update-Zeitschätzung & Fortschritt

- ✅ `estimate_update_time()` – Paketanzahl + Downloadgröße per Dry-Run
- ✅ `parse_download_size_mb()` – parst B/kB/MB/GB aus apt/dnf-Ausgabe
- ✅ `format_duration()` – Zeitformatierung Sek/Min/Std (mehrsprachig)
- ✅ `start_spinner()` / `stop_spinner()` – Spinner bei stillen Operationen
- ✅ Graceful: kein Spinner bei Cron-Jobs (kein Terminal)

**Konfiguration:**
```bash
ENABLE_PROGRESS=true
```

### 🔄 Snap-Paket-Check

- ✅ `update_snap()` – erkennt ob `snapd.timer` aktiv (Auto-Updates)
- ✅ Führt `snap refresh` aus wenn Snap installiert aber Auto-Updates inaktiv

---

## Versions-Strategie ab v2.0.0

### Warum eine neue Strategie?

v1.9.0 ist feature-complete für Desktop- und Heimanwender. Enterprise-Features (Container, Multi-System, Webhooks) würden für die meisten User unnötige Komplexität bedeuten. Daher wird ab v2.0.0 eine klare Trennung eingeführt:

| Version | Zielgruppe | Fokus |
|---------|-----------|-------|
| **v1.9.x** | Desktop / Heimanwender | Bugfixes, kleinere Verbesserungen — kein neues Feature-Scope |
| **v2.0.0** | Alle | Reines Refactoring — gleicher Funktionsumfang wie v1.9, modulare Codebasis als Fundament |
| **v3.0.0** | Server / Power-User | Enterprise-Features (Container, Multi-System, Webhooks) auf Basis von v2.0 |

---

## Version 2.0.0 - Major Refactoring

**Status:** ✅ Implementiert (2026-05-14)

⚠️ **Kein neuer Feature-Scope.** v2.0.0 ist reines Code-Refactoring — gleiche Funktionen wie v1.9.0, aber modulare, testbare Architektur als Fundament für v3.0.0.

### 🏗️ Neue modulare Struktur

```
update-script/
├── update.sh              # Hauptscript (~140 Zeilen, reine Orchestrierung)
├── lib/
│   ├── core.sh           # Basis: Farben, Config, Logging, Distro-Erkennung
│   ├── notifications.sh  # E-Mail & Desktop-Notifications
│   ├── hooks.sh          # Pre/Post-Update Hooks
│   ├── backup.sh         # Backup-Integration & Load-Check
│   ├── kernel.sh         # Kernel-Schutz, NVIDIA & Secure Boot
│   ├── upgrades.sh       # Upgrade-Check System
│   ├── network.sh        # Bandbreitenmessung, Snap & fwupd
│   └── distros.sh        # Paketmanager-Updates & Reboot-Check
├── lang/
└── tests/
    ├── test_core.bats
    ├── test_network.bats
    ├── test_kernel.bats
    ├── test_upgrades.bats
    └── run_tests.sh
```

### 🧪 Test-Framework

- [bats-core](https://github.com/bats-core/bats-core) — Bash Automated Testing System
- Installation: `sudo apt install bats` oder via GitHub
- Ausführung: `bash tests/run_tests.sh`
- ShellCheck-Integration im Test-Runner

### 🔄 Migration

- `update.sh` bleibt Haupteinstiegspunkt ✅
- `config.conf` Format bleibt kompatibel ✅
- ⚠️ **Breaking Change**: Legacy-Config `./config.conf` nicht mehr unterstützt
  - Migration: `sudo cp ./config.conf /etc/linux-update-script/config.conf`
- Support für v1.9.x: 6 Monate nach v2.0.0 Release (bis 2026-11-14)

---

## Version 3.0.0 - Enterprise Features

**Status:** 📋 Konzeptphase — wartet auf Community-Feedback und v2.0.0

⚠️ **Nur für Server / Power-User.** Desktop-Anwender bleiben bei v1.9.x oder v2.0.0.

### 🐳 Container-Support

- Docker, LXC, Podman Container-Updates
- Automatische Container-Erkennung

### 🌐 Multi-System Management

- SSH-basiertes Remote-Update mehrerer Hosts
- Parallele Updates
- Status-Dashboard

### 📢 Advanced Notifications

- Webhook-Support (Slack, Discord, Teams)
- Matrix / Telegram Bot Integration
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
- **v1.8.0** ✅ - Backup-Integration & Load-Check (Released: 2026-04-04)
- **v1.9.0** ✅ - Bandbreitenmessung, Zeitschätzung & Snap-Check (Released: 2026-04-18)
- **v1.9.1** ✅ - fwupd Firmware-Updates & curl/wget Fallback (Released: 2026-04-27)
- **v2.0.0** ✅ - **Major Refactoring** (modulare Architektur, Tests) (Released: 2026-05-14)
- **v3.0.0** 📋 - **Enterprise Features** (Container, Multi-System, Webhooks) — nur für Server/Power-User

### Architektur-Strategie

| Linie | Versionen | Zielgruppe |
|-------|-----------|-----------|
| Desktop-stabil | v1.9.x | Heimanwender, Desktop |
| Refactoring | v2.0.0 | Alle — sauberes Fundament |
| Enterprise | v3.0.0 | Server, Power-User |

Letzte Aktualisierung: 2026-05-14
