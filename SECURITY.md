# Sicherheitsrichtlinien

## Unterstützte Versionen

Folgende Versionen erhalten aktiv Sicherheitsupdates:

| Version | Unterstützt        |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Sicherheitslücke melden

Die Sicherheit dieses Projekts wird ernst genommen. Wenn du eine Sicherheitslücke entdeckt hast, melde diese bitte **NICHT** über öffentliche Issues.

### Meldeprozess

1. **Erstelle einen privaten Security Advisory:**
   - Gehe zu [Security Advisories](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/security/advisories)
   - Klicke auf "Report a vulnerability"

2. **Oder sende eine E-Mail** an die Maintainer über GitHub

### Informationen in der Meldung

Bitte gib folgende Informationen an:

- **Typ der Schwachstelle** (z.B. Command Injection, Path Traversal)
- **Betroffene Datei(en)** und Zeilennummern
- **Schritte zur Reproduktion** des Problems
- **Möglicher Impact** der Schwachstelle
- **Vorschlag für einen Fix** (falls vorhanden)

### Was du erwarten kannst

- **Bestätigung** innerhalb von 48 Stunden
- **Erste Einschätzung** innerhalb von 7 Tagen
- **Regelmäßige Updates** zum Status
- **Koordinierte Veröffentlichung** nach dem Fix

## Sicherheitsbest Practices

### Für Nutzer des Scripts:

#### 1. Minimale Berechtigungen
```bash
# Script als root ausführen (für System-Updates erforderlich)
sudo ./update.sh
```

#### 2. Konfigurationsdatei schützen
```bash
# Sichere Berechtigungen setzen
chmod 600 config.conf

# Eigentümer prüfen
ls -l config.conf
```

#### 3. Log-Verzeichnis absichern
```bash
# Nur root sollte Logs ändern können
sudo chown root:root /var/log/system-updates
sudo chmod 750 /var/log/system-updates
```

#### 4. Cron-Job absichern
```bash
# Crontab nur als root bearbeiten
sudo crontab -e

# Prüfen, dass keine anderen User Zugriff haben
sudo ls -la /etc/cron.d/
```

#### 5. E-Mail-Konfiguration
- Verwende **keine Klartext-Passwörter** in Konfigurationsdateien
- Nutze **lokale MTAs** (postfix, ssmtp) mit sicherer Konfiguration
- Prüfe `/etc/ssmtp/ssmtp.conf` Berechtigungen: `chmod 640`

### Für Entwickler:

#### 1. Input Validierung
```bash
# IMMER User-Input validieren
if [[ ! "$EMAIL_RECIPIENT" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    log_error "Ungültige E-Mail-Adresse"
    exit 1
fi
```

#### 2. Command Injection verhindern
```bash
# SCHLECHT - Anfällig für Injection
eval "$USER_INPUT"

# GUT - Parameter quoting
"$PACKAGE_MANAGER" update
```

#### 3. Path Traversal verhindern
```bash
# Pfade validieren
LOG_DIR="/var/log/system-updates"
if [[ ! "$LOG_DIR" =~ ^/var/log/ ]]; then
    log_error "Ungültiger Log-Pfad"
    exit 1
fi
```

#### 4. Temporäre Dateien sicher erstellen
```bash
# Sichere Temp-Datei erstellen
TEMP_FILE=$(mktemp) || exit 1
trap 'rm -f "$TEMP_FILE"' EXIT
```

#### 5. Fehlerbehandlung
```bash
# Exit bei Fehler
set -e

# Oder explizit prüfen
if ! some_command; then
    log_error "Kommando fehlgeschlagen"
    exit 1
fi
```

## Bekannte Sicherheitsüberlegungen

### Sudo/Root-Rechte erforderlich

Das Script **muss als root** ausgeführt werden, da System-Updates Administratorrechte benötigen.

**Risiken:**
- Fehler im Script können System beschädigen
- Command Injection könnte mit root-Rechten ausgeführt werden

**Mitigationen:**
- Code-Reviews für alle Änderungen
- ShellCheck CI für statische Analyse
- Minimale externe Dependencies
- Kein User-Input ohne Validierung

### E-Mail-Versand

**Risiken:**
- Credentials in Konfigurationsdateien
- Unverschlüsselter E-Mail-Versand

**Mitigationen:**
- Nutzer müssen MTAs selbst konfigurieren
- Keine Credentials im Script gespeichert
- Empfehlung für sichere MTA-Konfiguration in Dokumentation

## Security Checklist für neue Features

- [ ] Kein User-Input ohne Validierung
- [ ] Keine `eval` Verwendung mit User-Input
- [ ] Pfade sind absolut oder validiert
- [ ] Command Injection getestet
- [ ] Berechtigungen korrekt gesetzt
- [ ] Fehlerbehandlung implementiert
- [ ] ShellCheck ohne Warnungen
- [ ] Dokumentation für sichere Nutzung

## Danksagung

Wir danken allen, die verantwortungsvoll Sicherheitsprobleme melden und damit zur Sicherheit des Projekts beitragen.

Security Researcher, die Schwachstellen finden und melden, werden (nach ihrer Zustimmung) in den Release Notes erwähnt.
