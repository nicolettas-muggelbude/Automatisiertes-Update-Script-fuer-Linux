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

## ⚠️ Wichtige Hinweise VOR der Installation

### Scripts IMMER im Terminal ausführen

**❌ NICHT im Dateimanager doppelklicken!**

Die Scripts müssen im **Terminal** ausgeführt werden, nicht durch Doppelklick im GUI-Dateimanager (Nautilus, Dolphin, Thunar, etc.).

**✅ Korrekt - Terminal verwenden:**

```bash
# Terminal öffnen (Strg+Alt+T oder über Anwendungsmenü)
# Dann ins Script-Verzeichnis wechseln:
cd ~/linux-update-script
./install.sh
```

**❌ Falsch:**
- Doppelklick auf `install.sh` im Dateimanager
- Script aus falschem Verzeichnis ausführen
- Alte/falsche Script-Versionen verwenden

### Richtige Verzeichnisstruktur

Nach der Installation sollte die Struktur so aussehen:

```
~/linux-update-script/          ← Hier müssen die Scripts sein!
├── update.sh                   ← Haupt-Update-Script
├── install.sh                  ← Installations-Script
├── log-viewer.sh               ← Log-Viewer
├── config.conf.example         ← Konfigurations-Vorlage
├── config.conf                 ← Deine Konfiguration (nach Installation)
└── lang/                       ← Sprachdateien
```

**⚠️ Alte Versionen aufräumen:**

Falls du bereits frühere Versionen oder Test-Downloads hast:

```bash
# Prüfe was in deinem Verzeichnis liegt:
ls -la

# Lösche ALTE Versionen (z.B.):
# - system-update.sh        ← Alter Name, NICHT verwenden!
# - README_mitMail.md       ← Alte Doku, NICHT verwenden!
```

**Nur diese Scriptnamen sind offiziell:**
- ✅ `update.sh`
- ✅ `install.sh`
- ✅ `log-viewer.sh`

Falls du Dateien mit anderen Namen siehst (z.B. `system-update.sh`), sind das **alte/inoffizielle Versionen**!

---

## Voraussetzungen

### Git installieren (nur für `git clone` Methode)

**⚠️ Wichtig:** Git ist **nur erforderlich**, wenn du das Repository mit `git clone` herunterladen möchtest. Für die ZIP-Download-Methode (siehe unten) wird Git **nicht** benötigt.

**Prüfen ob Git installiert ist:**
```bash
git --version
```

**Git installieren (falls nicht vorhanden):**

```bash
# Debian/Ubuntu/Mint
sudo apt-get update
sudo apt-get install git

# RHEL/CentOS/Fedora/Rocky/AlmaLinux
sudo dnf install git

# openSUSE/SUSE
sudo zypper install git

# Arch Linux/Manjaro
sudo pacman -S git

# Solus
sudo eopkg install git

# Void Linux
sudo xbps-install -S git
```

## Installation

### 1. Repository herunterladen

**Option A: Mit Git (empfohlen für einfache Updates)**

Installation im Home-Verzeichnis:
```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
```

Installation in /opt (system-weit):
```bash
cd /opt
sudo git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
sudo chown -R $USER:$USER linux-update-script
cd linux-update-script
```

**Vorteil:** Einfaches Update mit `git pull`

**Option B: Ohne Git (ZIP-Download)**

Falls Git nicht verfügbar oder gewünscht:

```bash
# Download als ZIP
cd ~
wget https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip

# Oder mit curl:
curl -L -o main.zip https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip

# Entpacken
unzip main.zip
mv Automatisiertes-Update-Script-fuer-Linux-main linux-update-script
cd linux-update-script

# ZIP-Datei aufräumen (optional)
rm ~/main.zip
```

**Hinweis:** Bei ZIP-Download musst du bei Updates die ZIP-Datei erneut herunterladen und entpacken.

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

**⚠️ Wichtig: Zuerst ins richtige Verzeichnis wechseln!**

```bash
# Terminal öffnen (Strg+Alt+T)

# Ins Script-Verzeichnis wechseln:
cd ~/linux-update-script

# ODER bei /opt Installation:
cd /opt/linux-update-script

# Jetzt das Update-Script ausführen:
sudo ./update.sh
```

