# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [Unreleased]

## [1.5.0] - 2025-12-27

### Hinzugefügt
- **Upgrade-Check System**: Automatische Erkennung verfügbarer Distribution-Upgrades
  - `check_upgrade_available()` - Zentrale Funktion für distributionsspezifische Upgrade-Checks
  - `check_upgrade_solus()` - Solus: Prüft auf ausstehende Updates (Rolling Release)
  - `check_upgrade_arch()` - Arch/Manjaro: Prüft auf verfügbare Updates (Rolling Release)
  - `check_upgrade_debian()` - Debian/Ubuntu: Erkennt neue Release-Versionen
  - `check_upgrade_fedora()` - Fedora: Erkennt neue Fedora-Versionen
  - `perform_upgrade()` - Führt Distribution-Upgrade mit Bestätigung durch
  - Automatischer Upgrade-Check nach jedem erfolgreichen Update
  - E-Mail-Benachrichtigung bei verfügbaren Upgrades
  - Backup-Warnung vor jedem Upgrade
  - Benutzer-Bestätigung erforderlich (außer bei AUTO_UPGRADE)
- **Command-Line Interface Erweiterung**:
  - `--upgrade` Flag zum manuellen Durchführen von Distribution-Upgrades
  - `--help` / `-h` Flag für Hilfe-Anzeige
- **Kernel-Schutz**: Verhindert versehentliches Entfernen von Fallback-Kerneln
  - `safe_autoremove()` - Sichere autoremove-Funktion mit Kernel-Check
  - `count_stable_kernels_debian()` - Zählt Kernel auf Debian/Ubuntu
  - `count_stable_kernels_redhat()` - Zählt Kernel auf RHEL/Fedora
  - Prüft vor autoremove ob genügend Kernel installiert sind
  - Konfigurierbare Mindestanzahl (Standard: 3 Kernel)
  - Überspringt autoremove wenn zu wenige Kernel vorhanden
  - Detailliertes Logging der Kernel-Informationen
- **Konfigurationsoptionen** (config.conf):
  - `KERNEL_PROTECTION` - Kernel-Schutz aktivieren/deaktivieren (default: true)
  - `MIN_KERNELS` - Minimale Anzahl stabiler Kernel (default: 3)
  - `ENABLE_UPGRADE_CHECK` - Upgrade-Check aktivieren/deaktivieren (default: true)
  - `AUTO_UPGRADE` - Automatisches Upgrade durchführen (default: false, WARNUNG!)
  - `UPGRADE_NOTIFY_EMAIL` - E-Mail bei verfügbarem Upgrade (default: true)
- **Mehrsprachigkeit**: 18 neue Sprachmeldungen für Upgrade-Check und Kernel-Schutz
  - Alle Messages in Deutsch (de.lang) und Englisch (en.lang)
  - MSG_UPGRADE_* - Upgrade-bezogene Meldungen
  - MSG_KERNEL_* - Kernel-Schutz Meldungen
  - EMAIL_SUBJECT_UPGRADE / EMAIL_BODY_UPGRADE - E-Mail Templates

### Geändert
- **update.sh**: Upgrade-Check wird nach erfolgreichem Update automatisch ausgeführt
- **update.sh**: Kernel-Schutz in allen Distributionen mit autoremove integriert
- **update.sh**: Hauptprogramm unterstützt Command-Line Parameter
- **E-Mail-Benachrichtigungen**: Upgrade-Verfügbarkeit wird per E-Mail gemeldet
- **Standard-Konfiguration**: Neue Default-Werte für v1.5.0 Features

### Behoben
- Keine ShellCheck-Warnungen (100% ShellCheck-konform)

### Dokumentation
- **README.md**: Vollständige Dokumentation des Upgrade-Check Systems
  - Neue Sektion "Distribution-Upgrade durchführen"
  - Neue Sektion "Kernel-Schutz" mit Beispielen
  - Aktualisierte Konfigurationsübersicht
  - Erweiterte Sicherheitshinweise
- **ROADMAP.md**: Upgrade-Check System als implementiert markiert
  - Detaillierte Feature-Beschreibung
  - Technische Implementierungsdetails
  - User-Workflows dokumentiert
  - Status auf "Feature-Complete" gesetzt
- **.claude/CLAUDE.md**: Projekt-Dokumentation erstellt
  - Vollständige Implementierungsdetails
  - Workflow-Beschreibung
  - Rückgabewerte dokumentiert

### Sicherheit
- **Kernel-Schutz**: Verhindert Bootprobleme durch fehlende Fallback-Kernel
- **Upgrade-Warnungen**: Backup-Warnung vor jedem Distribution-Upgrade
- **Opt-in System**: AUTO_UPGRADE standardmäßig deaktiviert
- **Benutzer-Bestätigung**: Manuelle Bestätigung vor kritischen Upgrades

### Technische Details
- Upgrade-Check Rückgabewerte:
  - `0` - Kein Upgrade verfügbar
  - `1` - Fehler oder nicht unterstützt
  - `2` - Updates verfügbar (Rolling Release)
  - `3` - Major-Upgrade verfügbar
- Kernel-Schutz unterstützt Debian/Ubuntu (dpkg) und RHEL/Fedora (dnf/rpm)
- Distribution-Upgrades für Debian/Ubuntu (do-release-upgrade) und Fedora (dnf system-upgrade)

