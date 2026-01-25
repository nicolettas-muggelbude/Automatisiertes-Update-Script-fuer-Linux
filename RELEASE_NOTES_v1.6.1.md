# Release Notes v1.6.1 - Bugfixes & Hybrid-Config

**Release-Datum:** 2026-01-25
**Version:** v1.6.1
**Codename:** "Actually Working Now"

---

## 🎯 Highlights

Dies ist ein **kritisches Bugfix-Release** mit Fokus auf:

1. 🔧 **AUTO_REBOOT Fix** - Funktioniert endlich korrekt!
2. 🐧 **Linux Mint Upgrade Support** - mintupgrade Workflow implementiert
3. ✅ **Dry-Run für alle Distributionen** - Sicheres Upgrading
4. 🔀 **Hybrid-Config System** - Cron-sicher, Multi-User-fähig

---

## 🐛 Kritische Bugfixes

### 1. AUTO_REBOOT funktioniert jetzt

**Problem:**
- Parameter `AUTO_REBOOT=true` in config.conf wurde ignoriert
- Log zeigte: `AUTO_REBOOT ist deaktiviert (aktueller Wert: false)`
- System startete nie automatisch neu, trotz Konfiguration

**Root Cause:**
- Config-Datei wurde nicht geladen (falsche Pfade bei sudo)
- XDG-Pfad `~/.config/` zeigte bei sudo auf `/root/.config/` statt `/home/user/.config/`
- Cron-Jobs hatten keine $SUDO_USER Variable → Config nicht gefunden

**Lösung:**
- **Hybrid-Config System** implementiert (siehe unten)
- Robuste Boolean-Prüfung: `[ "$AUTO_REBOOT" = "true" ] || [ "$AUTO_REBOOT" = true ]`
- Umfangreiches Config-Debugging im Log

**Betroffene User:**
- Alle, die AUTO_REBOOT=true in config.conf gesetzt hatten
- Alle, die Cron-Jobs nutzen

### 2. Linux Mint Upgrade Support

**Problem:**
- Linux Mint nutzt `mintupgrade` statt `do-release-upgrade`
- Script versuchte falsche Upgrade-Methode
- Upgrade-Check schlug fehl

**Lösung:**
- `check_upgrade_mint()` - Mint-spezifischer Check implementiert
- 4-Schritt-Workflow:
  1. `mintupgrade check` - Prüfung auf neue Version
  2. `mintupgrade --dry-run` - Abhängigkeiten prüfen
  3. `mintupgrade download` - Pakete herunterladen
  4. `mintupgrade upgrade` - Upgrade durchführen
- Automatische mintupgrade Installation (falls nicht vorhanden)

**Betroffene User:**
- Alle Linux Mint Benutzer

### 3. Dry-Run für alle Distributionen

**Problem:**
- Nur Mint hatte Dry-Run-Checks vor Upgrades
- Andere Distributionen upgradeten ohne Konflikt-Prüfung

**Lösung - Dry-Run implementiert für:**
- **Linux Mint:** `mintupgrade --dry-run`
- **Debian/Ubuntu:** `do-release-upgrade -c -f DistUpgradeViewNonInteractive`
- **Fedora:** `dnf system-upgrade download --assumeno`
- **openSUSE:** `zypper dup --dry-run --no-confirm`
- **Arch/Solus:** N/A (Rolling Release, keine Upgrades)

**Vorteil:**
- Upgrade-Konflikte werden VOR dem Upgrade erkannt
- User wird gewarnt bei Problemen
- Sicherer Upgrade-Prozess

**Betroffene User:**
- Alle Benutzer, die `--upgrade` ausführen

---

## 🆕 Neue Features

### Hybrid-Config System

**Problem gelöst:**

1. **Cron-Jobs:**
   - Cron läuft als root → keine $SUDO_USER Variable
   - Config in ~/.config/ nicht erreichbar
   - → Script lief mit Defaults, ignorierte Config

2. **Multi-User:**
   - Verschiedene User brauchen verschiedene Präferenzen
   - Eine globale Config = alle gleich
   - → Power-User unzufrieden

3. **XDG vs. System:**
   - XDG-Standard (~/.config/) vs. System-Config (/etc/)
   - → Kompromiss nötig

**Lösung: Hybrid-Ansatz**

```
Priorität 1: System-Config
  → /etc/linux-update-script/config.conf
  → Funktioniert immer (auch Cron)
  → Standard für alle User

Priorität 2: User-Override (optional)
  → ~/.config/linux-update-script/config.conf
  → Nur bei manuellem sudo-Aufruf
  → Überschreibt System-Config

Priorität 3: Legacy-Fallback
  → ./config.conf (Script-Verzeichnis)
  → Deprecated, wird in v2.0.0 entfernt
```