**Häufiger Fehler:**
```bash
# ❌ FALSCH - ohne cd ins richtige Verzeichnis:
sudo ./update.sh
# Fehler: ./update.sh: Datei oder Verzeichnis nicht gefunden

# ✅ RICHTIG - erst mit cd ins Verzeichnis:
cd ~/linux-update-script
sudo ./update.sh
```

Das Script führt automatisch folgende Schritte durch:
1. System-Updates installieren
2. Prüfung auf verfügbare Distribution-Upgrades
3. Optional: E-Mail-Benachrichtigung versenden
4. Optional: Desktop-Benachrichtigung anzeigen

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
# Ins Script-Verzeichnis wechseln:
cd ~/linux-update-script

# Upgrade durchführen:
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
# Ins Script-Verzeichnis wechseln:
cd ~/linux-update-script

# Hilfe anzeigen:
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

### Config-Datei Location (NEU in v1.6.0)

**XDG-konform seit v1.6.0:**

Die Konfigurationsdatei liegt jetzt standardmäßig in:

```bash
~/.config/linux-update-script/config.conf
```

**Vorteile:**
- ✅ **Config bleibt erhalten** beim Script-Update (git pull)
- ✅ **Linux-Standard-konform** (XDG Base Directory Specification)
- ✅ **Multi-User-fähig** (jeder User eigene Config)
- ✅ **Saubere Trennung** von Code und Konfiguration

**Automatische Migration:**

Beim ersten Start nach Update auf v1.6.0 wird die alte Config automatisch migriert:

```bash
sudo ./update.sh
# [INFO] Migriere Konfiguration nach ~/.config/ (XDG-Standard)
# [INFO] Konfiguration erfolgreich migriert nach: ~/.config/linux-update-script/config.conf
# [INFO] Alte Konfiguration gesichert als: config.conf.migrated
```

**Config-Pfade (Fallback-Reihenfolge):**

1. `~/.config/linux-update-script/config.conf` (bevorzugt)
2. `/etc/linux-update-script/config.conf` (system-weit)
3. `./config.conf` (deprecated, wird in v2.0.0 entfernt)

### Config-Optionen

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

**Option 1: Installations-Script erneut ausführen**
```bash
./install.sh
```

**Option 2: Config-Datei manuell bearbeiten**

Ab v1.6.0 (XDG-konform):
```bash
nano ~/.config/linux-update-script/config.conf
```

Vor v1.6.0 (deprecated):
```bash
cd ~/linux-update-script
nano config.conf
```

**Hinweis:** Nach Bearbeitung der Config ist kein Neustart nötig - die Änderungen werden beim nächsten Script-Lauf übernommen.

## E-Mail-Benachrichtigung

### Übersicht: Lokal vs. Extern

Es gibt **zwei verschiedene Arten** von E-Mail-Benachrichtigungen:

| Art | Empfänger | Verwendung | Konfigurationsaufwand |
|-----|-----------|------------|----------------------|
| **Lokal** | `nicole`, `root` | Mails bleiben auf dem System | ⭐ Minimal (empfohlen!) |
| **Extern** | `user@gmail.com` | Mails gehen raus ins Internet | ⚙️ Aufwändig (SMTP nötig) |

**Empfehlung für Einsteiger:** Start mit **lokalen Mails** - einfacher, funktioniert sofort!

---

## 📬 Lokale E-Mail-Benachrichtigungen (Empfohlen)

### Was sind lokale Mails?

Lokale Mails werden **nicht ins Internet** verschickt, sondern landen direkt in deiner **Mailbox auf dem System**.

✅ **Vorteile:**
- Keine externe SMTP-Konfiguration nötig
- Funktioniert sofort nach Installation
- Perfekt für System-Benachrichtigungen
- Keine Spam-Probleme
- Keine Internet-Verbindung erforderlich

### Schritt 1: Installation (automatisch via install.sh)

```bash
./install.sh

# Bei der Frage:
E-Mail-Adresse oder Benutzername [nicole]: nicole ← Einfach Username!
```

