# Release Notes - v1.9.1

**Release-Datum:** 2026-04-27

## Übersicht

v1.9.1 bringt **fwupd Firmware-Update Integration** und behebt die **curl-Abhängigkeit** für Systeme ohne vorinstalliertes curl (z.B. Ubuntu 26.04).

---

## 🔧 Neues Feature: fwupd Firmware-Updates

Firmware-Updates für UEFI, SSDs, Docks, Tastaturen und weitere Hardware via [Linux Vendor Firmware Service (LVFS)](https://fwupd.org/).

### Aktivierung

```bash
# In config.conf:
ENABLE_FWUPD=true
```

Standard ist `false` — bewusstes Opt-in, da Firmware-Updates Hardware-spezifisch sind.

### Ablauf

1. Prüft ob fwupd installiert ist — falls nicht, wird es automatisch installiert
2. `fwupdmgr refresh --force` — aktualisiert Firmware-Metadaten
3. `fwupdmgr update --assume-yes` — installiert verfügbare Firmware-Updates

### Hinweis

Manche Firmware-Updates erfordern einen Neustart. Das Script erkennt dies über den bestehenden Reboot-Check.

### Unterstützte Distributionen

| Distribution | Installations-Befehl |
|---|---|
| Debian / Ubuntu / Mint | `apt-get install fwupd` |
| Fedora / RHEL / Rocky | `dnf install fwupd` |
| openSUSE | `zypper install fwupd` |
| Arch / Manjaro | `pacman -S fwupd` |
| Void Linux | `xbps-install fwupd` |

---

## 🛠️ Bugfix: curl/wget Fallback (Ubuntu 26.04)

Ubuntu 26.04 hat curl nicht mehr als Standard installiert. Die Bandbreitenmessung bricht dadurch nicht mehr ab, sondern folgt einer Fallback-Kette:

```
1. curl verfügbar?         → curl verwenden
2. wget verfügbar?         → wget verwenden (measure_speed_wget)
3. Keines verfügbar?       → curl automatisch installieren
4. Installation fehlgeschlagen? → Messung überspringen, kein Limit
```

---

## ⚙️ Neue Konfigurationsparameter

| Parameter | Standard | Beschreibung |
|---|---|---|
| `ENABLE_FWUPD` | `false` | Firmware-Updates via fwupd aktivieren |

---

## Technische Details

- 2 neue Funktionen: `install_fwupd()`, `update_fwupd()`
- 3 neue Funktionen für curl-Fallback: `install_curl()`, `measure_speed_wget()`
- 11 neue Sprachmeldungen (DE/EN)
- ShellCheck: 0 Warnungen
- Keine Breaking Changes
