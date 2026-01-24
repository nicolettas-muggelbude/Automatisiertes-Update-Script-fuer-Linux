# Linux Update-Script - Projektdokumentation

## Projektübersicht
Automatisiertes Update-Script für verschiedene Linux-Distributionen mit optionaler E-Mail-Benachrichtigung.

## Unterstützte Distributionen
- **Debian-Familie**: Debian, Ubuntu, Linux Mint
- **RedHat-Familie**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-Familie**: openSUSE (Leap/Tumbleweed), SLES
- **Arch-Familie**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus**: Solus
- **Void Linux**: Void Linux

## Funktionen
- Automatische Erkennung der Linux-Distribution
- Vollautomatische System-Updates
- Optionale E-Mail-Benachrichtigung über Update-Status
- Detaillierte Logging-Funktion
- Einfache Konfiguration über Config-Datei
- Installations-Script für initiales Setup und spätere Anpassungen

## Projektstruktur
```
Update-Script/
├── .gitignore            # Git-Ignore-Datei
├── update.sh             # Haupt-Update-Script
├── install.sh            # Installations- und Konfigurations-Script
├── log-viewer.sh         # Interaktiver Log-Viewer
├── config.conf           # Konfigurationsdatei (wird bei Installation erstellt)
├── config.conf.example   # Beispiel-Konfigurationsdatei
├── README.md             # Benutzeranleitung (Deutsch)
├── CHANGELOG.md          # Versionshistorie und Änderungen
├── LICENSE               # MIT Lizenz
├── projekt.md            # Projektanforderungen
└── claude.md             # Diese Datei (Projektdokumentation)
```

## Technische Details

### update.sh
- Erkennt automatisch die Distribution via `/etc/os-release`
- Führt distributionsspezifische Update-Befehle aus
- Erstellt Logdatei mit Timestamp im Format: `/var/log/system-updates/update_YYYY-MM-DD_HH-MM-SS.log`
- Sendet optional E-Mail-Benachrichtigung via `mail` oder `sendmail`
  - Prüft Exit-Code des Mail-Befehls
  - Meldet nur bei erfolgreicher Zustellung "E-Mail gesendet"
  - Warnt bei fehlender MTA-Konfiguration
- Exit-Codes: 0 (Erfolg), 1 (Fehler)

### install.sh
- Interaktives Setup-Script mit verbesserter Benutzerführung
- Erstellt Konfigurationsdatei im Projekt-Verzeichnis
- E-Mail-Benachrichtigung (erste Frage)
  - Prüft automatisch, ob Mail-Programm installiert ist
  - Zeigt distributionsspezifische Installationsanweisungen
  - Bestätigt gespeicherte E-Mail-Adresse
- Optional: Automatischer Neustart konfigurierbar
- Optional: Log-Verzeichnis ändern
  - Zeigt Standard-Verzeichnis an
  - Legt Verzeichnis mit sudo an, falls nötig
- Richtet optional Cron-Job im root-Crontab ein
  - Wählbare Zeitpläne (täglich, wöchentlich, monatlich, benutzerdefiniert)
  - Automatische sudo-Ausführung
- Kann jederzeit erneut ausgeführt werden für Konfigurationsänderungen
- Alle Eingaben mit klaren Bestätigungsmeldungen

### log-viewer.sh
- Interaktiver Log-Viewer mit Menü
- Zeigt neueste Logdatei komplett an
- Zeigt letzte 50 Zeilen des neuesten Logs
- Listet alle verfügbaren Logdateien auf
- Sucht nach Fehlern in allen Logs
- Farbige Ausgabe für bessere Lesbarkeit

### Konfigurationsdatei (config.conf)
```bash
ENABLE_EMAIL=false
EMAIL_RECIPIENT=""
LOG_DIR="/var/log/system-updates"
AUTO_REBOOT=false
```

## Sicherheitsüberlegungen
- Script sollte als root oder mit sudo ausgeführt werden
- Logging für Nachvollziehbarkeit
- Keine Passwörter im Klartext in der Config

## Lizenz
MIT License

## Implementierungsdetails

### Erstellte Dateien