Das installiert automatisch:
- ✅ **mailutils** (liefert den `mail`-Befehl)
- ✅ **DMA** (DragonFly Mail Agent - leichtgewichtiger MTA)

### Schritt 2: Lokale Mails lesen

**Option 1: mail-Kommando (empfohlen)**

```bash
# Mailbox öffnen
mail

# Ausgabe:
# Mail version 8.1.2 01/15/2001.  Type ? for help.
# "/var/mail/nicole": 3 messages 2 new
# >N  1 nicole@hostname  Sat Jan 25 10:30  23/699   Linux Update-Script - Test
#  N  2 nicole@hostname  Sat Jan 25 11:15  18/543   System-Update erfolgreich
#    3 nicole@hostname  Sat Jan 25 12:00  21/612   System-Update FEHLGESCHLAGEN
```

**Wichtige Befehle im mail-Programm:**

```bash
# Erste Mail lesen
& 1

# Nächste Mail
& n

# Mail löschen
& d 1

# Mehrere Mails löschen
& d 1-5

# Alle Mails löschen
& d *

# Beenden
& q
```

**Option 2: Direkt in Mailbox-Datei schauen**

```bash
# Mailbox anzeigen
cat /var/mail/nicole

# Oder mit Pager (scrollbar)
less /var/mail/nicole

# Neueste Mails anzeigen
tail -50 /var/mail/nicole
```

**Option 3: Mailbox komplett leeren**

```bash
# Alle Mails löschen
> /var/mail/nicole

# ODER
sudo rm /var/mail/nicole
```

### Schritt 3: Test-Mail senden

```bash
# Einfache Test-Mail
echo "Dies ist ein Test" | mail -s "Test-Betreff" nicole

# Mit mehrzeiligem Text
mail -s "Mehrzeiliger Test" nicole << EOF
Zeile 1
Zeile 2
Zeile 3
EOF

# Mail lesen
mail
```

### Troubleshooting: Lokale Mails

**Problem: Mails kommen nicht an**

```bash
# 1. Prüfe ob mailutils installiert ist
command -v mail && echo "✓ mail vorhanden" || echo "✗ mail fehlt"

# 2. Prüfe ob DMA installiert ist
dpkg -l | grep dma

# 3. DMA-Queue prüfen (wartende Mails)
sudo mailq

# 4. DMA-Logs prüfen
sudo journalctl -u dma -n 50
```

**Problem: Bounce-Mails (Zustellfehler)**

Wenn du versehentlich externe Adressen verwendet hast:

```bash
# Queue leeren (alle wartenden Mails löschen)
sudo rm -rf /var/spool/dma/*

# Bounces aus Mailbox löschen
mail
& d *  # Alle löschen
& q

# Config korrigieren
nano ~/.config/linux-update-script/config.conf
# EMAIL_RECIPIENT="nicole"  ← Lokaler Username!
```

---

## 🌐 Externe E-Mail-Benachrichtigungen (Fortgeschritten)

Falls du Mails an **externe Adressen** (Gmail, Outlook, etc.) senden möchtest.

⚠️ **Warnung:** Deutlich komplexer! Nur wenn du wirklich externe Mails brauchst.

### Voraussetzungen

1. **Gültiger SMTP-Server** (Gmail, Posteo, dein Provider)
2. **App-Passwort** (bei Gmail, Outlook) NICHT dein normales Passwort!
3. **SMTP-Zugangsdaten** (Server, Port, Username, Passwort)

### Option 1: DMA mit SMTP (für Fortgeschrittene)

```bash
# 1. DMA-Config bearbeiten
sudo nano /etc/dma/dma.conf
```

Für **Gmail** beispielsweise:

```bash
# SMTP-Server
SMARTHOST smtp.gmail.com
PORT 587

# Authentifizierung
AUTHPATH /etc/dma/auth.conf
SECURETRANSFER
STARTTLS

# Absender-Domain
MAILNAME gmail.com
```

```bash
# 2. Zugangsdaten speichern
sudo nano /etc/dma/auth.conf
```

Inhalt:
```
deine@gmail.com|smtp.gmail.com:dein-app-passwort
```

