# Release Notes - Version 1.4.0

**Veröffentlichungsdatum:** 24. Dezember 2025

## Highlights

Wir freuen uns, die Version 1.4.0 unseres automatisierten Linux Update-Scripts vorzustellen! Diese Version bringt **vollständige Mehrsprachigkeit** und verbesserte Code-Qualität durch behobene ShellCheck-Warnungen.

### Neue Features

#### 🌍 Mehrsprachigkeit (i18n)
- **Vollständige Unterstützung für mehrere Sprachen**
  - Deutsch (de) und Englisch (en) als Start-Sprachen
  - Automatische Sprach-Erkennung aus System-Locale
  - Manuelle Sprach-Konfiguration in `config.conf`
  - Sprachdateien in `lang/` Verzeichnis
  - Community-freundliche Übersetzungsstruktur mit `lang/README.md`

#### 📝 Mehrsprachiges install.sh
- Interaktive Sprachauswahl während der Installation
- Bilingualer Start-Dialog (Deutsch/English)
- Gewählte Sprache wird in `config.conf` gespeichert
- Separate Sprachdateien für Installer (`install-de.lang`, `install-en.lang`)

#### 🔄 Mehrsprachiges update.sh
- Alle 45+ Meldungen in Sprachdateien ausgelagert
- `load_language()` Funktion mit automatischer Erkennung
- Fallback-Mechanismus: Gewählte Sprache → Englisch → Fehler
- Unterstützt temporäre Sprachwahl via Umgebungsvariable
- Log-Level Labels ([INFO], [ERROR], [WARNING]) sind mehrsprachig

#### 🔍 Mehrsprachiges log-viewer.sh
- Separate Sprachdateien (`viewer-de.lang`, `viewer-en.lang`)
- Alle Menüs, Meldungen und Fehler mehrsprachig
- Gleicher Sprach-Mechanismus wie update.sh

#### ⚙️ Konfiguration
- Neuer Parameter `LANGUAGE` in `config.conf` (auto|de|en|...)
- Automatische Erkennung bei `LANGUAGE=auto`

### Verbesserungen

#### ✅ Code-Qualität: Alle ShellCheck-Warnungen behoben
- **SC2162**: `read` ohne `-r` Flag → `read -r` verwendet
- **SC1090/SC1091**: ShellCheck source-Direktiven für dynamische Dateien hinzugefügt
- **SC2155**: Deklaration und Zuweisung getrennt zur korrekten Exit-Code-Behandlung
- **SC2181**: Exit-Code direkt prüfen statt `$?` verwenden
- **SC2012**: `find` und `stat` statt `ls` für robuste Datei-Operationen

### Dokumentation

- **README.md**: Neue Sektion "Mehrsprachigkeit" mit vollständiger Anleitung
- **lang/README.md**: Ausführliche Anleitung für Community-Contributors und Übersetzer
- Alle Sprachdateien mit konsistenter Struktur und Kommentaren
- Standard ISO 639-1 Sprachcodes für internationale Kompatibilität

### Community

- **Einfacher Beitrag neuer Sprachen** durch Community möglich
- Klare Anleitung und Beispiele für Übersetzer in `lang/README.md`
- Strukturierte Sprachdateien erleichtern das Hinzufügen neuer Übersetzungen

## Unterstützte Distributionen

Das Script unterstützt weiterhin **8 Distributionsfamilien**:

- **Debian-Familie**: Debian, Ubuntu, Linux Mint
- **RedHat-Familie**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-Familie**: openSUSE (Leap/Tumbleweed), SLES
- **Arch-Familie**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus**: Solus
- **Void Linux**: Void Linux

Jetzt mit **vollständiger Mehrsprachigkeit** in allen Scripts!

## Installation und Update

### Neu-Installation

```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
./install.sh
```

Bei der Installation können Sie nun Ihre bevorzugte Sprache wählen (Deutsch/English) oder die automatische Erkennung nutzen.

### Update für bestehende Installationen

```bash
cd ~/linux-update-script  # oder /opt/linux-update-script
git pull
# Optional: Installationsskript erneut ausführen für Sprachauswahl
./install.sh
```

**Hinweis:** Bestehende Installationen nutzen standardmäßig die automatische Sprach-Erkennung. Sie können die Sprache in der `config.conf` manuell setzen:

```bash
LANGUAGE=de  # für Deutsch
LANGUAGE=en  # für Englisch
LANGUAGE=auto  # für automatische Erkennung
```

## Wichtige Links

- [Vollständiges Changelog](CHANGELOG.md)
- [Dokumentation](README.md)
- [Mehrsprachigkeits-Anleitung](lang/README.md)
- [GitHub Repository](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux)
- [Issues & Bug Reports](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)
- [Contributing Guide](CONTRIBUTING.md)

## Was kommt als Nächstes?

Wir arbeiten kontinuierlich an Verbesserungen und freuen uns über weitere Community-Beiträge! Interessante zukünftige Features:

- **Weitere Sprachen**: Französisch, Spanisch, Italienisch, Niederländisch, etc.
- Upgrade-Check System für automatische Update-Benachrichtigungen
- Erweiterte Backup-Funktionen vor Updates
- Web-Interface für Log-Ansicht
- Update-Benachrichtigungen per Webhook (Discord, Slack, etc.)

**Habt ihr Ideen oder möchtet ihr beitragen?**

- **Neue Sprache hinzufügen?** Schaut euch [lang/README.md](lang/README.md) an!
- **Anderes Feature?** Öffnet ein [Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)!
- **Pull Request?** Lest den [Contributing Guide](CONTRIBUTING.md)!

---

**Version:** 1.4.0
**Datum:** 2025-12-24
**Lizenz:** MIT License
