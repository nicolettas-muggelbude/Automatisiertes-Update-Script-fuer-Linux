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

## Version 1.6.0 - Weitere Verbesserungen

### Geplante Features

- **Pre-Update Hooks**: Custom Scripts vor Update ausführen
- **Post-Update Hooks**: Custom Scripts nach Update ausführen
- **Backup-Integration**: Optional Snapshots vor Updates
- **Update-Schedule**: Intelligente Update-Zeitpunkte
- **Bandwidth-Limit**: Download-Geschwindigkeit begrenzen
- **Delta-Updates**: Nur Unterschiede laden (wenn unterstützt)

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

Letzte Aktualisierung: 2025-12-27
