# Release Notes - Version 1.3.0

**Veröffentlichungsdatum:** 16. Dezember 2025

## Highlights

Wir freuen uns, die Version 1.3.0 unseres automatisierten Linux Update-Scripts vorzustellen! Diese Version erweitert die Unterstützung um zwei weitere beliebte Linux-Distributionen: **Solus** und **Void Linux**.

### Neue Features

#### 🎉 Solus Unterstützung
- Vollständige Unterstützung für Solus-basierte Distributionen
- Automatische Updates via `eopkg update-repo` und `eopkg upgrade -y`
- Integrierte Fehlerbehandlung und Logging

#### 🎉 Void Linux Unterstützung
- Vollständige Unterstützung für Void Linux
- Automatische Updates via `xbps-install -Su -y`
- Nahtlose Integration in das bestehende Update-Framework

### Verbesserungen

- **Code-Qualität**: Alle ShellCheck-Warnungen wurden behoben, was zu robusterem und wartbarerem Code führt
- **Fehlerbehandlung**: Syntax-Fehler in den neuen Funktionen wurden korrigiert
- **GitHub Integration**: Professionelle Repository-Einrichtung mit:
  - Issue Templates (Bug Reports, Feature Requests)
  - Pull Request Template
  - GitHub Actions Workflow für automatische ShellCheck-Validierung
  - CONTRIBUTING.md, SECURITY.md und CODE_OF_CONDUCT.md

## Unterstützte Distributionen

Das Script unterstützt jetzt **8 Distributionsfamilien**:

- **Debian-Familie**: Debian, Ubuntu, Linux Mint
- **RedHat-Familie**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **SUSE-Familie**: openSUSE (Leap/Tumbleweed), SLES
- **Arch-Familie**: Arch Linux, Manjaro, EndeavourOS, Garuda Linux, ArcoLinux
- **Solus**: Solus ⭐ NEU
- **Void Linux**: Void Linux ⭐ NEU

## Besonderer Dank an unsere Community

Diese Version wäre nicht möglich ohne die wertvollen Beiträge unserer Community-Mitglieder:

### 🙏 Contributors

- **[@mrtoadie](https://github.com/mrtoadie)** (Toadie)
  - Pull Request #3: Solus Unterstützung
  - Implementierung der `update_solus()` Funktion
  - Dokumentation und Tests für Solus-Systeme

- **[@tbreswald](https://github.com/tbreswald)** (Torsten Breswald)
  - Pull Request #4: Void Linux Unterstützung
  - Implementierung der `update_void()` Funktion
  - Integration in das bestehende Framework

**Vielen Dank für eure wertvollen Beiträge! 🎉**

Eure Pull Requests haben das Projekt bereichert und helfen vielen weiteren Linux-Nutzern, ihre Systeme automatisiert zu aktualisieren.

## Installation und Update

### Neu-Installation

```bash
cd ~
git clone https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux.git linux-update-script
cd linux-update-script
./install.sh
```

### Update für bestehende Installationen

```bash
cd ~/linux-update-script  # oder /opt/linux-update-script
git pull
# Optional: Installationsskript erneut ausführen für neue Features
./install.sh
```

## Wichtige Links

- [Vollständiges Changelog](CHANGELOG.md)
- [Dokumentation](README.md)
- [GitHub Repository](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux)
- [Issues & Bug Reports](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)
- [Contributing Guide](CONTRIBUTING.md)

## Was kommt als Nächstes?

Wir arbeiten kontinuierlich an Verbesserungen und freuen uns über weitere Community-Beiträge! Interessante zukünftige Features könnten sein:

- Unterstützung weiterer Distributionen
- Erweiterte Backup-Funktionen vor Updates
- Web-Interface für Log-Ansicht
- Update-Benachrichtigungen per Webhook (Discord, Slack, etc.)

**Habt ihr Ideen oder möchtet ihr beitragen?** Schaut euch unseren [Contributing Guide](CONTRIBUTING.md) an oder öffnet ein [Issue](https://github.com/nicolettas-muggelbude/Automatisiertes-Update-Script-fuer-Linux/issues)!

---

**Version:** 1.3.0
**Datum:** 2025-12-16
**Lizenz:** MIT License
