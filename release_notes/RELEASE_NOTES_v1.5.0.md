# Release Notes - Version 1.5.0

**Veröffentlicht am:** 2025-12-27
**Codename:** Sicherheit & Upgrade-Check

---

## 🎉 Highlights

Version 1.5.0 bringt zwei wichtige neue Features, die die Sicherheit und Funktionalität des Update-Scripts deutlich verbessern:

### 🔄 Upgrade-Check System

Das Script kann jetzt automatisch Distribution-Upgrades erkennen und durchführen! Nach jedem erfolgreichen Update prüft das Script, ob eine neue Distribution-Version verfügbar ist und informiert dich darüber.

**Beispiel:**
```bash
sudo ./update.sh
# [INFO] System-Update erfolgreich abgeschlossen
# [INFO] Prüfe auf verfügbare Distribution-Upgrades
# [INFO] Upgrade verfügbar: Ubuntu 22.04 → Ubuntu 24.04
# [INFO] Für Upgrade ausführen: sudo ./update.sh --upgrade
```

**Unterstützte Distributionen:**
- ✅ Debian/Ubuntu - Erkennt neue Release-Versionen
- ✅ Fedora - Erkennt neue Fedora-Versionen
- ✅ Arch/Manjaro - Prüft auf wichtige Updates (Rolling Release)
- ✅ Solus - Prüft auf ausstehende Updates (Rolling Release)

### 🛡️ Kernel-Schutz

Das Script schützt jetzt automatisch vor versehentlichem Entfernen von Fallback-Kerneln. Wenn weniger als 3 Kernel installiert sind, wird `autoremove` übersprungen, um sicherzustellen, dass du immer genug Kernel-Versionen für Notfälle hast.

**Beispiel:**
```bash
sudo ./update.sh
# [INFO] Prüfe installierte Kernel-Versionen
# [INFO] Gefunden: 5 stabile Kernel-Versionen
# [INFO] Aktuell laufend: 6.5.0-28-generic
# [INFO] Genügend Kernel vorhanden, führe autoremove aus
```

Bei zu wenigen Kerneln:
```bash
# [WARNUNG] Nur 2 Kernel gefunden, überspringe autoremove zur Sicherheit
# [INFO] Minimum erforderlich: 3 stabile Kernel (aktuell + Fallbacks)
# [INFO] Kernel-Schutz aktiv: Mindestens 2 stabile Kernel werden behalten
```

---

## ✨ Neue Features

### Command-Line Interface

- **`--upgrade`** - Führt Distribution-Upgrade manuell durch
- **`--help` / `-h`** - Zeigt Hilfe und verfügbare Optionen an

### Konfigurationsoptionen

Neue Parameter in `config.conf`:

```bash
# Kernel-Schutz (true/false)
KERNEL_PROTECTION=true

# Minimale Anzahl stabiler Kernel (Standard: 3)
MIN_KERNELS=3

# Upgrade-Check aktivieren (true/false)
ENABLE_UPGRADE_CHECK=true

# Automatisches Upgrade durchführen (true/false)
# WARNUNG: Kann Breaking Changes verursachen!
AUTO_UPGRADE=false

# Upgrade-Benachrichtigungen per E-Mail (true/false)
UPGRADE_NOTIFY_EMAIL=true
```

### E-Mail-Benachrichtigungen

- Automatische E-Mail-Benachrichtigung wenn Distribution-Upgrade verfügbar
- Enthält Versions-Informationen und Upgrade-Anleitung
- Backup-Warnung in E-Mail enthalten

### Mehrsprachigkeit

- 18 neue Sprachmeldungen für Upgrade-Check und Kernel-Schutz
- Alle Features vollständig in Deutsch und Englisch verfügbar

---

## 🔧 Technische Details

### Upgrade-Check Funktionen

- `check_upgrade_available()` - Zentrale Dispatcher-Funktion
- `check_upgrade_solus()` - Solus-spezifischer Check
- `check_upgrade_arch()` - Arch-spezifischer Check
- `check_upgrade_debian()` - Debian/Ubuntu Release-Check
- `check_upgrade_fedora()` - Fedora Version-Check
- `perform_upgrade()` - Upgrade-Durchführung mit Bestätigung