1. **update.sh** (6.8K, ausführbar)
   - Hauptscript für System-Updates
   - ~250 Zeilen Bash-Code
   - Unterstützt alle geforderten Distributionen
   - Vollständiges Error-Handling

2. **install.sh** (9.3K, ausführbar)
   - Interaktives Installations-Script
   - ~350 Zeilen Bash-Code
   - Farbige Ausgaben für bessere UX
   - Cron-Job-Konfiguration

3. **README.md** (5.4K)
   - Umfassende deutsche Benutzeranleitung
   - Installation, Verwendung, Konfiguration
   - Fehlerbehebung und Support-Informationen
   - Beispiele für alle Anwendungsfälle

4. **LICENSE** (1.1K)
   - Vollständige MIT-Lizenz
   - Jahr: 2025
   - Platzhalter für Copyright-Inhaber

5. **config.conf.example** (502 Bytes)
   - Beispiel-Konfiguration
   - Kann ins Git-Repository eingecheckt werden
   - Dokumentiert alle verfügbaren Optionen

6. **.gitignore** (290 Bytes)
   - Schützt sensible Konfigurationsdaten
   - Ignoriert Log-Dateien und Backups
   - Standard-Ausschlüsse für Editor-Dateien

7. **log-viewer.sh** (6.3K, ausführbar)
   - Interaktiver Log-Viewer mit Menü
   - ~230 Zeilen Bash-Code
   - 4 verschiedene Ansichts-Optionen
   - Fehlersuche in allen Logs
   - Farbige, benutzerfreundliche Ausgabe

8. **CHANGELOG.md** (4.3K)
   - Vollständige Versionshistorie
   - Strukturiert nach Keep a Changelog Standard
   - Semantic Versioning
   - Kategorisiert nach: Hinzugefügt, Geändert, Behoben, etc.

### Besonderheiten der Implementierung

- **Farbige Ausgaben**: Bessere Unterscheidung von Erfolg, Fehler und Warnungen
- **Fehlertoleranz**: Robustes Error-Handling mit aussagekräftigen Fehlermeldungen
- **Logging**: Jeder Update-Durchlauf wird vollständig protokolliert
- **Flexibilität**: Einfache Anpassung durch Config-Datei ohne Code-Änderungen
- **Sicherheit**: Keine Passwörter im Klartext, Root-Prüfung, Input-Validierung
- **Benutzerfreundlichkeit**:
  - Interaktive Installation ohne unsichtbare Warteschritte
  - Klare Bestätigungsmeldungen nach jeder Eingabe
  - Sofortige Anzeige des Standard-Log-Verzeichnisses
  - Distributionsspezifische Installationsanweisungen für Mail-Programme
- **Robuste Input-Verarbeitung**:
  - `ask_input` Funktion nutzt stderr für Fragen, stdout nur für Rückgabewerte
  - Automatische Bereinigung von Whitespace in Benutzereingaben
  - Verhindert Probleme mit mehrzeiligen Eingaben
- **Automatisierung**:
  - Root-Crontab-Einrichtung mit einem einzigen sudo-Aufruf
  - Log-Verzeichnis wird bei Bedarf automatisch mit sudo angelegt
  - Keine manuelle sudoers-Konfiguration nötig

## Nächste Schritte

Für die Verwendung:
1. Führen Sie `./install.sh` aus, um die initiale Konfiguration vorzunehmen
2. Testen Sie das Update-Script: `sudo ./update.sh`
3. Logs ansehen: `./log-viewer.sh`
4. Optional: Git-Repository initialisieren für Versionsverwaltung

## Version

### 1.6.0 (in Entwicklung - XDG-Konformität)
**Neues Hauptfeature: XDG Base Directory Specification**
- Config-Migration nach `~/.config/linux-update-script/`
- Automatische Migration von alter Config
- Backwards-kompatibel (keine Breaking Changes)
- Config bleibt bei Script-Updates erhalten

**Technische Umsetzung:**
- `migrate_config()` - Automatische Migration beim Start
- `find_config_file()` - Intelligente Config-Suche mit Fallback
- Neue Config-Pfade: XDG → System → Alt
- 8 neue Sprachmeldungen (DE/EN)
- install.sh erstellt Config in `~/.config/`
- Warnung bei alter Config-Location (deprecated)

