# Release Notes v1.6.0 - XDG-Konformität & NVIDIA Secure Boot

**Release-Datum:** 2026-01-25
**Version:** v1.6.0
**Codename:** "Safe & Sound"

---

## 🎯 Highlights

Dies ist das **größte Update** seit v1.5.0 mit Fokus auf:

1. ✅ **XDG-Konformität** - Config-Dateien jetzt im Standard-Verzeichnis
2. ✅ **NVIDIA Secure Boot Support** - MOK-Signierung für NVIDIA-Treiber
3. ✅ **Kernel-Hold-Mechanismus** - Sichere Defaults bei NVIDIA-Inkompatibilität
4. ✅ **Benutzerfreundlichkeit** - Automatische Installation, bessere Defaults
5. ✅ **Ausführliche Dokumentation** - E-Mail-Setup für Anfänger erklärt

---

## 🆕 Neue Features

### 1. XDG-Konformität & Config-Migration

**Config-Dateien jetzt im Linux-Standard-Verzeichnis!**

- **Neue Location:** `~/.config/linux-update-script/config.conf`
- **Alte Location:** `~/linux-update-script/config.conf` (deprecated)
- **Automatische Migration:** Beim ersten Start werden alte Configs automatisch migriert
- **Backup:** Alte Config wird als `.migrated` gesichert

### 2. NVIDIA-Kernel-Kompatibilitätsprüfung

**Verhindert "schwarzen Bildschirm" nach Kernel-Updates!**

Das Script prüft **VOR dem Update**, ob NVIDIA-Treiber mit dem neuen Kernel kompatibel sind.

**Features:**
- ✅ Automatische NVIDIA-Treiber-Erkennung
- ✅ DKMS-Status-Prüfung
- ✅ **Secure Boot Support** mit MOK-Signierung
- ✅ **Kernel-Hold-Mechanismus** (sicherer Default)
- ✅ **Power-User-Modus** (Opt-in für Experten)

### 3. Benutzerfreundliche Defaults

**"Einfach Enter drücken = alles funktioniert"**

- E-Mail-Benachrichtigung: **JA** (Default)
- mailutils & DMA automatisch installieren
- Test-Benachrichtigungen direkt nach Installation

---

## 📚 Vollständige Release Notes

Siehe: [RELEASE_NOTES_v1.6.0.md](RELEASE_NOTES_v1.6.0.md)

---

## 🆙 Upgrade

```bash
cd ~/linux-update-script
git pull origin main
./install.sh  # Optional für neue Features
```

**Viel Erfolg mit v1.6.0!** 🚀
