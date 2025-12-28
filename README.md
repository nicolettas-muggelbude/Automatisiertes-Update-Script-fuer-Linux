# Linux Update-Script

[![Version](https://img.shields.io/github/v/release/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux?label=Version)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![ShellCheck](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/actions/workflows/shellcheck.yml)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![GitHub Stars](https://img.shields.io/github/stars/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux?style=social)](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/stargazers)

Automatisiertes Update-Script für verschiedene Linux-Distributionen mit optionaler E-Mail-Benachrichtigung und detailliertem Logging.

## Unterstützte Distributionen

- **Debian-basiert**: Debian, Ubuntu, Linux Mint
- **RedHat-basiert**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-basiert**: openSUSE (Leap/Tumbleweed), SLES
- **Arch-basiert**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus**: Solus
- **Void Linux**: Void Linux

## Features

- ✅ **Mehrsprachigkeit**: Deutsch und Englisch (weitere Sprachen via Community)
- ✅ **Desktop-Benachrichtigungen**: Popup-Notifications für Updates, Upgrades, Fehler (v1.5.1)
- ✅ **Upgrade-Check System**: Automatische Erkennung verfügbarer Distribution-Upgrades (v1.5.0)
- ✅ **Kernel-Schutz**: Verhindert versehentliches Entfernen von Fallback-Kerneln (v1.5.0)
- ✅ Automatische Distribution-Erkennung
- ✅ Vollautomatische System-Updates
- ✅ Detailliertes Logging mit Zeitstempel
- ✅ Optionale E-Mail-Benachrichtigung (DMA empfohlen)
- ✅ Interaktives Installations-Script
- ✅ Cron-Job-Unterstützung für automatische Updates
- ✅ Optionaler automatischer Neustart
- ✅ Einfache Konfiguration über Config-Datei

## Installation

### 1. Repository klonen oder Dateien herunterladen

**Option A: Installation im Home-Verzeichnis (empfohlen)**

```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
```

**Option B: Installation in /opt (System-weit)**

```bash
cd /opt
sudo git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
sudo chown -R $USER:$USER linux-update-script
cd linux-update-script
```

### 2. Installations-Script ausführen

**Ohne sudo ausführen** (als normaler User):

```bash
./install.sh
```

> **Hinweis:** Das Installations-Script benötigt **keine** root-Rechte. Es erstellt nur die Konfigurationsdatei und richtet optional einen Cron-Job ein. Das eigentliche Update-Script (`update.sh`) wird später mit sudo ausgeführt.

Das Installations-Script führt dich interaktiv durch die Einrichtung:

**Schritt-für-Schritt:**
1. **E-Mail-Benachrichtigung** aktivieren oder deaktivieren
   - Bei Aktivierung: E-Mail-Adresse eingeben
   - Script prüft automatisch, ob Mail-Programm installiert ist
   - Zeigt distributionsspezifische Installationsanweisungen

2. **Automatischer Neustart** (optional)
   - System wird automatisch neu gestartet, wenn Updates dies erfordern

3. **Log-Verzeichnis** (optional ändern)
   - Standard: `/var/log/system-updates`
   - Script legt Verzeichnis mit sudo an, falls nötig

4. **Cron-Job einrichten** (optional)
   - Täglich um 3:00 Uhr
   - Wöchentlich (Sonntag, 3:00 Uhr)
   - Monatlich (1. des Monats, 3:00 Uhr)
   - Benutzerdefiniert
   - Script richtet automatisch im root-Crontab ein

Alle Schritte werden mit klaren Bestätigungsmeldungen quittiert.

### 3. Konfiguration überprüfen

Nach der Installation wird die Datei `config.conf` erstellt:

```bash
cat config.conf
```

## Verwendung

### Manuelles Update ausführen

```bash
sudo ./update.sh
```

Das Script führt automatisch folgende Schritte durch:
1. System-Updates installieren
2. Prüfung auf verfügbare Distribution-Upgrades
3. Optional: E-Mail-Benachrichtigung versenden

### Distribution-Upgrade durchführen

**NEU in v1.5.0:** Das Script kann jetzt auch Distribution-Upgrades erkennen und durchführen.

#### Automatischer Upgrade-Check

Nach jedem erfolgreichen Update prüft das Script automatisch, ob ein Distribution-Upgrade verfügbar ist:

```bash
sudo ./update.sh
# [INFO] System-Update erfolgreich abgeschlossen
# [INFO] Prüfe auf verfügbare Distribution-Upgrades
# [INFO] Upgrade verfügbar: Ubuntu 22.04 → Ubuntu 24.04
# [INFO] Für Upgrade ausführen: sudo ./update.sh --upgrade
```

#### Manuelles Upgrade

Um ein verfügbares Distribution-Upgrade durchzuführen:

```bash
sudo ./update.sh --upgrade
```

Das Script zeigt eine Backup-Warnung und fragt nach Bestätigung:

```
[WARNUNG] Erstelle ein Backup vor dem Upgrade!
Möchtest du das Upgrade durchführen? [j/N]: j
[INFO] Starte Upgrade zu Ubuntu 24.04
[INFO] Distribution-Upgrade erfolgreich abgeschlossen
```

#### Unterstützte Distribution-Upgrades

- **Debian/Ubuntu**: Erkennt neue Release-Versionen (z.B. Ubuntu 22.04 → 24.04)
- **Fedora**: Erkennt neue Fedora-Versionen (z.B. Fedora 39 → 40)
- **Arch/Manjaro**: Prüft auf wichtige Updates (Rolling Release)
- **Solus**: Prüft auf ausstehende Updates (Rolling Release)

### Hilfe anzeigen

```bash
sudo ./update.sh --help
```

### Automatische Updates via Cron

Während der Installation kannst du einen Cron-Job einrichten. Das Script richtet den Cron-Job automatisch im **root-Crontab** ein (du wirst einmal nach dem sudo-Passwort gefragt).

**Verfügbare Optionen:**
- Täglich um 3:00 Uhr
- Wöchentlich (Sonntag, 3:00 Uhr)
- Monatlich (1. des Monats, 3:00 Uhr)
- Benutzerdefiniert

**Root-Cron-Jobs anzeigen:**
```bash
sudo crontab -l
```

**Root-Cron-Jobs bearbeiten:**
```bash
sudo crontab -e
```

## Mehrsprachigkeit

Das Script unterstützt mehrere Sprachen. Die Sprache wird automatisch erkannt oder kann manuell konfiguriert werden.

### Verfügbare Sprachen

- **Deutsch** (de) - German
- **English** (en) - English

Weitere Sprachen können von der Community beigetragen werden! Siehe `lang/README.md` für Anleitung.

### Sprache einstellen

**Option 1: Automatische Erkennung (Standard)**

Das Script erkennt automatisch die System-Sprache aus der `LANG` Umgebungsvariable.

**Option 2: Manuelle Einstellung**

In der `config.conf`:
```bash
# Sprache (auto|de|en)
LANGUAGE=de     # Deutsch
LANGUAGE=en     # English
LANGUAGE=auto   # Automatisch
```

**Option 3: Temporär für einen Lauf**
```bash
LANGUAGE=en sudo ./update.sh
```

### Installation

Während der Installation (`./install.sh`) wirst du nach deiner bevorzugten Sprache gefragt.

## Konfiguration

Die Konfigurationsdatei `config.conf` enthält folgende Optionen:

```bash
# Sprache (auto|de|en)
LANGUAGE=auto

# E-Mail-Benachrichtigung aktivieren (true/false)
ENABLE_EMAIL=false

# E-Mail-Empfänger
EMAIL_RECIPIENT="admin@domain.de"

# Log-Verzeichnis
LOG_DIR="/var/log/system-updates"

# Automatischer Neustart bei Bedarf (true/false)
AUTO_REBOOT=false

# Kernel-Schutz (true/false)
# Verhindert autoremove wenn zu wenige Kernel installiert sind
KERNEL_PROTECTION=true

# Minimale Anzahl stabiler Kernel (Standard: 3)
MIN_KERNELS=3

# Upgrade-Check aktivieren (true/false)
# Prüft nach regulären Updates, ob Distribution-Upgrades verfügbar sind
ENABLE_UPGRADE_CHECK=true

# Automatisches Upgrade durchführen (true/false)
# WARNUNG: Kann Breaking Changes verursachen! Nur für erfahrene User
AUTO_UPGRADE=false

# Upgrade-Benachrichtigungen per E-Mail (true/false)
UPGRADE_NOTIFY_EMAIL=true

# Desktop-Benachrichtigungen aktivieren (true/false)
ENABLE_DESKTOP_NOTIFICATION=true

# Notification-Dauer in Millisekunden
NOTIFICATION_TIMEOUT=5000
```

### Konfiguration ändern

Option 1: Installations-Script erneut ausführen
```bash
./install.sh
```

Option 2: Config-Datei manuell bearbeiten
```bash
nano config.conf
```

## E-Mail-Benachrichtigung

### Voraussetzungen

Für E-Mail-Benachrichtigungen benötigst du:

1. **Mail-Client** (mail oder mailx)
2. **MTA (Mail Transfer Agent)**

### Empfohlene MTA-Lösung: DMA (DragonFly Mail Agent)

**DMA** ist die **einfachste und beste Lösung** für lokale E-Mail-Benachrichtigungen:

✅ **Vorteile:**
- Keine Konfiguration nötig
- Kein laufender Dienst
- Kein offener Port (25)
- Keine Queue im Hintergrund
- Perfekt für lokale Mails (cron, mail)
- Funktioniert sofort nach Installation

**Debian/Ubuntu/Mint:**
```bash
# DMA installieren (EMPFOHLEN)
sudo apt-get install dma

# Das war's! DMA funktioniert sofort für lokale Mails
```

### Alternative MTAs

Falls DMA nicht verfügbar oder spezielle Anforderungen bestehen:

**ssmtp (einfach, für externe SMTP-Server):**
```bash
sudo apt-get install ssmtp
# Konfiguration in /etc/ssmtp/ssmtp.conf erforderlich
```

**postfix (vollwertiger MTA):**
```bash
sudo apt-get install postfix
# Während Installation: "Internet Site" wählen
```

**RHEL/Fedora/CentOS:**
```bash
# Mail-Client installieren
sudo dnf install mailx

# Einfacher MTA
sudo dnf install ssmtp

# ODER vollwertiger MTA
sudo dnf install postfix
```

**openSUSE/SUSE:**
```bash
sudo zypper install mailx
sudo zypper install postfix
```

**Arch Linux/Manjaro:**
```bash
# Mail-Client installieren
sudo pacman -S mailutils

# Einfacher MTA
sudo pacman -S ssmtp

# ODER vollwertiger MTA
sudo pacman -S postfix
```

### E-Mail-Konfiguration testen

```bash
echo "Test-Nachricht" | mail -s "Test" deine-admin@domain.de
```

**Wichtig:** Wenn du die Fehlermeldung "Cannot start /usr/sbin/sendmail" siehst, ist kein MTA installiert oder konfiguriert. Das Script wird dich dann warnen:
```
[WARNUNG] E-Mail konnte nicht gesendet werden (MTA nicht konfiguriert?)
```

## Desktop-Benachrichtigungen

**NEU in v1.5.1:** Das Script zeigt Popup-Benachrichtigungen für wichtige Events!

### Funktionen

Desktop-Benachrichtigungen werden angezeigt bei:
- ✅ **Update erfolgreich**: Grüner Hinweis nach abgeschlossenem Update
- ✅ **Upgrade verfügbar**: Info über neue Distribution-Version
- ✅ **Update fehlgeschlagen**: Kritische Warnung bei Fehler
- ✅ **Neustart erforderlich**: Hinweis wenn Reboot nötig

### Voraussetzungen

```bash
# Debian/Ubuntu/Mint
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify

# Arch Linux
sudo pacman -S libnotify

# openSUSE
sudo zypper install libnotify-tools
```

### Unterstützte Desktop-Umgebungen

- GNOME
- KDE Plasma
- XFCE
- Cinnamon
- MATE
- LXQt
- Budgie

### Konfiguration

```bash
# In config.conf

# Desktop-Benachrichtigungen aktivieren
ENABLE_DESKTOP_NOTIFICATION=true

# Notification-Dauer (Millisekunden)
NOTIFICATION_TIMEOUT=5000
```

**Hinweis:** Funktioniert automatisch auch wenn Script als `sudo` ausgeführt wird - Notifications werden für den eigentlichen User angezeigt.

## Logging

Alle Updates werden in Logdateien mit Zeitstempel gespeichert:

```
/var/log/system-updates/update_YYYY-MM-DD_HH-MM-SS.log
```

### Logs anzeigen

**Interaktiver Log Viewer (empfohlen):**

```bash
./log-viewer.sh
```

Der Log Viewer bietet folgende Optionen:
1. Neueste Logdatei komplett anzeigen
2. Letzte 50 Zeilen des neuesten Logs
3. Alle Logdateien auflisten
4. Nach Fehlern in Logs suchen
5. Beenden

**Manuelle Log-Anzeige:**

Neueste Logdatei komplett:
```bash
cat /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)
```

Letzte 50 Zeilen:
```bash
tail -n 50 /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)
```

Alle Logdateien auflisten:
```bash
ls -lth /var/log/system-updates/
```

## Fehlerbehebung

### Problem: "Permission denied"

**Lösung:** Script muss als root ausgeführt werden
```bash
sudo ./update.sh
```

### Problem: "Kann Distribution nicht erkennen"

**Lösung:** Prüfen ob `/etc/os-release` existiert
```bash
cat /etc/os-release
```

### Problem: E-Mail wird nicht versendet

**Fehlermeldung: "Cannot start /usr/sbin/sendmail"**

Dies bedeutet, dass kein MTA (Mail Transfer Agent) installiert ist.

**Lösung:**
```bash
# Option 1: Einfacher MTA (ssmtp für Gmail, etc.)
sudo apt install ssmtp
sudo nano /etc/ssmtp/ssmtp.conf

# Option 2: Vollwertiger MTA
sudo apt install postfix
# Während Installation: "Internet Site" wählen
```

**Überprüfungen:**
1. Ist `mailutils` oder `mailx` installiert?
   ```bash
   which mail
   which sendmail
   ```

2. Ist ein MTA installiert?
   ```bash
   systemctl status postfix
   # oder
   dpkg -l | grep ssmtp
   ```

3. Ist die E-Mail-Adresse korrekt in `config.conf`?
   ```bash
   cat config.conf | grep EMAIL
   ```

4. Ist E-Mail aktiviert?
   ```bash
   cat config.conf | grep ENABLE_EMAIL
   ```

5. Test-E-Mail senden:
   ```bash
   echo "Test" | mail -s "Test" deine@email.de
   # Prüfe /var/log/mail.log für Fehler
   ```

### Problem: Log-Verzeichnis kann nicht erstellt werden

**Lösung:** Script beim ersten Mal als root ausführen
```bash
sudo ./update.sh
```

Oder Log-Verzeichnis manuell erstellen:
```bash
sudo mkdir -p /var/log/system-updates
sudo chown $USER:$USER /var/log/system-updates
```

### Problem: Cron-Job funktioniert nicht

**Überprüfungen:**

1. Ist der Cron-Job korrekt eingetragen?
   ```bash
   crontab -l
   ```

2. Prüfen Sie die Cron-Logs:
   ```bash
   tail -f /var/log/cron.log
   # oder
   tail -f /var/log/system-updates/cron.log
   ```

3. Script-Pfad absolut angeben:
   ```bash
   # Beispiel für Installation im Home-Verzeichnis:
   0 3 * * * /home/USERNAME/linux-update-script/update.sh

   # Beispiel für Installation in /opt:
   0 3 * * * /opt/linux-update-script/update.sh
   ```

   **Hinweis:** Ersetze `USERNAME` mit deinem tatsächlichen Benutzernamen oder verwende den absoluten Pfad zu deiner Installation.

## Kernel-Schutz

**NEU in v1.5.0:** Das Script schützt automatisch vor versehentlichem Entfernen von Fallback-Kerneln.

### Funktionsweise

- Zählt installierte stabile Kernel-Versionen vor `autoremove`
- Überspringt `autoremove` wenn weniger als `MIN_KERNELS` vorhanden
- Standard: Mindestens 3 Kernel (aktuell laufend + 2 Fallback-Versionen)
- Unterstützt Debian/Ubuntu und RHEL/Fedora

### Beispiel

```bash
sudo ./update.sh
# [INFO] Prüfe installierte Kernel-Versionen
# [INFO] Gefunden: 5 stabile Kernel-Versionen
# [INFO] Aktuell laufend: 6.5.0-28-generic
# [INFO] Genügend Kernel vorhanden, führe autoremove aus
```

Wenn zu wenige Kernel vorhanden:

```bash
# [WARNUNG] Nur 2 Kernel gefunden, überspringe autoremove zur Sicherheit
# [INFO] Minimum erforderlich: 3 stabile Kernel (aktuell + Fallbacks)
# [INFO] Kernel-Schutz aktiv: Mindestens 2 stabile Kernel werden behalten
```

### Konfiguration

```bash
# Kernel-Schutz deaktivieren (nicht empfohlen)
KERNEL_PROTECTION=false

# Mindestanzahl ändern
MIN_KERNELS=5  # Behält mehr Fallback-Kernel
```

## Sicherheitshinweise

- Das Script benötigt root-Rechte für System-Updates
- **Backup empfohlen** vor Distribution-Upgrades
- Konfigurationsdatei enthält keine sensiblen Daten
- E-Mail-Passwörter werden nicht im Script gespeichert
- Logs können sensible Systeminformationen enthalten
- Kernel-Schutz verhindert Bootprobleme durch fehlende Fallback-Kernel

## Deinstallation

### Cron-Job entfernen

```bash
crontab -e
# Zeile mit update.sh löschen
```

### Dateien entfernen

**Für Installation im Home-Verzeichnis:**
```bash
rm -rf ~/linux-update-script
sudo rm -rf /var/log/system-updates
```

**Für Installation in /opt:**
```bash
sudo rm -rf /opt/linux-update-script
sudo rm -rf /var/log/system-updates
```

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) Datei für Details.

## Support

Bei Problemen oder Fragen:
1. Prüfe die Logdateien
2. Überprüfen die Konfiguration
3. Stelle sicher, dass alle Voraussetzungen erfüllt sind

## Changelog

Die vollständige Versionshistorie findest du in der [CHANGELOG.md](CHANGELOG.md) Datei.

### Aktuelle Version: 1.5.1 (2025-12-27) - Desktop-Benachrichtigungen & DMA

**Highlights:**
- ✅ **NEU: Desktop-Benachrichtigungen** - Popup-Notifications für wichtige Events
  - Benachrichtigungen bei Update-Erfolg, Upgrade verfügbar, Fehler, Neustart
  - Funktioniert automatisch auch als root
  - Unterstützt GNOME, KDE, XFCE, Cinnamon, MATE, LXQt, Budgie
- ✅ **NEU: DMA-Empfehlung** - Einfachste Lösung für E-Mail-Benachrichtigungen
  - Keine Konfiguration nötig
  - Kein laufender Dienst, kein offener Port
  - Perfekt für lokale Mails
- ✅ Upgrade-Check System (v1.5.0)
- ✅ Kernel-Schutz (v1.5.0)
- ✅ ShellCheck-konform (keine Warnungen)

**Version 1.4.0:**
- ✅ ShellCheck-Warnungen behoben
- ✅ Code-Qualität verbessert

**Version 1.3.0:**
- ✅ Solus Unterstützung (Community Beitrag von @mrtoadie)
- ✅ Void Linux Unterstützung (Community Beitrag von @tbreswald)
- ✅ GitHub Repository professionell eingerichtet

**Siehe [CHANGELOG.md](CHANGELOG.md) für alle Details**
