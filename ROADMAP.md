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

### 🔄 Geplante Features

#### Upgrade-Check System

**Motivation:**
Einige Distributionen (besonders Rolling Releases wie Solus) bieten nicht automatisch ein Upgrade auf neue Versionen an. Ein Upgrade-Check würde Users darüber informieren und optional das Upgrade durchführen.

#### 1. Upgrade-Check Framework
```bash
check_upgrade_available() {
    # Distributionsspezifische Upgrade-Checks
    case "$DISTRO" in
        solus)
            check_upgrade_solus
            ;;
        arch|manjaro)
            check_upgrade_arch
            ;;
        # ... weitere Distributionen
    esac
}
```

#### 2. Solus Upgrade-Check (Priority)
```bash
check_upgrade_solus() {
    # Prüfen ob neue Solus-Version verfügbar
    # eopkg upgrade --check oder ähnlich
    # Bei Verfügbarkeit: User informieren
    # Optional: Automatisches Upgrade durchführen
}
```

**Technische Details:**
- Solus ist ein Rolling Release, aber Major-Updates erfordern manchmal manuelles Upgrade
- Check auf neue ISOs oder Major-Versionen
- Prüfung über eopkg oder System-API

#### 3. Weitere Distributionen

**Arch/Manjaro:**
- Check auf neue Kernel-Versionen
- Hinweis auf manuelle Interventionen (z.B. .pacnew Dateien)
- AUR-Updates (optional, wenn yay/paru installiert)

**Debian/Ubuntu:**
- Check auf neue Distribution-Releases
- `do-release-upgrade` Integration
- LTS → Non-LTS Upgrade-Optionen

**Fedora:**
- Check auf neue Fedora-Versionen
- `dnf system-upgrade` Integration

### Konfiguration (config.conf)

```bash
# Upgrade-Check aktivieren (true/false)
ENABLE_UPGRADE_CHECK=true

# Automatisches Upgrade durchführen (true/false)
# WARNUNG: Kann Breaking Changes verursachen!
AUTO_UPGRADE=false

# Upgrade-Benachrichtigung
UPGRADE_NOTIFY_EMAIL=true
UPGRADE_NOTIFY_LOG=true
```

### User-Workflow

1. **Automatischer Check während Update:**
   ```bash
   sudo ./update.sh
   # [INFO] System-Update abgeschlossen
   # [INFO] Upgrade verfügbar: Solus 4.4 → Solus 4.5
   # [INFO] Führe aus: sudo ./update.sh --upgrade
   ```

2. **Manuelles Upgrade:**
   ```bash
   sudo ./update.sh --upgrade
   # [INFO] Starte Upgrade zu Solus 4.5
   # [WARNUNG] Erstelle Backup vor dem Upgrade!
   # Fortfahren? [j/N]:
   ```

3. **Automatisches Upgrade (Config):**
   ```bash
   # AUTO_UPGRADE=true in config.conf
   sudo ./update.sh
   # Führt automatisch Upgrade durch wenn verfügbar
   ```

### Sicherheitsaspekte

- ⚠️ **Backup-Warnung** vor jedem Upgrade
- ⚠️ **Dry-Run Option** zum Testen
- ⚠️ **Rollback-Information** in Logs
- ⚠️ **Opt-in** (standardmäßig nur Benachrichtigung)

### E-Mail-Benachrichtigung

```
Betreff: Upgrade verfügbar für Solus

Ein Upgrade ist verfügbar:
Aktuelle Version: Solus 4.4
Neue Version: Solus 4.5

Changelogs: https://getsol.us/2024/...

Zum Upgraden:
sudo /pfad/zum/update.sh --upgrade

Hinweis: Erstelle vor dem Upgrade ein Backup!
```

### Testing-Strategie

1. **Solus** (Priorität - User-Request)
2. **Arch/Manjaro** (Rolling Release)
3. **Ubuntu** (LTS Upgrades)
4. **Fedora** (Versions-Upgrades)
5. Weitere nach Community-Feedback

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
- [ ] Upgrade-Check System (Solus Priority) - @User Request
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

Letzte Aktualisierung: 2025-12-24