```bash
# 3. Berechtigungen setzen
sudo chmod 640 /etc/dma/auth.conf
sudo chown root:mail /etc/dma/auth.conf

# 4. Mailname setzen
echo "gmail.com" | sudo tee /etc/mailname
```

**Gmail App-Passwort erstellen:**
1. Google Account → Sicherheit
2. 2-Faktor-Authentifizierung aktivieren
3. App-Passwörter → Neues Passwort generieren
4. Passwort in `/etc/dma/auth.conf` eintragen

### Option 2: ssmtp mit SMTP (Alternative)

```bash
# 1. ssmtp installieren
sudo apt-get install ssmtp

# 2. Konfiguration
sudo nano /etc/ssmtp/ssmtp.conf
```

Für **Gmail**:
```bash
root=deine@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=deine@gmail.com
AuthPass=dein-app-passwort
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
```

### Externe Mails testen

```bash
# Test-Mail an externe Adresse
echo "Test von $(hostname)" | mail -s "Externer Test" deine@gmail.com

# Queue prüfen (falls Mail wartet)
sudo mailq

# Logs prüfen
sudo tail -f /var/log/mail.log
```

### Troubleshooting: Externe Mails

**Problem: "Invalid HELO" oder "550 Rejected"**

```bash
# MAILNAME muss gültige Domain sein!
sudo nano /etc/dma/dma.conf
# MAILNAME gmail.com  ← NICHT "hostname.localdomain"!

echo "gmail.com" | sudo tee /etc/mailname
```

**Problem: "Authentication failed"**

```bash
# Prüfe App-Passwort (NICHT normales Passwort!)
sudo cat /etc/dma/auth.conf

# Format muss sein:
# user@gmail.com|smtp.gmail.com:16-stelliges-app-passwort
```

**Problem: Mails bleiben in Queue**

```bash
# Queue anzeigen
sudo mailq

# Queue manuell abarbeiten (DMA)
sudo dma -q

# Oder Queue komplett leeren (ACHTUNG: löscht alle wartenden Mails!)
sudo rm -rf /var/spool/dma/*
```

---

## 📋 Zusammenfassung: Was soll ich nutzen?

### Für normale Heimanwender:
```
✅ Lokale Mails (nicole, root)
✅ mailutils + DMA
✅ Keine SMTP-Konfiguration nötig
✅ Mails mit "mail" lesen
```

### Für Fortgeschrittene mit externen Mails:
```
⚙️ Externe Mails (user@gmail.com)
⚙️ DMA oder ssmtp mit SMTP
⚙️ App-Passwörter einrichten
⚙️ MAILNAME konfigurieren
```

### Quick-Start für Einsteiger:

```bash
# 1. Installation
./install.sh
# Bei E-Mail: nicole eingeben

# 2. Test-Mail senden
echo "Test" | mail -s "Test" nicole

# 3. Mails lesen
mail

# Fertig! ✓
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
# Ins Script-Verzeichnis wechseln:
cd ~/linux-update-script

# Log-Viewer starten:
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

## Script-Updates

Das Update-Script selbst kann auf neue Versionen aktualisiert werden. Die Methode hängt davon ab, wie du es installiert hast.

### Update mit Git (wenn mit `git clone` installiert)

**Vorteil:** Einfachstes Update-Verfahren, Config bleibt automatisch erhalten

```bash
# Ins Script-Verzeichnis wechseln
cd ~/linux-update-script

# Oder bei /opt Installation:
cd /opt/linux-update-script

# Neueste Version holen
git pull

# Beim ersten Start nach Update auf v1.6.0+ wird Config automatisch migriert
sudo ./update.sh
```

**Deine Config bleibt erhalten!** Seit v1.6.0 liegt die Config in `~/.config/linux-update-script/` und wird bei `git pull` nicht überschrieben.

### Update ohne Git (bei ZIP-Installation)

Wenn du das Script als ZIP heruntergeladen hast:

```bash
# WICHTIG: Zuerst Config sichern (nur bei v1.5.1 oder früher nötig)
# Seit v1.6.0 liegt Config in ~/.config/ und muss nicht gesichert werden
cp ~/linux-update-script/config.conf ~/config.conf.backup 2>/dev/null || true

