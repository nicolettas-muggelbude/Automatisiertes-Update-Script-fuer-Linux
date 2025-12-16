# 🧪 BETA: Mehrsprachigkeit (v1.4.0-beta.1)

**Status:** Experimentelles Feature - Feedback erwünscht!

## Was ist neu?

Das Update-Script unterstützt jetzt **mehrere Sprachen**:
- 🇩🇪 **Deutsch** (Standard)
- 🇬🇧 **English** (Neu!)

## Für wen ist diese Beta?

- ✅ User die Englisch bevorzugen
- ✅ Internationale Community
- ✅ Tester die Feedback geben möchten
- ✅ Entwickler die weitere Sprachen beitragen wollen

## Installation (Beta)

```bash
# Beta-Branch klonen
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git
cd Automatisiertes-Update-Script-fuer-Linux
git checkout feature/i18n-multilanguage

# Oder mit Tag
git checkout v1.4.0-beta.1

# Installation wie gewohnt
./install.sh
```

## Verwendung

### 1. Sprachauswahl bei Installation

```bash
./install.sh
```

Der Installer fragt dich nach deiner bevorzugten Sprache:
```
=================================================
   Wähle deine Sprache / Choose your language
=================================================

  1) Deutsch (de)
  2) English (en)
  3) Auto-detect / Automatisch

Selection / Auswahl [1-3]:
```

### 2. Sprache ändern

**In config.conf:**
```bash
# Deutsch
LANGUAGE=de

# English
LANGUAGE=en

# Automatisch (System-Sprache)
LANGUAGE=auto
```

**Temporär für einen Lauf:**
```bash
LANGUAGE=en sudo ./update.sh
```

### 3. Automatische Erkennung

Ohne Konfiguration erkennt das Script automatisch deine System-Sprache aus der `LANG` Umgebungsvariable.

## Was wird getestet?

Bitte teste folgende Szenarien:

### ✅ Basis-Tests
- [ ] Installation mit Sprachauswahl (Deutsch)
- [ ] Installation mit Sprachauswahl (English)
- [ ] Installation mit Auto-Detect
- [ ] `sudo ./update.sh` mit Deutsch
- [ ] `sudo ./update.sh` mit English
- [ ] Sprache in config.conf ändern

### ✅ Distribution-Tests
- [ ] Debian/Ubuntu/Mint
- [ ] RHEL/Fedora/CentOS/Rocky/Alma
- [ ] openSUSE/SLES
- [ ] Arch/Manjaro/EndeavourOS
- [ ] Solus
- [ ] Void Linux

### ✅ Feature-Tests
- [ ] E-Mail-Benachrichtigungen (beide Sprachen)
- [ ] Log-Ausgaben lesbar
- [ ] Fehler-Meldungen verständlich
- [ ] Cron-Job Setup

### ✅ Edge Cases
- [ ] Nicht-existierende Sprache (sollte auf EN fallen)
- [ ] Fehlende Sprachdatei (Fallback-Mechanismus)
- [ ] System ohne LANG Variable
- [ ] Wechsel zwischen Sprachen

## Bekannte Einschränkungen

- ⚠️ Nur 2 Sprachen verfügbar (weitere folgen durch Community)
- ⚠️ Teilweise noch deutsche Strings in install.sh (nicht-kritische Bereiche wie Cron-Setup)

## Feedback geben

Wir freuen uns über dein Feedback!

### Option 1: GitHub Issue
Öffne ein Issue mit dem Label `beta-feedback`:
https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues/new

**Template:**
```markdown
## Beta-Feedback v1.4.0-beta.1

**Distribution:** [z.B. Ubuntu 24.04]
**Gewählte Sprache:** [de/en/auto]
**Was funktioniert gut:**
**Was funktioniert nicht:**
**Verbesserungsvorschläge:**
**Screenshots:** [optional]
```

### Option 2: Pull Request
Verbesserungen direkt beitragen:
- Übersetzungsfehler korrigieren
- Fehlende Strings ergänzen
- Neue Sprache hinzufügen

Siehe `lang/README.md` für Anleitung.

## Neue Sprache beitragen

Du sprichst Französisch, Spanisch, Italienisch, ...?

**So einfach geht's:**
```bash
cd lang/
cp en.lang fr.lang
nano fr.lang  # Übersetzen
```

Siehe `lang/README.md` für Details.

## Roadmap

### Beta-Phase (v1.4.0-beta.x)
- ✅ v1.4.0-beta.1 - Erste Beta-Version (Deutsch, Englisch)
- ⏳ Community-Testing und Feedback
- ⏳ Bugfixes basierend auf Feedback
- ⏳ Weitere Sprachen durch Community

### Stable Release (v1.4.0)
- Nach erfolgreicher Beta-Phase
- Dokumentation finalisiert
- Alle kritischen Bugs behoben
- Merge in main Branch

### Zukünftig (v1.5.0+)
- log-viewer.sh mehrsprachig
- Weitere Sprachen (FR, ES, IT, PT, ...)
- Übersetzungs-Vollständigkeit-Check
- Automatische Tests für alle Sprachen

## Zurück zur Stable-Version

Falls du Probleme hast:
```bash
git checkout main
./install.sh
```

## Fragen?

- 📖 Siehe [README.md](README.md) für allgemeine Dokumentation
- 🌍 Siehe [lang/README.md](lang/README.md) für Übersetzungs-Guide
- 📝 Siehe [CHANGELOG.md](CHANGELOG.md) für alle Änderungen
- 💬 Öffne ein Issue auf GitHub

---

**Vielen Dank fürs Testen! 🎉**

*Dein Feedback hilft, das Script für die internationale Community zu verbessern.*
