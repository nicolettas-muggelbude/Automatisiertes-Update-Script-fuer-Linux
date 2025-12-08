# Beiträge zum Projekt

Vielen Dank für dein Interesse, zu diesem Projekt beizutragen!

## Wie kann ich beitragen?

### Bug Reports

Wenn du einen Fehler gefunden hast:

1. **Prüfe**, ob der Fehler bereits als [Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues) gemeldet wurde
2. Wenn nicht, [erstelle ein neues Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues/new/choose) mit dem "Bug Report" Template
3. Fülle alle relevanten Abschnitte aus (Distribution, Version, Logs)
4. Beschreibe das Problem so detailliert wie möglich

### Feature Requests

Für neue Funktionen oder Verbesserungen:

1. **Prüfe** die [Issues](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues) und [Discussions](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/discussions)
2. [Erstelle ein neues Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues/new/choose) mit dem "Feature Request" Template
3. Beschreibe den Anwendungsfall und gewünschten Nutzen

### Pull Requests

Pull Requests sind herzlich willkommen!

#### Bevor du anfängst:

1. **Fork** das Repository
2. **Clone** deinen Fork lokal
3. **Erstelle** einen neuen Branch für deine Änderungen
   ```bash
   git checkout -b feature/deine-feature-beschreibung
   ```

#### Entwicklungsrichtlinien:

##### Code-Stil für Bash-Scripte:

- **Einrückung**: 4 Leerzeichen (keine Tabs)
- **Funktionsnamen**: snake_case (z.B. `update_debian`)
- **Variablen**: GROSSBUCHSTABEN für globale Variablen, lowercase für lokale
- **Kommentare**: Auf Deutsch, erkläre das "Warum", nicht das "Was"
- **Fehlerbehandlung**: Immer Exit-Codes prüfen und Fehler loggen

##### Beispiel:

```bash
# Aktualisiert Debian-basierte Systeme
update_debian() {
    log_info "Starte Update-Prozess für Debian..."

    if ! apt-get update 2>&1 | tee -a "$LOG_FILE"; then
        log_error "apt-get update fehlgeschlagen"
        return 1
    fi

    log_info "Update erfolgreich abgeschlossen"
    return 0
}
```

##### Testing:

- **Teste** deine Änderungen auf mindestens einer Distribution
- **Prüfe** die Syntax: `bash -n script.sh`
- **Führe** ShellCheck aus: `shellcheck *.sh`
- **Teste** verschiedene Konfigurationen (E-Mail an/aus, Auto-Reboot, etc.)

##### Dokumentation:

- **README.md** aktualisieren bei neuen Features
- **CHANGELOG.md** aktualisieren (Format: [Keep a Changelog](https://keepachangelog.com/de/))
- **Kommentare** im Code für komplexe Logik

#### Pull Request erstellen:

1. **Commit** deine Änderungen mit aussagekräftigen Commit-Messages:
   ```bash
   git commit -m "Füge Unterstützung für XYZ hinzu"
   ```

2. **Push** zu deinem Fork:
   ```bash
   git push origin feature/deine-feature-beschreibung
   ```

3. **Erstelle** einen Pull Request auf GitHub
4. **Fülle** das PR-Template vollständig aus
5. **Warte** auf Review und Feedback

## Unterstützte Distributionen

Wenn du eine neue Distribution hinzufügst:

### Debian-basiert
- Debian, Ubuntu, Linux Mint

### RedHat-basiert
- RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux

### SUSE-basiert
- openSUSE (Leap/Tumbleweed), SLES

### Arch-basiert
- Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux

### Neue Distribution hinzufügen:

1. Update-Funktion in `update.sh` erstellen
2. Distribution-Erkennung in `/etc/os-release` testen
3. In `README.md` dokumentieren
4. Installations-Hinweise in `install.sh` hinzufügen
5. Im `CHANGELOG.md` vermerken

## Code Review Prozess

1. Mindestens ein Maintainer reviewed den PR
2. ShellCheck CI muss erfolgreich sein
3. Alle Diskussionspunkte müssen geklärt sein
4. Nach Approval wird der PR gemerged

## Versionierung

Wir folgen [Semantic Versioning](https://semver.org/lang/de/):

- **MAJOR** (x.0.0): Breaking Changes
- **MINOR** (x.1.0): Neue Features (abwärtskompatibel)
- **PATCH** (x.x.1): Bugfixes (abwärtskompatibel)

## Lizenz

Durch das Einreichen von Code stimmst du zu, dass dein Code unter der [MIT License](LICENSE) lizenziert wird.

## Fragen?

Bei Fragen kannst du gerne:
- Ein [Discussion](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/discussions) starten
- Ein [Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues) erstellen

Vielen Dank für deine Unterstützung! 🎉