### Kernel-Schutz Funktionen

- `safe_autoremove()` - Sichere autoremove-Funktion mit Kernel-Check
- `count_stable_kernels_debian()` - Zählt Kernel auf Debian/Ubuntu
- `count_stable_kernels_redhat()` - Zählt Kernel auf RHEL/Fedora

### Rückgabewerte

Der Upgrade-Check verwendet folgende Rückgabewerte:
- `0` - Kein Upgrade verfügbar
- `1` - Fehler oder nicht unterstützt
- `2` - Updates verfügbar (Rolling Release)
- `3` - Major-Upgrade verfügbar

---

## 🔒 Sicherheit

- **Kernel-Schutz**: Verhindert Bootprobleme durch fehlende Fallback-Kernel
- **Backup-Warnung**: Vor jedem Distribution-Upgrade
- **Benutzer-Bestätigung**: Manuelle Bestätigung vor kritischen Upgrades
- **Opt-in System**: AUTO_UPGRADE standardmäßig deaktiviert
- **ShellCheck-konform**: Keine Code-Warnungen

---

## 📚 Dokumentation

- **README.md** - Vollständig aktualisiert mit allen neuen Features
- **CHANGELOG.md** - Detaillierte Versionshistorie
- **ROADMAP.md** - Upgrade-Check System als implementiert markiert
- **.claude/CLAUDE.md** - Technische Projekt-Dokumentation

---

## 🚀 Upgrade-Anleitung

### Von v1.4.0 auf v1.5.0

1. **Repository aktualisieren:**
   ```bash
   cd ~/linux-update-script
   git pull origin main
   ```

2. **Konfiguration aktualisieren (optional):**
   ```bash
   # Neue Parameter zu config.conf hinzufügen
   cat config.conf.example >> config.conf
   nano config.conf  # Duplikate entfernen und anpassen
   ```

3. **Script testen:**
   ```bash
   sudo ./update.sh --help
   sudo ./update.sh
   ```

### Neue Installation

```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
./install.sh
```

---

## 🎯 Workflow-Beispiele

### Normales Update mit Upgrade-Check

```bash
sudo ./update.sh
# 1. Führt System-Updates durch
# 2. Prüft auf Distribution-Upgrades
# 3. Informiert über verfügbare Upgrades
```

### Manuelles Upgrade

```bash
sudo ./update.sh --upgrade
# 1. Zeigt Backup-Warnung
# 2. Fragt nach Bestätigung
# 3. Führt Distribution-Upgrade durch
```

### Automatisches Upgrade (Experten-Modus)

```bash
# In config.conf:
AUTO_UPGRADE=true

sudo ./update.sh
# Führt automatisch Upgrade durch wenn verfügbar
```

---

## ⚠️ Wichtige Hinweise

1. **Backup vor Upgrades:** Erstelle IMMER ein Backup vor Distribution-Upgrades!
2. **Kernel-Schutz:** Standardmäßig aktiviert und empfohlen
3. **AUTO_UPGRADE:** Nur für erfahrene User - kann Breaking Changes verursachen
4. **Testing:** Diese Version wurde getestet auf Debian, Ubuntu, Fedora, Arch

---

## 🐛 Bekannte Einschränkungen

- Rolling Release Distributionen (Arch, Solus) haben keine "Major-Upgrades" im klassischen Sinne
- Upgrade-Check für SUSE noch nicht implementiert (geplant für v1.6.0)
- Void Linux Upgrade-Check noch nicht implementiert (geplant für v1.6.0)

---

## 🙏 Danksagungen

- **Community-Feedback** für die Upgrade-Check Idee
- **ShellCheck** für Code-Qualitäts-Verbesserungen
- Alle Tester und Contributors

---

## 📝 Vollständiges Changelog

Siehe [CHANGELOG.md](CHANGELOG.md) für alle Details.

---

## 🔗 Links

- **GitHub Repository:** https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux
- **Dokumentation:** [README.md](README.md)
- **Roadmap:** [ROADMAP.md](ROADMAP.md)
- **Issues:** https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues

---

**Viel Erfolg mit v1.5.0! 🎉**

Bei Fragen oder Problemen bitte ein Issue auf GitHub öffnen.
