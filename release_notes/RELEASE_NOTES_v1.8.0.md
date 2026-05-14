# Release Notes - v1.8.0

**Release-Datum:** 2026-04-04

## Übersicht

v1.8.0 bringt **Backup-Integration** mit vier Methoden (rsync, Btrfs, LVM, ZFS), automatischer Rotation und einer intelligenten Laufwerk-Prüfung — sowie eine optionale **System-Last-Prüfung**, die Updates auf stark ausgelasteten Systemen verhindert.

Außerdem werden ab dieser Version alle `apt-get`-Aufrufe mit `DEBIAN_FRONTEND=noninteractive` ausgeführt, was die bekannten debconf-Warnungen in Cron-Umgebungen beseitigt.

---

## 💾 Neues Feature: Backup-Integration

Automatische Backups vor Updates — lokal oder auf externem Laufwerk.

### Unterstützte Methoden

| Methode | Beschreibung | Voraussetzung |
|---------|-------------|---------------|
| `rsync` | Vollst��ndiges Dateisystem-Backup (Standard) | `rsync` |
| `btrfs` | Subvolume-Snapshot (schnell, platzsparend) | Btrfs-Root + `btrfs-progs` |
| `lvm`   | LVM-Snapshot des Root-Volumes | LVM + `lvm2` |
| `zfs`   | ZFS-Snapshot des Root-Datasets | ZFS + `zfsutils` |

### Konfiguration (`config.conf`)

```bash
# Backup aktivieren
ENABLE_BACKUP=false

# Methode: rsync | btrfs | lvm | zfs
BACKUP_METHOD="rsync"

# Zielverzeichnis (für rsync und btrfs)
BACKUP_TARGET="/backup/system"

# Anzahl zu behaltender Backups
BACKUP_RETENTION=3

# Backup vor Distribution-Upgrades erzwingen (auch wenn ENABLE_BACKUP=false)
BACKUP_BEFORE_UPGRADE=true
```

### Backup-Ziel auf gleichem Laufwerk

Das Script erkennt automatisch ob das Backup-Ziel auf demselben Laufwerk wie `/` liegt und prüft den verfügbaren Speicherplatz:

- **Genug Platz (≥ Systemgröße + 20%)** → Warnung, Backup läuft weiter
- **Zu wenig Platz** → Fehler, Backup wird übersprungen — Update läuft weiter

```
[WARNUNG] Backup-Ziel liegt auf demselben Laufwerk wie das System (/)
[WARNUNG] Genug freier Speicher vorhanden (45.2 GB frei, 28.8 GB benötigt) - Backup wird fortgesetzt
```

**Empfehlung:** Backup-Ziel auf einem separaten Laufwerk anlegen.

### Automatische Backup-Rotation

Älteste Backups werden automatisch gelöscht wenn mehr als `BACKUP_RETENTION` Einträge vorhanden sind:

```
[INFO] Rotiere Backups: 1 alte Backup(s) werden gelöscht
[INFO] Lösche altes Backup: /backup/system/system-20260301_030012
```

### Ablauf im Hauptprogramm

```
1. Root-Check
2. System-Last prüfen          ← NEU (v1.8.0)
3. Distribution erkennen
4. NVIDIA-Kompatibilität prüfen
5. Pre-Hooks ausführen
6. Backup erstellen            ← NEU (v1.8.0)
7. Update/Upgrade durchführen
8. Post-Hooks ausführen
```

---

## ⚙️ Neues Feature: System-Last-Prüfung

Updates werden abgebrochen wenn das System zu stark ausgelastet ist — nützlich für Server im Produktivbetrieb.

### Konfiguration (`config.conf`)

```bash
# Load-Check aktivieren (Standard: false)
UPDATE_LOAD_CHECK=false

# Maximale 1-Minuten-Last
UPDATE_MAX_LOAD="2.0"
```

### Beispiel

```
[INFO]    System-Last akzeptabel (0.8) - Update wird gestartet
[WARNUNG] System-Last zu hoch (3.4 > 2.0) - Update wird abgebrochen
```

Bei zu hoher Last beendet das Script mit Exit-Code 1 — ein Cron-Job wird beim nächsten geplanten Zeitpunkt automatisch erneut versucht.

---

## 🔧 Fix: debconf-Warnungen in Cron-Umgebungen

Alle `apt-get`-Aufrufe verwenden jetzt `DEBIAN_FRONTEND=noninteractive`. Die bisherige Fehlerkette beim Ausführen ohne Terminal entfällt:

```
# Vorher:
debconf: kann Oberfläche nicht initialisieren: Dialog
debconf: greife zurück auf die Oberfläche: Readline
debconf: kann Oberfläche nicht initialisieren: Readline
debconf: greife zurück auf die Oberfläche: Teletype
...

# Jetzt: Keine Warnungen mehr
```

Betrifft: `update`, `upgrade`, `dist-upgrade`, `autoremove`, `autoclean`, `install`.

---

## Änderungen im Überblick

| Datei | Änderungen |
|-------|-----------|
| `update.sh` | +8 neue Funktionen, DEBIAN_FRONTEND für alle apt-get Aufrufe, 2 neue Config-Blöcke |
| `lang/de.lang` | +37 neue Sprachmeldungen (Backup, Load-Check) |
| `lang/en.lang` | +37 neue Sprachmeldungen (Backup, Load-Check) |
| `README.md` | Neue Abschnitte: Backup-Integration, System-Last-Prüfung |
| `README.en.md` | Neue Abschnitte: Backup Integration, System Load Check |
| `ROADMAP.md` | v1.8.0 als ✅ markiert, v1.9.0 ergänzt |

**Statistik:** 8 Dateien, +905 / -56 Zeilen, ShellCheck: 0 Warnungen

---

## Upgrade von v1.7.x

```bash
git pull
```

Die neuen Parameter werden beim nächsten `./install.sh` in die Config geschrieben. Bestehende Configs funktionieren weiterhin — Backup und Load-Check sind standardmäßig deaktiviert (`ENABLE_BACKUP=false`, `UPDATE_LOAD_CHECK=false`), es ändert sich also ohne Konfigurationsänderung nichts am bisherigen Verhalten.

---

## Bekannte Einschränkungen

- Bei `rsync`-Backups wird `/var/log/*` ausgeschlossen — wer Logs sichern möchte, kann `BACKUP_TARGET` auf ein separates Laufwerk legen und den rsync-Aufruf via Pre-Hook erweitern.
- LVM-Snapshots benötigen freien Speicher in der Volume Group (standardmäßig 10 GB reserviert).
- Die Progress-Anzeige und das Bandwidth-Limit sind für **v1.9.0** geplant.
