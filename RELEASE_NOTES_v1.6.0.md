# Release Notes - Version 1.6.0

**Release-Datum:** 2026-01-24
**Codename:** XDG-Konformität & Config-Migration

## 🎯 Hauptfeatures

### XDG Base Directory Specification

Version 1.6.0 bringt **volle XDG-Konformität** für Konfigurationsdateien - ein häufig gewünschtes Feature aus der Community!

#### Was ist neu?

**Neue Config-Location (Linux-Standard-konform):**
```bash
# Alt (v1.5.1 und früher):
~/linux-update-script/config.conf

# Neu (v1.6.0+):
~/.config/linux-update-script/config.conf
```

**Warum ist das wichtig?**
- ✅ **Config bleibt erhalten** bei Script-Updates (git pull)
- ✅ **Alle Configs an einem Ort** (`~/.config/`)
- ✅ **Linux-Standard-konform** (XDG Base Directory Specification)
- ✅ **Multi-User-fähig** (jeder User eigene Config)
- ✅ **Saubere Trennung** von Code und Konfiguration

## 🔄 Automatische Migration

### Nahtloser Übergang ohne manuelle Schritte!

Beim ersten Start nach dem Update auf v1.6.0:

```bash
sudo ./update.sh
# [INFO] Migriere Konfiguration nach ~/.config/ (XDG-Standard)
# [INFO] Konfiguration erfolgreich migriert nach: /home/user/.config/linux-update-script/config.conf
# [INFO] Alte Konfiguration gesichert als: /home/user/linux-update-script/config.conf.migrated
```

**Was passiert automatisch:**
1. Script erkennt alte Config (`./config.conf`)
2. Erstellt `~/.config/linux-update-script/`
3. Kopiert Config in neue Location
4. Benennt alte Config um zu `.migrated` (Backup)
5. Script läuft normal weiter mit neuer Config

**Keine manuellen Schritte nötig!** 🎉

## 📁 Fallback-Mechanismus

### Intelligente Config-Suche

Das Script sucht Config-Dateien in folgender Reihenfolge:

1. **`~/.config/linux-update-script/config.conf`** (XDG, bevorzugt)
2. **`/etc/linux-update-script/config.conf`** (system-weit)
3. **`./config.conf`** (alt, deprecated)

**Beispiel:**
```bash
# Neue Installation:
./install.sh
# Erstellt Config in ~/.config/linux-update-script/config.conf

# Update von v1.5.1:
sudo ./update.sh
# Migriert automatisch ./config.conf → ~/.config/linux-update-script/config.conf
```

## 🆕 Neue Features

### Config-Migration
- ✅ Automatische Migration beim ersten Start
- ✅ Alte Config als Backup erhalten (`.migrated`)
- ✅ Vollständig backwards-kompatibel
- ✅ Keine Breaking Changes

### install.sh Verbesserungen
- ✅ Erstellt Config direkt in `~/.config/`
- ✅ Zeigt neuen Config-Pfad während Installation
- ✅ Migriert alte Config wenn vorhanden
- ✅ Kein Unterschied im Workflow für User

### Mehrsprachigkeit
- ✅ 8 neue Sprachmeldungen für Config-Migration
- ✅ Deutsch und Englisch
- ✅ Konsistente Terminologie

## 📊 Technische Details

### Neue Funktionen in update.sh

**`migrate_config()`**
- Führt automatische Migration durch
- Prüft ob Migration nötig
- Erstellt Backup der alten Config
- Detailliertes Logging

**`find_config_file()`**
- Sucht Config mit Fallback-Mechanismus
- Respektiert `$XDG_CONFIG_HOME`
- Unterstützt system-weite Config

### Neue Sprachmeldungen

