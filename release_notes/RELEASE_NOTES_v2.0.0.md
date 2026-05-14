# Release Notes - v2.0.0

**Release-Datum:** 2026-05-14

## 💾 Downloads

| Plattform | Download |
|-----------|----------|
| 🐧 **Linux** Installer | [⬇ install.sh](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/releases/download/v2.0.0/install.sh) |

---

## Übersicht

v2.0.0 ist ein **Major Refactoring**: Das monolithische `update.sh` (2914 Zeilen) wurde vollständig in eine **modulare Architektur** mit 8 eigenständigen Modulen aufgeteilt. Kein neues Feature — gleiche Funktionalität wie v1.9.1, aber mit deutlich besserer Wartbarkeit und Testbarkeit als Fundament für v3.0.0.

> **⚠️ Breaking Change:** Die Legacy-Config `./config.conf` im Script-Verzeichnis wird nicht mehr unterstützt. Siehe unten für die Migrationsanleitung.

---

## 🏗️ Modulare Architektur

`update.sh` ist jetzt ein schlanker Orchestrator (~140 Zeilen), der 8 Module lädt:

| Modul | Inhalt |
|---|---|
| `lib/core.sh` | Farben, Config-Loading, Logging, Distro-Erkennung, Root-Check |
| `lib/notifications.sh` | E-Mail & Desktop-Benachrichtigungen |
| `lib/hooks.sh` | Pre/Post-Update Hook-System |
| `lib/backup.sh` | Backup-Integration (LVM, Btrfs, ZFS, Rsync) & System-Last-Prüfung |
| `lib/kernel.sh` | Kernel-Schutz, NVIDIA-Kompatibilität & Secure Boot |
| `lib/upgrades.sh` | Distribution-Upgrade-Check System |
| `lib/network.sh` | Bandbreitenmessung, Spinner, Snap-Updates & fwupd |
| `lib/distros.sh` | Paketmanager-Updates für alle Distributionen & Reboot-Check |

### Vorteile

- **Wartbarkeit**: Änderungen an einem Feature berühren nur ein Modul
- **Testbarkeit**: Jedes Modul kann isoliert getestet werden
- **Lesbarkeit**: `update.sh` zeigt auf einen Blick den gesamten Update-Ablauf
- **Fundament für v3.0.0**: Container-Support, Webhooks und Multi-System-Management werden als weitere Module eingehängt

---

## 🧪 Test-Framework (bats-core)

Erstmalig werden automatisierte Tests mitgeliefert:

| Testdatei | Abgedeckte Funktionen |
|---|---|
| `tests/test_core.bats` | Config-Loading, Logging, Sprach-Fallback, Root-Check |
| `tests/test_network.bats` | Bandbreite, Größen-Parser (MB/GB/kB), Spinner |
| `tests/test_kernel.bats` | NVIDIA-Erkennung, Secure Boot Exit-Codes, DKMS-Status |
| `tests/test_upgrades.bats` | Debian-Codenames, Upgrade-Checks, Disabled-State |

### Tests ausführen

```bash
# Voraussetzung: bats-core installieren
# Debian/Ubuntu: sudo apt install bats
# Arch:          sudo pacman -S bash-automated-testing-system

cd tests/
./run_tests.sh
```

`run_tests.sh` führt automatisch auch ShellCheck auf alle Module aus.

---

## ⚠️ Breaking Change: Legacy-Config entfernt

Die Config `./config.conf` im Script-Verzeichnis wird seit v1.6.1 als deprecated markiert und wird ab v2.0.0 nicht mehr geladen.

### Unterstützte Config-Pfade

| Typ | Pfad | Verwendung |
|---|---|---|
| System-Config | `/etc/linux-update-script/config.conf` | Cron-Jobs, alle User |
| User-Override | `~/.config/linux-update-script/config.conf` | Persönliche Einstellungen |

### Migration

```bash
# Option 1: Als System-Config (empfohlen für Cron-Jobs)
sudo mkdir -p /etc/linux-update-script
sudo cp ./config.conf /etc/linux-update-script/config.conf

# Option 2: Als User-Config
mkdir -p ~/.config/linux-update-script
cp ./config.conf ~/.config/linux-update-script/config.conf

# Option 3: Neu installieren
sudo ./install.sh
```

---

## Technische Details

- `update.sh` von 2914 auf ~140 Zeilen reduziert (Orchestrierung)
- 8 neue Module in `lib/` (gesamt ~2200 Zeilen)
- 35 Testfälle in 4 `.bats`-Dateien
- ShellCheck: 0 Fehler, 0 Warnungen auf allen 9 Dateien
- Keine neuen Abhängigkeiten

---

## Upgrade von v1.9.1

Das Script selbst funktioniert ohne Änderungen weiter — sofern keine `./config.conf` im Script-Verzeichnis verwendet wird.

```bash
# Upgrade via git
git pull

# Oder neu installieren
sudo ./install.sh
```

Bei Verwendung von `./config.conf`: Vor dem Upgrade migrieren (siehe oben).