**Community-Aspekt:**
- Basierend auf Feedback von @tbreswald
- Linux-Standard-konform
- Vorbereitung für v2.0.0

### 1.4.0 (Released - Feature-Branch)
**Neues Hauptfeature: Mehrsprachigkeit (i18n)**
- Vollständige Internationalisierung des Scripts
- Deutsch und Englisch als Start-Sprachen
- Automatische Sprach-Erkennung oder manuelle Konfiguration
- Sprachdateien-System mit einfacher Erweiterbarkeit

**Technische Implementierung:**
- `lang/` Verzeichnis mit Sprachdateien:
  - `de.lang` / `en.lang` - für update.sh (45+ Strings)
  - `install-de.lang` / `install-en.lang` - für install.sh (60+ Strings)
  - `README.md` - Contributor-Guide
- `load_language()` Funktion in update.sh:
  - Auto-Detection via `$LANG` Umgebungsvariable
  - Fallback-Kette: Gewünscht → EN → Fehler
  - Unterstützt temporäre Sprachwahl
- `select_and_load_language()` in install.sh:
  - Bilinguale Sprachauswahl am Start
  - Gewählte Sprache wird in config.conf persistiert
- Alle Log-Level Labels mehrsprachig
- ISO 639-1 Standard für Sprachcodes

**Community-Aspekt:**
- Einfacher Beitrag neuer Sprachen
- Klare Struktur und Dokumentation
- Keine externen Abhängigkeiten (Pure Bash)

### 1.3.0 (2025-12-16)
**Neue Features:**
- Solus Unterstützung hinzugefügt (PR #3 von @mrtoadie)
  - Neue `update_solus()` Funktion
  - Verwendet `eopkg update-repo` und `eopkg upgrade -y`
- Void Linux Unterstützung hinzugefügt (PR #4 von @tbreswald)
  - Neue `update_void()` Funktion
  - Verwendet `xbps-install -Su -y`

**Verbesserungen:**
- Code-Qualität verbessert durch Behebung von ShellCheck-Warnungen
- Syntax-Fehler in `update_solus()` und `update_void()` behoben

**Dokumentation:**
- README.md, install.sh und claude.md mit Solus und Void Linux aktualisiert
- GitHub Repository professionell eingerichtet (Issue Templates, PR Template, GitHub Actions)

### 1.2.0 (2025-11-09)
**Neue Features:**
- Arch Linux Unterstützung hinzugefügt
  - Neue `update_arch()` Funktion für Arch Linux und Forks
  - Unterstützt: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
  - Verwendet `pacman -Syu --noconfirm` für Updates
  - Automatische Cache-Bereinigung mit `pacman -Sc`

**Verbesserungen:**
- E-Mail-Benachrichtigung mit Exit-Code-Prüfung
- Verbesserte Fehlermeldungen bei fehlender MTA-Konfiguration
- Erweiterte Installationsanleitungen für alle Distributionen

### 1.1.0 (2025-11-09)
**Verbesserungen und Bugfixes:**
- Behobene Input-Verarbeitung in install.sh
  - ask_input Funktion nutzt jetzt stderr für Fragen
  - Automatische Whitespace-Bereinigung
  - Keine unsichtbaren ENTER-Schritte mehr
- Cron-Job-Auswahl 1-4 funktioniert jetzt korrekt
- Log-Verzeichnis wird automatisch mit sudo angelegt
- Standard-Log-Verzeichnis wird angezeigt vor der Frage
- Bestätigungsmeldungen nach allen Eingaben
- Distributionsspezifische Mail-Programm-Installationsanweisungen

**Neue Features:**
- log-viewer.sh: Interaktives Log-Viewer-Script mit 4 Ansichtsoptionen
- Root-Crontab-Einrichtung ohne manuelle sudoers-Konfiguration
- Verbesserte Benutzerführung durch das gesamte Setup

### 1.0.0 (2025-11-04)
- Alle Anforderungen aus projekt.md implementiert
- Vollständige Dokumentation erstellt
- Bereit für den produktiven Einsatz