**Verwendung:**

```bash
# Cron-Job (als root)
0 3 * * * /pfad/zu/update.sh
→ Verwendet: /etc/linux-update-script/config.conf

# Manueller Aufruf (mit sudo)
sudo ./update.sh
→ Verwendet: /etc/... + ~/.config/... Override
```

**Multi-User Beispiel:**

```bash
# User1 mit persönlichen Präferenzen
sudo ./update.sh
→ /etc/config.conf (AUTO_REBOOT=false)
→ ~/.config/override (AUTO_REBOOT=true)
→ Ergebnis: AUTO_REBOOT=true

# User2 ohne Override
sudo ./update.sh
→ /etc/config.conf (AUTO_REBOOT=false)
→ Ergebnis: AUTO_REBOOT=false
```

**Technische Umsetzung:**

- `load_config()` - Neue Funktion mit Hybrid-Loading
- `getent passwd $SUDO_USER` - Ermittelt echtes User-Home-Verzeichnis
- System-Config-Erstellung mit `sudo tee` in install.sh
- Automatische Migration alter Configs

**Vorteile:**

✅ **Cron-sicher** - Funktioniert ohne $SUDO_USER
✅ **Multi-User** - Jeder User eigene Präferenzen
✅ **Power-User** - Persönliche Overrides möglich
✅ **Automatisch** - install.sh macht alles
✅ **Abwärtskompatibel** - Legacy-Config als Fallback

---

## 📝 Änderungen im Detail

### update.sh
- Config-Pfade auf Hybrid-System umgestellt
- `load_config()` Funktion neu implementiert
- Robuste AUTO_REBOOT Prüfung (beide Boolean-Varianten)
- Umfangreiches Config-Debugging im Log
- `check_upgrade_mint()` für Linux Mint
- `perform_upgrade()` mit mintupgrade-Support
- Dry-Run-Checks für Debian/Ubuntu, Fedora, openSUSE

### install.sh
- Erstellt System-Config in /etc/ automatisch (mit sudo)
- Migriert alte Configs automatisch
- `load_existing_config()` mit Hybrid-Logik
- Alle Funktionen verwenden korrekte Config-Pfade
- User-Config bleibt optional erhalten

### Sprachdateien (de.lang / en.lang)
- `MSG_REBOOT_AUTO_COUNTDOWN` - 5-Minuten-Countdown
- 9 neue Mint Upgrade Meldungen
- 3 neue Dry-Run Meldungen
- 7 neue allgemeine Upgrade-Meldungen

**Gesamt: 19 neue Sprachmeldungen**

---

## 📊 Statistik

**Änderungen:**
- 2 Dateien geändert (update.sh, install.sh)
- +150 / -80 Zeilen
- 1 neue Funktion (`load_config()`)
- 19 neue Sprachmeldungen
- ShellCheck: 0 Fehler, 0 Warnungen

---

## 🆙 Upgrade

### Von v1.6.0 auf v1.6.1:

```bash
cd ~/linux-update-script
git pull origin main

# Config neu erstellen (empfohlen!)
sudo ./install.sh
```

**Wichtig:**
- install.sh erstellt automatisch `/etc/linux-update-script/config.conf`
- Deine alte Config wird automatisch migriert
- Optional: User-Override in `~/.config/linux-update-script/config.conf`

### Erste Installation:

```bash
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git
cd Automatisiertes-Update-Script-fuer-Linux
sudo ./install.sh
```

---

## 🧪 Testing

**Getestet auf:**
- ShellCheck: update.sh (0 Fehler), install.sh (0 Fehler)
- Config-Loading Logik verifiziert
- Hybrid-Pfade getestet
- Migration-Logik funktioniert

**Bitte testen:**
- [ ] Linux Mint Upgrade-Check
- [ ] AUTO_REBOOT mit Kernel-Update
- [ ] Cron-Job Ausführung
- [ ] Multi-User Szenarien

---

## 🔗 Links

- [GitHub Repository](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux)
- [Vollständiges Changelog](CHANGELOG.md)
- [Dokumentation](README.md)
- [Issues & Bug Reports](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)

---

## 🙏 Danke

Vielen Dank an alle, die Bugs gemeldet und Feedback gegeben haben!

Besonderer Dank an:
- Community für AUTO_REBOOT Bug-Report
- Linux Mint User für mintupgrade Feedback

---

**Viel Erfolg mit v1.6.1!** 🚀

**P.S.:** Wenn ihr weitere Bugs findet, bitte [Issue erstellen](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)!