**Deutsch (de.lang):**
- `MSG_CONFIG_MIGRATE_START` - "Migriere Konfiguration nach ~/.config/ (XDG-Standard)"
- `MSG_CONFIG_MIGRATE_SUCCESS` - "Konfiguration erfolgreich migriert nach: %s"
- `MSG_CONFIG_MIGRATE_BACKUP` - "Alte Konfiguration gesichert als: %s"
- `MSG_CONFIG_MIGRATE_FAILED` - "Fehler bei Config-Migration: %s"
- `MSG_CONFIG_OLD_LOCATION` - "HINWEIS: Konfiguration im alten Pfad gefunden"
- `MSG_CONFIG_OLD_DEPRECATED` - "Der alte Config-Pfad ist veraltet und wird in v2.0.0 entfernt"
- `MSG_CONFIG_LOCATION` - "Verwende Konfiguration von: %s"
- `MSG_CONFIG_NOT_FOUND` - "Keine Konfiguration gefunden. Bitte install.sh ausführen."

**Englisch (en.lang):**
- Vollständige Übersetzungen aller neuen Meldungen

## ⚠️ Deprecation Notice

### Alte Config-Location wird in v2.0.0 entfernt

**Aktueller Status (v1.6.0):**
- ✅ Alte Location (`./config.conf`) funktioniert weiterhin
- ✅ Automatische Migration beim ersten Start
- ⚠️ Warnung bei Verwendung alter Location

**Geplant für v2.0.0:**
- ❌ Alte Location wird nicht mehr unterstützt
- ✅ Migration wird obligatorisch
- ✅ 6 Monate Vorlaufzeit für Migration

## 🔧 Installation & Update

### Neue Installation

```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
./install.sh

# Config wird automatisch erstellt in:
# ~/.config/linux-update-script/config.conf
```

### Update von v1.5.1

```bash
cd ~/linux-update-script
git pull

# Beim ersten Start:
sudo ./update.sh

# Migration passiert automatisch!
```

### Manuelle Migration (optional)

Falls du die Migration manuell durchführen möchtest:

```bash
# Config-Verzeichnis erstellen
mkdir -p ~/.config/linux-update-script

# Config kopieren
cp ~/linux-update-script/config.conf ~/.config/linux-update-script/config.conf

# Alte Config umbenennen (optional)
mv ~/linux-update-script/config.conf ~/linux-update-script/config.conf.migrated
```

## 🎓 Für Entwickler

### Neue Umgebungsvariablen

```bash
# XDG_CONFIG_HOME wird respektiert
XDG_CONFIG_HOME=~/my-configs ./update.sh
# Sucht in: ~/my-configs/linux-update-script/config.conf
```

### Config-Pfad-Logik

```bash
# XDG-konforme Pfade
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CONFIG_DIR="${XDG_CONFIG_HOME}/linux-update-script"
XDG_CONFIG_FILE="${XDG_CONFIG_DIR}/config.conf"
SYSTEM_CONFIG_FILE="/etc/linux-update-script/config.conf"
OLD_CONFIG_FILE="${SCRIPT_DIR}/config.conf"
```

## 🚀 Nächste Schritte

### Roadmap v1.7.0 - Hooks & Automation

Bereits in Planung:
- Pre/Post-Update Hooks
- Custom Scripts vor/nach Updates ausführen
- Hook-Verzeichnisse (`/etc/update-hooks/pre.d/`, `post.d/`)

### Roadmap v2.0.0 - Major Refactoring

Große Änderungen geplant:
- Modulare Code-Architektur
- Test-Framework (bats-core)
- Container-Support
- Multi-System Management

Siehe [ROADMAP.md](ROADMAP.md) für Details.

## 📋 Vollständiger Changelog

Siehe [CHANGELOG.md](CHANGELOG.md) für detaillierte Änderungen.

## 🙏 Community

Diese Version basiert auf Community-Feedback:
- **@tbreswald** - Vorschlag für XDG-Konformität

Vielen Dank für eure Beiträge! 🎉

## 📞 Support

Bei Problemen oder Fragen:
1. Prüfe die Logdateien
2. Überprüfe die Konfiguration
3. Stelle sicher, dass alle Voraussetzungen erfüllt sind
4. Öffne ein Issue auf GitHub

## 📜 Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

---

**Happy Updating! 🚀**

Version 1.6.0 - XDG-Konformität & Config-Migration
Released: 2026-01-24
