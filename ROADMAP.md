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

## Version 1.6.0 - Benachrichtigungen & Hooks

### 🔔 Desktop-Benachrichtigungen (Priority)

**Motivation:**
Aktuell unterstützt das Script nur E-Mail-Benachrichtigungen. Desktop-User würden von visuellen Popup-Benachrichtigungen profitieren, besonders bei manueller Ausführung oder verfügbaren Upgrades.

#### 1. Desktop-Notification Framework

**Funktion:**
```bash
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"  # low, normal, critical
    local icon="$4"     # success, error, warning, info

    # Prüfen ob Desktop-Benachrichtigungen aktiviert
    if [ "$ENABLE_DESKTOP_NOTIFICATION" != "true" ]; then
        return 0
    fi

    # notify-send verfügbar?
    if ! command -v notify-send &> /dev/null; then
        log_warning "notify-send nicht verfügbar"
        return 1
    fi

    # Notification für SUDO_USER anzeigen
    if [ -n "$SUDO_USER" ]; then
        sudo -u "$SUDO_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$SUDO_USER")/bus \
            notify-send --urgency="$urgency" --icon="$icon" "$title" "$message"
    fi
}
```

#### 2. Notification-Szenarien

**Nach erfolgreichem Update:**
```bash
send_notification \
    "System-Update abgeschlossen" \
    "Alle Updates wurden erfolgreich installiert" \
    "normal" \
    "software-update-available"
```

**Bei verfügbarem Upgrade:**
```bash
send_notification \
    "Distribution-Upgrade verfügbar" \
    "Ubuntu 22.04 → Ubuntu 24.04\nMit 'sudo ./update.sh --upgrade' installieren" \
    "normal" \
    "system-software-update"
```

**Bei Fehlern:**
```bash
send_notification \
    "Update fehlgeschlagen" \
    "Prüfe Logdatei: $LOG_FILE" \
    "critical" \
    "dialog-error"
```

**Neustart erforderlich:**
```bash
send_notification \
    "Neustart erforderlich" \
    "System benötigt Neustart nach Updates" \
    "normal" \
    "system-reboot"
```

#### 3. Konfiguration

**config.conf:**
```bash
# Desktop-Benachrichtigungen aktivieren (true/false)
ENABLE_DESKTOP_NOTIFICATION=true

# Notification-Dauer in Millisekunden (0 = Standard)
NOTIFICATION_TIMEOUT=5000

# Nur kritische Notifications anzeigen (true/false)
NOTIFICATION_CRITICAL_ONLY=false
```

#### 4. Technische Details

**Voraussetzungen:**
- `notify-send` (Teil von libnotify)
- X11 oder Wayland Desktop-Umgebung
- DBUS läuft

**Installation:**
```bash
# Debian/Ubuntu
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify

# openSUSE
sudo zypper install libnotify-tools
```

**Unterstützte Desktop-Umgebungen:**
- GNOME
- KDE Plasma
- XFCE
- Cinnamon
- MATE
- LXQt
- Budgie

**Herausforderungen:**
- Script läuft als root, Notification soll für User angezeigt werden
- DISPLAY und DBUS_SESSION_BUS_ADDRESS müssen korrekt gesetzt sein
- Funktioniert nicht auf Headless-Servern (Fallback zu E-Mail)

#### 5. Mehrsprachigkeit

**Neue Sprachmeldungen (de.lang / en.lang):**
```bash
NOTIFICATION_UPDATE_SUCCESS="System-Update abgeschlossen"
NOTIFICATION_UPDATE_FAILED="Update fehlgeschlagen"
NOTIFICATION_UPGRADE_AVAILABLE="Distribution-Upgrade verfügbar"
NOTIFICATION_REBOOT_REQUIRED="Neustart erforderlich"
```

---

## Version 1.7.0 - Hooks & Automation

### 🪝 Pre/Post-Update Hooks

**Motivation:**
User möchten eigene Scripts vor und nach Updates ausführen können (z.B. Services stoppen, Backups erstellen, Monitoring pausieren).

#### 1. Hook-System

**Funktionen:**
- `run_pre_update_hooks()` - Führt Scripts vor Update aus
- `run_post_update_hooks()` - Führt Scripts nach Update aus
- Hook-Verzeichnisse: `/etc/update-hooks/pre.d/` und `/etc/update-hooks/post.d/`

**Features:**
- Scripts in alphabetischer Reihenfolge ausführen
- Exit-Code-Handling (bei Fehler abbrechen?)
- Timeout für Hooks
- Logging aller Hook-Ausführungen

#### 2. Konfiguration

```bash
# Hooks aktivieren (true/false)
ENABLE_HOOKS=true

# Hook-Verzeichnis
HOOKS_DIR="/etc/update-hooks"

# Bei Hook-Fehler abbrechen (true/false)
HOOKS_ABORT_ON_ERROR=false

# Hook-Timeout in Sekunden
HOOKS_TIMEOUT=300
```

#### 3. Beispiel-Hooks

**Pre-Update Hook (Service stoppen):**
```bash
#!/bin/bash
# /etc/update-hooks/pre.d/10-stop-services.sh
systemctl stop myapp.service
```

**Post-Update Hook (Service starten):**
```bash
#!/bin/bash
# /etc/update-hooks/post.d/90-start-services.sh
systemctl start myapp.service
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

## Version 2.0.0 - Major Features

### Container-Support
- Docker Container Updates
- LXC Container Updates
- Podman Integration

### Multi-System Management
- Mehrere Systeme zentral verwalten
- SSH-basiertes Remote-Update
- Dashboard für Status-Übersicht

### Advanced Notifications
- Webhook-Support (Slack, Discord, etc.)
- Matrix/Element Benachrichtigungen
- Telegram Bot Integration

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

- **v1.5.0** ✅ - Upgrade-Check System & Kernel-Schutz (Released 2025-12-27)
- **v1.6.0** 🔄 - Desktop-Benachrichtigungen
- **v1.7.0** 📋 - Hooks & Automation (Pre/Post-Update Hooks)
- **v1.8.0** 📋 - Backup-Integration & Optimierungen
- **v2.0.0** 📋 - Container-Support & Multi-System Management

Letzte Aktualisierung: 2025-12-27
