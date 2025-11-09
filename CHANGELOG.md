# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [1.1.0] - 2025-11-09

### Hinzugefügt
- **log-viewer.sh**: Neues interaktives Log-Viewer-Script
  - Neueste Logdatei komplett anzeigen
  - Letzte 50 Zeilen des neuesten Logs anzeigen
  - Alle Logdateien auflisten mit Datum und Größe
  - Nach Fehlern in allen Logs suchen
  - Farbige, benutzerfreundliche Menüführung
- Bestätigungsmeldung nach E-Mail-Adress-Eingabe
- Anzeige des Standard-Log-Verzeichnisses vor der Änderungs-Frage
- Distributionsspezifische Installationsanweisungen für Mail-Programme
- Automatisches Anlegen des Log-Verzeichnisses mit sudo, falls benötigt

### Geändert
- **install.sh**: Verbesserte Input-Verarbeitung
  - `ask_input` Funktion nutzt jetzt stderr für Fragen, stdout nur für Rückgabewerte
  - Automatische Bereinigung von Whitespace in Benutzereingaben
  - Verhindert mehrzeilige Input-Probleme
- **Cron-Job-Einrichtung**: Root-Crontab wird direkt eingerichtet
  - Keine manuelle sudoers-Konfiguration mehr nötig
  - Klare Bestätigungsmeldungen nach jeder Auswahl
- Verbesserte Benutzerführung mit mehr Feedback und Bestätigungen
- Alle Eingabeschritte sind jetzt sichtbar (keine unsichtbaren ENTER-Schritte mehr)

### Behoben
- Cron-Job-Auswahl 1-4 wurde als ungültig erkannt (jetzt behoben)
- Unsichtbare ENTER-Schritte bei E-Mail-Konfiguration
- Log-Verzeichnis konnte nicht angelegt werden ohne root-Rechte
- Fehlende Anzeige des Standard-Log-Verzeichnisses

### Dokumentation
- README.md mit Schritt-für-Schritt-Installationsanleitung erweitert
- claude.md mit technischen Implementierungsdetails erweitert
- CHANGELOG.md neu erstellt

## [1.0.0] - 2025-11-04

### Hinzugefügt
- **update.sh**: Haupt-Update-Script für automatische System-Updates
  - Unterstützung für Debian, Ubuntu, Linux Mint
  - Unterstützung für RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
  - Unterstützung für openSUSE (Leap/Tumbleweed), SLES
  - Automatische Distribution-Erkennung via `/etc/os-release`
  - Detailliertes Logging mit Zeitstempel
  - Optionale E-Mail-Benachrichtigung bei Erfolg/Fehler
  - Automatische Neustart-Erkennung und -Durchführung (optional)
  - Farbige Terminal-Ausgabe für bessere Lesbarkeit

- **install.sh**: Interaktives Installations- und Konfigurations-Script
  - Schritt-für-Schritt-Führung durch die Einrichtung
  - E-Mail-Benachrichtigung konfigurieren
  - Log-Verzeichnis festlegen
  - Automatischen Neustart konfigurieren
  - Cron-Job einrichten (täglich, wöchentlich, monatlich, benutzerdefiniert)
  - Kann jederzeit zur Konfigurationsänderung erneut ausgeführt werden

- **config.conf.example**: Beispiel-Konfigurationsdatei
  - Dokumentiert alle verfügbaren Optionen
  - Kann als Vorlage verwendet werden

- **Dokumentation**:
  - README.md: Ausführliche deutsche Benutzeranleitung
  - LICENSE: MIT-Lizenz
  - .gitignore: Git-Konfiguration zum Schutz sensibler Daten

### Sicherheit
- Root-Rechte-Prüfung für Update-Script
- Keine Passwörter im Klartext
- Input-Validierung für Benutzereingaben
- Lesbare Logs (chmod 755) für Systemadministratoren

---

## Legende

- **Hinzugefügt**: Neue Features
- **Geändert**: Änderungen an bestehenden Funktionen
- **Veraltet**: Features, die bald entfernt werden
- **Entfernt**: Entfernte Features
- **Behoben**: Bugfixes
- **Sicherheit**: Sicherheits-relevante Änderungen
- **Dokumentation**: Änderungen an der Dokumentation

---

## Versionierung

Das Projekt verwendet [Semantic Versioning](https://semver.org/lang/de/):

- **MAJOR** (1.x.x): Nicht abwärtskompatible API-Änderungen
- **MINOR** (x.1.x): Neue Funktionen (abwärtskompatibel)
- **PATCH** (x.x.1): Bugfixes (abwärtskompatibel)

[1.1.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases/tag/v1.0.0
