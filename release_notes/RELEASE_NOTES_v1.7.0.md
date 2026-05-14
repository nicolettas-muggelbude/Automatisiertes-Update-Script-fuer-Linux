# Release Notes - v1.7.0

**Release-Datum:** 2026-03-13

## Übersicht

v1.7.0 bringt das lang geplante **Hook-System** für eigene Pre/Post-Update-Scripts sowie nativen **Debian-Upgrade-Support** ohne Ubuntu-Abhängigkeiten.

---

## 🪝 Neues Feature: Hooks & Automation

Eigene Scripts vor und nach Updates ausführen — für Services, Backups, Monitoring und mehr.

### Hook-Verzeichnisse

```
/etc/update-hooks/pre.d/   ← läuft VOR dem Update
/etc/update-hooks/post.d/  ← läuft NACH dem Update (auch bei Fehlern)
```

### Funktionsweise

- Scripts werden **alphabetisch** ausgeführt (`10-` vor `20-` vor `90-`)
- Jeder Hook läuft mit konfigurierbarem **Timeout** (Standard: 5 Minuten)
- Bei **HOOKS_ABORT_ON_ERROR=true**: Pre-Hook-Fehler bricht das Update ab
- Post-Hooks laufen **immer** — auch wenn das Update fehlschlug (z.B. um gestoppte Services wieder zu starten)
- Vollständiges **Logging** aller Hook-Ausführungen

### Konfiguration (`config.conf`)

```bash
# Hooks aktivieren (true/false)
ENABLE_HOOKS=true

# Hook-Verzeichnis
HOOKS_DIR="/etc/update-hooks"

# Update abbrechen wenn Pre-Hook fehlschlägt (true/false)
HOOKS_ABORT_ON_ERROR=false

# Timeout pro Hook in Sekunden
HOOKS_TIMEOUT=300
```

### Beispiel-Hooks

```bash
# /etc/update-hooks/pre.d/10-stop-services.sh
#!/bin/bash
systemctl stop myapp.service

# /etc/update-hooks/post.d/90-start-services.sh
#!/bin/bash
systemctl start myapp.service
```

### Einrichtung via install.sh

`install.sh` erstellt die Verzeichnisse automatisch und installiert kommentierte Beispiel-Hooks als Vorlage.

---

## 🐧 Fix: Nativer Debian-Upgrade-Support (Issue #8)

Debian verwendet kein `do-release-upgrade` — das ist ein Ubuntu-Tool. Ab v1.7.0 hat Debian einen eigenen automatisierten Upgrade-Workflow.

### Upgrade-Check

Das Script erkennt anhand einer gepflegten Codename-Liste ob eine neuere Debian-Version verfügbar ist:

```
buster (10) → bullseye (11) → bookworm (12) → trixie (13)
```

Beispiel: Wer Debian 12 (bookworm) nutzt, bekommt eine Upgrade-Benachrichtigung auf Debian 13 (trixie).

### Automatischer Upgrade-Ablauf (`sudo ./update.sh --upgrade`)

```
1. Backup     /etc/apt/sources.list.bak.DATUM
2. sed -i     Codename in sources.list + sources.list.d/ ersetzen
3. apt update
4. apt dist-upgrade --simulate  (Dry-Run, Rollback möglich)
5. apt dist-upgrade -y
6. apt autoremove
```

**Rollback:** Bei Fehler in Schritt 3 oder Nutzerabbruch in Schritt 4 wird `sources.list` automatisch wiederhergestellt.

Unterstützt beide APT-Quellen-Formate: klassische `.list`-Dateien und deb822 `.sources`-Dateien.

---

## Änderungen im Überblick

| Datei | Änderungen |
|-------|-----------|
| `update.sh` | +4 Hook-Funktionen, +3 Debian-Funktionen, Hook-Aufrufe im Hauptprogramm |
| `install.sh` | +`setup_hooks()` mit Beispiel-Hooks |
| `lang/de.lang` | +19 neue Sprachmeldungen |
| `lang/en.lang` | +19 neue Sprachmeldungen |
| `config.conf` | +4 Hook-Parameter (ENABLE_HOOKS, HOOKS_DIR, HOOKS_ABORT_ON_ERROR, HOOKS_TIMEOUT) |

**Statistik:** 7 Dateien, +494 / -38 Zeilen, ShellCheck: 0 Warnungen

---

## Upgrade von v1.6.x

```bash
git pull
sudo ./install.sh   # optional: Hook-Verzeichnisse einrichten
```

Die neuen Hook-Parameter werden automatisch in neue Configs geschrieben. Bestehende Configs funktionieren weiterhin — Hooks sind standardmäßig aktiviert aber die Verzeichnisse sind leer (kein Effekt).

---

## Bekannte Einschränkungen

- Die Debian-Codename-Liste (`DEBIAN_CODENAMES_ORDERED`) wird manuell bei neuen Debian-Releases aktualisiert. Nächster Eintrag: **forky** (Debian 14, erwartet ~2027).