# Alte Version löschen
rm -rf ~/linux-update-script

# Neue Version herunterladen
cd ~
wget https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/archive/refs/heads/main.zip
unzip main.zip
mv Automatisiertes-Update-Script-fuer-Linux-main linux-update-script

# Alte Config wiederherstellen (nur bei v1.5.1 oder früher)
# Seit v1.6.0 liegt Config in ~/.config/ und wird automatisch gefunden
if [ -f ~/config.conf.backup ]; then
    cp ~/config.conf.backup ~/linux-update-script/config.conf
    rm ~/config.conf.backup
fi

# Aufräumen
rm main.zip
```

**Tipp:** Bei regelmäßigen Updates ist die Git-Methode deutlich einfacher!

### Prüfen welche Installationsmethode du verwendest

```bash
cd ~/linux-update-script

# Wenn dieser Befehl ein Git-Repository zeigt, hast du mit git clone installiert:
git status

# Wenn Fehler "not a git repository", hast du ZIP-Download verwendet
```

### Aktuelle Version prüfen

Die Version wird im Script angezeigt oder kann in den Dateien nachgeschaut werden:

```bash
# In CHANGELOG.md (erste Zeilen)
head -20 ~/linux-update-script/CHANGELOG.md | grep "##"
```

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

## NVIDIA-Kernel-Kompatibilitätsprüfung

**NEU in v1.6.0:** Das Script prüft automatisch die NVIDIA-Treiber-Kompatibilität VOR Kernel-Updates!

### Problem

Proprietäre NVIDIA-Treiber müssen nach Kernel-Updates neu kompiliert werden (DKMS). Ohne funktionierende Treiber startet das System nach dem Neustart möglicherweise nicht richtig:
- Schwarzer Bildschirm
- Kein X11/Wayland
- System bootet in Textmodus

### Lösung

Das Script prüft **vor dem Update**:
1. Ob NVIDIA-Treiber installiert sind
2. Welcher Kernel im Update verfügbar ist
3. Ob DKMS-Module für den neuen Kernel existieren
4. Bietet automatischen DKMS-Rebuild an

### Funktionsweise

```bash
sudo ./update.sh

# [INFO] NVIDIA-Treiber erkannt: 535.129.03
# [INFO] Prüfe NVIDIA-Treiber-Kompatibilität
# [INFO] Kernel-Update verfügbar: 6.5.0-35-generic
# [INFO] Prüfe DKMS-Status für Kernel 6.5.0-35-generic
```

**Falls DKMS-Module fehlen:**

```bash
# [WARNUNG] DKMS-Module müssen für neuen Kernel neu gebaut werden
# Möchtest du DKMS-Module jetzt neu bauen? [j/N]: j
# [INFO] Führe DKMS autoinstall durch...
# [INFO] DKMS-Module erfolgreich neu gebaut
```

**Falls DKMS-Rebuild fehlschlägt:**

```bash
# [FEHLER] Fehler beim Neu-Bauen der DKMS-Module
# [WARNUNG] Trotzdem mit Update fortfahren? [j/N]: n
# [INFO] Update abgebrochen - bitte NVIDIA-Treiber aktualisieren
```

### Automatischer DKMS-Rebuild

Für Server/automatisierte Umgebungen kannst du den Rebuild automatisieren:

```bash
# In config.conf:
NVIDIA_AUTO_DKMS_REBUILD=true
```

Das Script führt dann `dkms autoinstall` automatisch durch, ohne nachzufragen.

### Secure Boot Unterstützung

Wenn **Secure Boot** aktiv ist, müssen NVIDIA-Module nach dem DKMS-Build signiert werden:

```bash
# [INFO] Secure Boot ist aktiv
# [INFO] Prüfe MOK (Machine Owner Key) Status
# [INFO] MOK-Schlüssel gefunden
# [INFO] Signiere NVIDIA-Module mit MOK
# [INFO] Module erfolgreich signiert
```

**MOK-Keys enrollen** (einmalig erforderlich):

```bash
# Generiere MOK-Schlüssel (falls nicht vorhanden)
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der

