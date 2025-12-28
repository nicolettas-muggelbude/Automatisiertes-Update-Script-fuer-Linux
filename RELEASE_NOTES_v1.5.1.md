# Release Notes - Version 1.5.1

**Veröffentlicht am:** 2025-12-27
**Typ:** Feature-Release (Minor)

---

## 🎉 Highlights

### 🔔 Desktop-Benachrichtigungen

Das Script zeigt jetzt **Popup-Benachrichtigungen** für wichtige Events!

**Benachrichtigungen bei:**
- ✅ Update erfolgreich abgeschlossen
- ✅ Distribution-Upgrade verfügbar
- ✅ Update fehlgeschlagen (kritisch)
- ✅ Neustart erforderlich

**Features:**
- Funktioniert automatisch auch als `root` (zeigt Notification für aktuellen User)
- Unterstützt alle gängigen Desktop-Umgebungen (GNOME, KDE, XFCE, Cinnamon, MATE, LXQt, Budgie)
- Konfigurierbar über `ENABLE_DESKTOP_NOTIFICATION` und `NOTIFICATION_TIMEOUT`
- Graceful Degradation: Kein Fehler wenn `notify-send` nicht verfügbar

**Installation:**
```bash
# Debian/Ubuntu
sudo apt-get install libnotify-bin

# Fedora/RHEL
sudo dnf install libnotify

# Arch
sudo pacman -S libnotify
```

### 📧 DMA - Empfohlene MTA-Lösung

Basierend auf **Community-Feedback** ist jetzt **DMA (DragonFly Mail Agent)** die empfohlene Lösung für E-Mail-Benachrichtigungen!

**Warum DMA?**
- ✅ Keine Konfiguration nötig - einfach installieren und es funktioniert
- ✅ Kein laufender Dienst im Hintergrund
- ✅ Kein offener Port (25)
- ✅ Keine Queue
- ✅ Perfekt für lokale Mails (cron, mail)

**Installation:**
```bash
sudo apt-get install dma
# Das war's - DMA funktioniert sofort!
```

---

## ✨ Neue Features

### Desktop-Benachrichtigungen

**Neue Funktion:**
- `send_notification()` - Zentrale Funktion für Desktop-Notifications

**Konfiguration:**
```bash
# In config.conf
ENABLE_DESKTOP_NOTIFICATION=true
NOTIFICATION_TIMEOUT=5000  # Millisekunden
```

**Sprachmeldungen:**
- 8 neue Messages in Deutsch und Englisch
- NOTIFICATION_UPDATE_SUCCESS
- NOTIFICATION_UPDATE_FAILED
- NOTIFICATION_UPGRADE_AVAILABLE
- NOTIFICATION_REBOOT_REQUIRED

### E-Mail-Verbesserungen

**Dokumentation:**
- DMA als empfohlene Lösung prominent dokumentiert
- Alternativen (ssmtp, postfix) weiterhin verfügbar
- Einfachere Installationsanleitung

---

## 📝 Änderungen

### Code

**update.sh:**
- `send_notification()` Funktion hinzugefügt
- Notifications nach Update-Erfolg
- Notifications bei verfügbarem Upgrade
- Notifications bei Update-Fehler
- Notifications bei erforderlichem Neustart
- Automatische DISPLAY und DBUS_SESSION_BUS_ADDRESS Konfiguration für root

**config.conf.example:**
- `ENABLE_DESKTOP_NOTIFICATION` (default: true)
- `NOTIFICATION_TIMEOUT` (default: 5000)

**Sprachdateien:**
- de.lang: 8 neue Meldungen
- en.lang: 8 neue Meldungen

### Dokumentation

**README.md:**
- Neue Sektion "Desktop-Benachrichtigungen"
- DMA als empfohlene MTA-Lösung
- Installationsanleitungen aktualisiert
- Feature-Liste erweitert

**CHANGELOG.md:**
- Vollständiger Eintrag für v1.5.1
- Technische Details dokumentiert

---

## 🔧 Technische Details

### Desktop-Notifications

- Verwendet `notify-send` (libnotify)
- DISPLAY=:0 für graphische Anzeige
- DBUS_SESSION_BUS_ADDRESS automatisch gesetzt
- Icons: software-update-available, system-software-update, dialog-error, system-reboot
- Urgency: normal für Updates/Upgrades, critical für Fehler

### Kompatibilität

- ✅ Abwärtskompatibel mit v1.5.0
- ✅ Keine Breaking Changes
- ✅ ShellCheck-konform (0 Warnungen)
- ✅ Funktioniert auch ohne libnotify (Notifications werden dann übersprungen)

---

## 📊 Statistik

**Code-Änderungen:**
- 6 Dateien geändert
- +244 / -19 Zeilen
- 1 neue Funktion (`send_notification()`)
- 2 neue Konfigurationsparameter
- 8 neue Sprachmeldungen

---

## 🙏 Community

- **DMA-Empfehlung** basierend auf User-Feedback
- Einfachere Lösung für typische Use-Cases
- Danke an @Community für den Vorschlag!

---

## 🚀 Upgrade von v1.5.0

```bash
cd ~/linux-update-script
git pull origin main

# Optional: Neue Features in config.conf aktivieren
echo "ENABLE_DESKTOP_NOTIFICATION=true" >> config.conf
echo "NOTIFICATION_TIMEOUT=5000" >> config.conf

# libnotify installieren (für Desktop-Notifications)
sudo apt-get install libnotify-bin  # Debian/Ubuntu
```

---

## 📦 Was kommt als Nächstes?

**v1.6.0** (geplant):
- Weitere Desktop-Notification-Verbesserungen
- Zusätzliche Konfigurationsoptionen

**v1.7.0** (geplant):
- Pre/Post-Update Hooks
- Custom Scripts vor und nach Updates

**v2.0.0** (geplant):
- Modulare Code-Architektur
- Test-Framework
- Container-Support

Siehe [ROADMAP.md](ROADMAP.md) für Details.

---

## 🔗 Links

- **GitHub Repository:** https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Roadmap:** [ROADMAP.md](ROADMAP.md)

---

**Viel Spaß mit v1.5.1! 🎉**

Bei Fragen oder Problemen bitte ein Issue auf GitHub öffnen.