## [1.4.0] - 2025-12-24

### Hinzugefügt
- **Mehrsprachigkeit (i18n)**: Vollständige Unterstützung für mehrere Sprachen
  - Deutsch (de) und Englisch (en) als Start-Sprachen
  - Automatische Sprach-Erkennung aus System-Locale
  - Manuelle Sprach-Konfiguration in config.conf
  - Sprachdateien in `lang/` Verzeichnis
  - `lang/README.md` mit Anleitung für Community-Übersetzungen
- **install.sh**: Interaktive Sprachauswahl während Installation
  - Bilingualer Start-Dialog (Deutsch/English)
  - Gewählte Sprache wird in config.conf gespeichert
  - Separate Sprachdateien für Installer (install-de.lang, install-en.lang)
- **update.sh**: Vollständig mehrsprachig
  - Alle 45+ Meldungen in Sprachdateien ausgelagert
  - `load_language()` Funktion mit Auto-Detection
  - Fallback-Mechanismus: Gewählte Sprache → Englisch → Fehler
  - Unterstützt temporäre Sprachwahl via Umgebungsvariable
- **log-viewer.sh**: Vollständig mehrsprachig
  - Separate Sprachdateien (viewer-de.lang, viewer-en.lang)
  - Alle Menüs, Meldungen und Fehler mehrsprachig
  - Gleicher Sprach-Mechanismus wie update.sh
- **config.conf**: Neuer Parameter `LANGUAGE` (auto|de|en|...)

### Geändert
- Alle Log-Ausgaben verwenden jetzt Variablen statt hart-codierte Strings
- Log-Level Labels ([INFO], [ERROR], [WARNING]) sind jetzt mehrsprachig

### Behoben
- **ShellCheck-Warnungen**: Alle ShellCheck-Warnungen in install.sh und log-viewer.sh behoben
  - SC2162: `read` ohne `-r` Flag
  - SC1090/SC1091: Source-Direktiven für dynamische Dateien
  - SC2155: Deklaration und Zuweisung getrennt
  - SC2181: Exit-Code direkt prüfen statt `$?`
  - SC2012: `find` statt `ls` für robuste Datei-Operationen

### Dokumentation
- README.md: Neue Sektion "Mehrsprachigkeit" mit vollständiger Anleitung
- lang/README.md: Anleitung für Community-Contributors
- Alle Sprachdateien mit konsistenter Struktur und Kommentaren

### Community
- Einfacher Beitrag neuer Sprachen durch Community möglich
- Klare Anleitung und Beispiele für Übersetzer
- Standard ISO 639-1 Sprachcodes

## [1.3.0] - 2025-12-16

### Hinzugefügt
- **Solus Unterstützung**: Neue `update_solus()` Funktion (PR #3, danke @mrtoadie)
  - Verwendet `eopkg update-repo` und `eopkg upgrade -y`
  - Automatische Fehlerbehandlung und Logging
- **Void Linux Unterstützung**: Neue `update_void()` Funktion (PR #4, danke @tbreswald)
  - Verwendet `xbps-install -Su -y`
  - Vollautomatische System-Updates für Void-basierte Distributionen

### Geändert
- Code-Qualität verbessert durch Behebung von ShellCheck-Warnungen
- Syntax-Fehler in `update_solus()` und `update_void()` behoben

### Dokumentation
- README.md: Solus und Void Linux zu unterstützten Distributionen hinzugefügt
- GitHub Repository professionell eingerichtet (Issue Templates, PR Template, GitHub Actions)

## [1.2.0] - 2025-11-09

### Hinzugefügt
- **Arch Linux Unterstützung**: Neue `update_arch()` Funktion
  - Unterstützung für Arch Linux und Forks
  - Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
  - Verwendet `pacman -Syu` für System-Updates
  - Automatische Paket-Cache-Bereinigung mit `pacman -Sc`
- Arch Linux zu allen Installationsanleitungen hinzugefügt
- Mail-Konfiguration für Arch/Manjaro in README.md

### Geändert
- **E-Mail-Benachrichtigung**: Verbesserte Fehlerbehandlung
  - Prüft Exit-Code von mail/sendmail Befehlen
  - Meldet nur bei erfolgreicher Zustellung "E-Mail gesendet"
  - Warnt explizit bei fehlender MTA-Konfiguration
  - Gibt konkrete Hilfestellung zur MTA-Installation
- **install.sh**: Erweiterte Mail-Programm-Hinweise
  - Erklärt Unterschied zwischen Mail-Client und MTA
  - Zeigt Installation für alle unterstützten Distributionen inkl. Arch
- **README.md**: Ausführliche E-Mail-Konfigurationsanleitung
  - Neue Sektion "E-Mail-Benachrichtigung" mit Voraussetzungen
  - Fehlerbehebung für "Cannot start /usr/sbin/sendmail"
  - Test-Anweisungen und Debugging-Tipps

### Dokumentation
- README.md: Arch Linux in unterstützte Distributionen aufgenommen
- claude.md: Distributionsliste als Familien strukturiert
- install.sh: Arch-spezifische Installationsbefehle hinzugefügt

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

[1.5.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases/tag/v1.0.0
