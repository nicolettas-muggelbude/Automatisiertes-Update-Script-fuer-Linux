# Linux Update-Script

Automatisiertes Update-Script für verschiedene Linux-Distributionen mit optionaler E-Mail-Benachrichtigung und detailliertem Logging.

## Unterstützte Distributionen

- **Debian-basiert**: Debian, Ubuntu, Linux Mint
- **RedHat-basiert**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-basiert**: openSUSE (Leap/Tumbleweed), SLES

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

```bash
cd /opt
git clone <https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git> linux-update-script
cd linux-update-script
```

### 2. Installations-Script ausführen

```bash
./install.sh
```

Das Installations-Script führt dich interaktiv durch die Einrichtung:
- Konfiguration der E-Mail-Benachrichtigung
- Festlegung des Log-Verzeichnisses
- Optional: Einrichtung eines Cron-Jobs
- Optional: Automatischer Neustart bei Bedarf

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

Während der Installation kannst du einen Cron-Job einrichten. Beispiele:

```bash
# Täglich um 3:00 Uhr
0 3 * * * /opt/linux-update-script/update.sh

# Wöchentlich (Sonntag, 3:00 Uhr)
0 3 * * 0 /opt/linux-update-script/update.sh

# Monatlich (1. des Monats, 3:00 Uhr)
0 3 1 * * /opt/linux-update-script/update.sh
```

Cron-Jobs anzeigen:
```bash
crontab -l
```

Cron-Jobs bearbeiten:
```bash
crontab -e
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

Für E-Mail-Benachrichtigungen muss eines der folgenden Programme installiert sein:

**Debian/Ubuntu/Mint:**
```bash
sudo apt-get install mailutils
```

**RHEL/Fedora/CentOS:**
```bash
sudo dnf install mailx
# oder
sudo yum install mailx
```

**openSUSE/SUSE:**
```bash
sudo zypper install mailx
```

### E-Mail-Konfiguration testen

```bash
echo "Test-Nachricht" | mail -s "Test" deine-admin@domain.de
```

## Logging

Alle Updates werden in Logdateien mit Zeitstempel gespeichert:

```
/var/log/system-updates/update_YYYY-MM-DD_HH-MM-SS.log
```

### Logs anzeigen

Neueste Logdatei anzeigen:
```bash
./log_view_new.sh
```
# oder
```bash
ls -lt /var/log/system-updates/ | head -n 2
cat /var/log/system-updates/update_*.log
```

Letzte 50 Zeilen des neuesten Logs:
```bash
./log_view_new50.sh
```

# oder
```bash
tail -n 50 /var/log/system-updates/$(ls -t /var/log/system-updates/ | head -n 1)
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

**Überprüfungen:**
1. Ist `mailutils` oder `mailx` installiert?
   ```bash
   which mail
   which sendmail
   ```

2. Ist die E-Mail-Adresse korrekt in `config.conf`?
   ```bash
   cat config.conf | grep EMAIL
   ```

3. Ist E-Mail aktiviert?
   ```bash
   cat config.conf | grep ENABLE_EMAIL
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

### Version 1.0.0 (2025-11-06)
- Initiale Veröffentlichung
- Unterstützung für Debian, Ubuntu, Mint, RHEL, Fedora, SUSE
- E-Mail-Benachrichtigung
- Automatisches Logging
- Interaktives Installations-Script
- Cron-Job-Unterstützung
