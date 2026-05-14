# Release Notes - v1.9.0

**Release-Datum:** 2026-04-18

## Übersicht

v1.9.0 bringt **automatische Bandbreitenmessung und -limitierung**, eine **Update-Zeitschätzung** und einen **Snap-Paket-Check**. Das Script passt sich jetzt automatisch an die verfügbare Netzwerkverbindung an — ohne manuelle Konfiguration.

---

## 🌐 Neues Feature: Automatische Bandbreitenmessung

Das Script misst vor jedem Update die aktuelle Netzwerkbandbreite und begrenzt den Download automatisch auf einen konfigurierbaren Prozentsatz.

### Wie funktioniert es?

1. `curl` lädt eine kleine Testdatei vom distro-eigenen Mirror herunter (max. 5 Sekunden)
2. Die gemessene Geschwindigkeit wird mit `BANDWIDTH_LIMIT_PERCENT` (Standard: 80%) multipliziert
3. Das Ergebnis wird als Limit an den Paketmanager übergeben

### Warum vor jedem Update messen?

Bandbreiten ändern sich — besonders bei geteilten Verbindungen und Servern je nach aktueller Last. Eine einmalige Messung wäre schnell veraltet.

### Distro-Mirror-Mapping

| Distribution | Test-Mirror |
|---|---|
| Debian / Ubuntu / Mint | deb.debian.org |
| Fedora / RHEL / Rocky | dl.fedoraproject.org |
| openSUSE / SLES | download.opensuse.org |
| Arch / Manjaro | geo.mirror.pkgbuild.com |
| Void Linux | repo-default.voidlinux.org |
| Solus | mirrors.rit.edu |

### Bandbreitenlimit nach Paketmanager

| Paketmanager | Methode |
|---|---|
| apt (Debian/Ubuntu/Mint) | Nativ: `-o Acquire::http::Dl-Limit=<KB/s>` |
| dnf / yum (Fedora/RHEL) | Nativ: `--setopt=throttle=<KB/s>k` |
| pacman, zypper, xbps, eopkg | `trickle` (falls installiert), sonst kein Limit |

### Konfiguration

```bash
# In config.conf (oder /etc/linux-update-script/config.conf):

# Modus
BANDWIDTH_LIMIT="auto"       # auto = messen (Standard)
BANDWIDTH_LIMIT=""           # leer = volle Bandbreite, keine Messung
BANDWIDTH_LIMIT="500"        # fester Wert in KB/s

# Prozent der gemessenen Bandbreite (Standard: 80)
BANDWIDTH_LIMIT_PERCENT=80

# Eigene Test-URL (leer = automatisch per Distro)
BANDWIDTH_TEST_URL=""

# Fortschrittsanzeige (Spinner)
ENABLE_PROGRESS=true
```

---

## 📊 Neues Feature: Update-Zeitschätzung

Vor dem eigentlichen Update zeigt das Script eine Schätzung an:

```
[INFO] Schätzung: 47 Pakete, ~180 MB - voraussichtlich ~3 Min
[INFO] Schätzung: 12 Pakete - voraussichtlich ~1 Min   (ohne Größeninfo)
```

### Wie wird geschätzt?

- Paketanzahl und Downloadgröße werden per Dry-Run ermittelt (`apt-get -s`, `dnf --assumeno`)
- Downloadzeit = Größe ÷ gemessene Bandbreite
- Installationszeit = Paketanzahl × ~3 Sekunden
- Ohne bekannte Bandbreite: nur Installationszeit

---

## 🔄 Neues Feature: Snap-Paket-Check

Das Script erkennt automatisch ob Snap-Pakete manuell aktualisiert werden müssen:

- **snapd.timer aktiv** (z.B. Ubuntu): Auto-Updates laufen bereits → kein manuelles Refresh nötig
- **snapd.timer inaktiv**: `snap refresh` wird ausgeführt
- **Snap nicht installiert**: nichts zu tun

---

## ⚙️ Neue Konfigurationsparameter

| Parameter | Standard | Beschreibung |
|---|---|---|
| `BANDWIDTH_LIMIT` | `"auto"` | Bandbreitenmodus |
| `BANDWIDTH_LIMIT_PERCENT` | `80` | Prozent der gemessenen Bandbreite |
| `BANDWIDTH_TEST_URL` | `""` | Eigene Test-URL (leer = automatisch) |
| `ENABLE_PROGRESS` | `true` | Spinner und Fortschrittsanzeige |

---

## Update-Ablauf ab v1.9.0

```
1. System-Last prüfen (optional)
2. Bandbreite messen → Limit setzen
3. Update-Zeitschätzung ausgeben
4. Backup erstellen (optional)
5. System-Updates installieren (mit Bandbreitenlimit)
6. Snap-Pakete prüfen
7. Upgrade-Check
```

---

## Technische Details

- 10 neue Funktionen: `detect_bandwidth`, `get_bandwidth_test_url`, `run_with_trickle`, `estimate_update_time`, `parse_download_size_mb`, `format_duration`, `start_spinner`, `stop_spinner`, `update_snap`
- 23 neue Sprachmeldungen (DE + EN)
- ShellCheck: 0 Warnungen
- Keine Breaking Changes — alle bestehenden Konfigurationen bleiben kompatibel

---

## Upgrade von v1.8.0

Keine manuellen Schritte nötig. Die neuen Parameter (`BANDWIDTH_LIMIT="auto"` etc.) sind bereits als Defaults im Script gesetzt und funktionieren ohne Anpassung der `config.conf`.

Für Power-User: Die vollständige Dokumentation aller neuen Parameter findet sich in `config.conf.example`.
