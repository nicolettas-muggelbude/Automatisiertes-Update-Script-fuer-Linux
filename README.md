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

- ✅ Automatische Distribution-Erkennung
- ✅ Vollautomatische System-Updates
- ✅ Detailliertes Logging mit Zeitstempel
- ✅ Optionale E-Mail-Benachrichtigung
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

## Konfiguration

Die Konfigurationsdatei `config.conf` enthält folgende Optionen:

```bash
# E-Mail-Benachrichtigung aktivieren (true/false)
ENABLE_EMAIL=false

# E-Mail-Empfänger
EMAIL_RECIPIENT="admin@domain.de"

# Log-Verzeichnis
LOG_DIR="/var/log/system-updates"

# Automatischer Neustart bei Bedarf (true/false)
AUTO_REBOOT=false
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
2. **MTA (Mail Transfer Agent)** wie postfix, ssmtp oder sendmail

**Debian/Ubuntu/Mint:**
```bash
# Mail-Client installieren
sudo apt-get install mailutils

# Einfacher MTA (ssmtp für Gmail, etc.)
sudo apt-get install ssmtp
# Dann /etc/ssmtp/ssmtp.conf konfigurieren

# ODER vollwertiger MTA
sudo apt-get install postfix
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
   0 3 * * * /opt/linux-update-script/update.sh
   ```

## Sicherheitshinweise

- Das Script benötigt root-Rechte für System-Updates
- Konfigurationsdatei enthält keine sensiblen Daten
- E-Mail-Passwörter werden nicht im Script gespeichert
- Logs können sensible Systeminformationen enthalten

## Deinstallation

### Cron-Job entfernen

```bash
crontab -e
# Zeile mit update.sh löschen
```

### Dateien entfernen

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

### Aktuelle Version: 1.3.0 (2025-12-16)

**Highlights:**
- ✅ **NEU: Solus Unterstützung** (Community Beitrag von @mrtoadie)
- ✅ **NEU: Void Linux Unterstützung** (Community Beitrag von @tbreswald)
- ✅ Verbesserte Code-Qualität durch Behebung von ShellCheck-Warnungen
- ✅ GitHub Repository professionell eingerichtet (Issue Templates, PR Template, GitHub Actions)

**Version 1.2.0:**
- ✅ Arch Linux Unterstützung (Arch, Manjaro, EndeavourOS, Garuda, ArcoLinux)
- ✅ Verbesserte E-Mail-Benachrichtigung mit Exit-Code-Prüfung
- ✅ Erweiterte Fehlerbehandlung bei fehlender MTA-Konfiguration

**Siehe [CHANGELOG.md](CHANGELOG.md) für alle Details**