# Beim nächsten Neustart: MOK Management Utility nutzen
# Passwort eingeben und Key enrollen
```

**Automatische Signierung:**

```bash
# In config.conf:
NVIDIA_AUTO_MOK_SIGN=true
```

### Kernel-Hold bei Inkompatibilität (NEU!)

**Problem:** NVIDIA unterstützt manchmal neue Kernel-Versionen noch nicht offiziell.

**Standard-Verhalten (sicherer Modus):**

Das Script testet DKMS-Build **vor** dem Update. Bei Inkompatibilität:

```bash
# [WARNUNG] NVIDIA-Treiber 535.129.03 unterstützt Kernel 6.8.0-40 noch nicht
# [WARNUNG] Kernel-Update wird zurückgehalten (sicherer Modus)
# [INFO] Kernel erfolgreich zurückgehalten: linux-image-generic
# [INFO] Kernel wird NICHT aktualisiert bis NVIDIA-Treiber bereit ist
# [INFO] Später freigeben mit: sudo apt-mark unhold linux-image-generic
```

Das Update **läuft weiter** und installiert alle anderen Pakete - nur der Kernel wird übersprungen!

**Kernel später freigeben:**

```bash
# Debian/Ubuntu
sudo apt-mark unhold linux-image-generic linux-headers-generic

# RHEL/Fedora
sudo dnf versionlock delete kernel kernel-core kernel-modules

# openSUSE
sudo zypper removelock kernel-default

# Arch (manuelle /etc/pacman.conf Bearbeitung)
# Entferne: IgnorePkg = linux linux-headers
```

### Power-User Modus (⚠️ Risikoreich!)

Für **erfahrene Benutzer**, die trotz offiziell nicht unterstützter Kernel ein Update wagen:

```bash
# In config.conf:
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=true
```

**Warnung beim Update:**

```bash
# [WARNUNG] Power-User-Modus: Versuche Update trotz Warnung
# [WARNUNG] WARNUNG: Risiko von Instabilität oder schwarzem Bildschirm
# Möchtest du DKMS-Module jetzt neu bauen? [j/N]: j
```

**⚠️ Risiken:**
- System bootet nicht mehr (schwarzer Bildschirm)
- Kein GUI, nur Textmodus
- NVIDIA-Features funktionieren nicht
- Instabilität und Abstürze

**Empfehlung:** Nur aktivieren wenn du weißt was du tust und Fallback-Kernel vorhanden sind!

### Konfiguration (Übersicht)

```bash
# NVIDIA-Prüfung komplett deaktivieren (nicht empfohlen)
NVIDIA_CHECK_DISABLED=true

# Automatischer DKMS-Rebuild ohne Nachfrage
NVIDIA_AUTO_DKMS_REBUILD=true

# Power-User Modus: Nicht unterstützte Kernel erlauben (risikoreich!)
NVIDIA_ALLOW_UNSUPPORTED_KERNEL=false  # Standard: false = sicher

# Automatische MOK-Signierung für Secure Boot
NVIDIA_AUTO_MOK_SIGN=false
```

### Voraussetzungen

Für automatischen DKMS-Rebuild:
```bash
# Debian/Ubuntu
sudo apt-get install dkms

# RHEL/Fedora
sudo dnf install dkms

# Arch Linux
sudo pacman -S dkms
```

### Unterstützte Distributionen

Die NVIDIA-Prüfung funktioniert auf **allen unterstützten Distributionen**:
- ✅ Debian/Ubuntu/Mint (apt-cache)
- ✅ RHEL/Fedora/CentOS/Rocky/AlmaLinux (dnf/yum)
- ✅ Arch Linux/Manjaro/EndeavourOS/Garuda/ArcoLinux (pacman)
- ✅ openSUSE/SLES (zypper)
- ✅ Solus (eopkg)
- ✅ Void Linux (xbps-query)

### Manueller DKMS-Rebuild

Falls du DKMS manuell neu bauen möchtest:

```bash
# Für alle NVIDIA-Module
sudo dkms autoinstall

# Für spezifischen Kernel
sudo dkms autoinstall -k 6.5.0-35-generic
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
