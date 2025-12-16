# Language Files / Sprachdateien

This directory contains language files for the Linux Update Script.
Dieses Verzeichnis enthält Sprachdateien für das Linux Update-Script.

## Available Languages / Verfügbare Sprachen

- `de.lang` - Deutsch (German)
- `en.lang` - English

## How to Use / Verwendung

The language is automatically detected from your system locale or can be configured in `config.conf`:

Die Sprache wird automatisch aus Ihrer System-Locale erkannt oder kann in `config.conf` konfiguriert werden:

```bash
# Auto-detect (default) / Automatische Erkennung (Standard)
LANGUAGE=auto

# Or specify manually / Oder manuell festlegen
LANGUAGE=de
LANGUAGE=en
```

## Contributing a Translation / Eine Übersetzung beitragen

We welcome translations! Here's how to contribute:
Wir freuen uns über Übersetzungen! So kannst du beitragen:

### 1. Copy the English template / Kopiere die englische Vorlage

```bash
cp en.lang your_language.lang
# Example: cp en.lang fr.lang
```

### 2. Translate all messages / Übersetze alle Nachrichten

Edit `your_language.lang` and translate all message strings.
Keep the variable names unchanged, only translate the values.

Bearbeite `your_language.lang` und übersetze alle Nachrichten.
Behalte die Variablennamen bei, übersetze nur die Werte.

Example / Beispiel:
```bash
# English
MSG_ROOT_REQUIRED="This script must be run as root!"

# French
MSG_ROOT_REQUIRED="Ce script doit être exécuté en tant que root!"
```

### 3. Update the language info / Aktualisiere die Sprachinfo

At the end of the file:
Am Ende der Datei:

```bash
LANGUAGE_NAME="Français"  # Native language name
LANGUAGE_CODE="fr"        # ISO 639-1 code
```

### 4. Test your translation / Teste deine Übersetzung

```bash
LANGUAGE=fr sudo ./update.sh
```

### 5. Submit a Pull Request / Reiche einen Pull Request ein

Submit your translation via GitHub Pull Request with:
Reiche deine Übersetzung via GitHub Pull Request ein mit:

- The new language file / Die neue Sprachdatei
- Updated README.md (add your language to the list) / Aktualisiertes README.md (füge deine Sprache zur Liste hinzu)

## Translation Guidelines / Übersetzungsrichtlinien

1. **Keep formatting / Formatierung beibehalten**: Don't change `%s`, `$VAR`, etc.
2. **Be concise / Sei prägnant**: Log messages should be short and clear
3. **Stay technical / Bleib technisch**: Use proper technical terminology
4. **Test thoroughly / Gründlich testen**: Test all message outputs
5. **Native speaker / Muttersprachler**: Ideally, translate to your native language

## Language Codes / Sprachcodes

Use [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) two-letter codes:

- `de` - German / Deutsch
- `en` - English
- `fr` - French / Français
- `es` - Spanish / Español
- `it` - Italian / Italiano
- `pt` - Portuguese / Português
- `pl` - Polish / Polski
- `ru` - Russian / Русский
- `ja` - Japanese / 日本語
- `zh` - Chinese / 中文

## Questions? / Fragen?

Open an issue on GitHub or contact the maintainers.
Öffne ein Issue auf GitHub oder kontaktiere die Maintainer.

**Thank you for helping make this script accessible to more users!**
**Danke, dass du hilfst, dieses Script für mehr Nutzer zugänglich zu machen!**
