# Breeze-Arch

Ein einheitliches, modernes **Arch Linux**-Designpaket für **KDE Plasma 6**, **Plymouth**, **SDDM** und **systemd-stub (UKI)** auf komplett schwarzem Hintergrund (`#000000`).

Basiert auf dem originalen Vektor-Logo von Arch Linux ([archlinux-logo-light-scalable.svg](https://archlinux.org/static/logos/archlinux-logo-light-scalable.svg)) und dem robusten KDE Breeze-System.

---

## 🎨 Was dieses Paket vereinheitlicht

Vom Einschalten bis zum fertigen Desktop und beim Herunterfahren bleibt das Design pixelgenau identisch:

| Station | Komponente | Beschreibung |
| :--- | :--- | :--- |
| **1. Boot-Stub** | `systemd-stub` (UKI) | Zeigt das zentrierte originale Arch-Logo auf tiefschwarzem Grund sofort nach dem BIOS/UEFI. |
| **2. Boot-Splash** | `Plymouth` (`breeze-arch`) | Das Arch-Logo bleibt exakt an derselben Position stehen; der Breeze-Ladekreis setzt nahtlos darunter ein. |
| **3. Anmeldung** | `SDDM` (`breeze-arch`) | Konsistenter schwarzer Hintergrund mit zentriertem Arch-Branding und elegantem Breeze-Login-Dialog. |
| **4. Plasma-Start**| `KSplash` (`breeze-arch`) | Nach der Passworteingabe läuft die Arch-Ladeanimation ohne Ruckeln oder Größenänderung weiter. |
| **5. Shutdown** | `Plymouth` (`breeze-arch`) | Beim Herunterfahren rotiert derselbe Ladekreis unter dem Arch-Logo bis zum Ausschalten. |

---

## 📁 Repository-Struktur

```text
breeze-arch/
├── README.md               # Diese Dokumentation
├── install.sh              # Installationsskript (automatisiert alles sicher)
├── uninstall.sh            # Deinstallationsskript (stellt Vorzustand wieder her)
├── assets/                 # Quelldateien (Original-SVG, 1080p-Background, UKI-BMP)
│   ├── archlinux-logo-light-scalable.svg
│   ├── background-1920x1080.png
│   ├── logo-566.png
│   └── splash-arch.bmp
├── plymouth/breeze-arch/   # Plymouth-Theme (Script-Modul mit Ladekreis)
├── sddm/breeze-arch/       # SDDM-Theme (Breeze-basiert mit Arch-Asset)
└── ksplash/breeze-arch/    # KDE Plasma 6 KSplash-Theme
```

---

## 🚀 Installation

```bash
# 1. In das Verzeichnis wechseln
cd ~/Projekte/breeze-arch

# 2. Ausführungsrechte vergeben (falls nötig)
chmod +x install.sh uninstall.sh

# 3. Installation ausführen (fordert bei Bedarf Root-Rechte per Polkit/Sudo an)
./install.sh
```

Das Installationsskript führt automatisch folgende Schritte durch:
1. Kopiert das Plymouth-Theme nach `/usr/share/plymouth/themes/breeze-arch` und aktiviert es.
2. Kopiert das SDDM-Theme nach `/usr/share/sddm/themes/breeze-arch` und setzt es in `/etc/sddm.conf.d/`.
3. Richtet den KSplash-Startbildschirm für KDE Plasma 6 ein.
4. Aktualisiert das UKI-Splash-Bild in `/usr/share/systemd/bootctl/` und `/etc/mkinitcpio.d/linux.preset`.
5. Baut das Unified Kernel Image (`mkinitcpio -p linux`) neu.

---

## 🔄 Deinstallation / Wiederherstellung

Möchtest du das Designpaket wieder entfernen und auf Standard-Breeze zurücksetzen:

```bash
cd ~/Projekte/breeze-arch
./uninstall.sh
```

---

## 🐙 Auf GitHub verwalten

Um dieses Repository in deinem eigenen GitHub-Konto zu speichern:

```bash
cd ~/Projekte/breeze-arch

# 1. Lokales Git-Repository initialisieren (bereits vorbereitet)
git init
git add .
git commit -m "feat: initial release of breeze-arch unified theme"

# 2. Mit deinem GitHub-Repository verknüpfen (Ersetze USERNAME/REPO)
git remote add origin git@github.com:DEIN_BENUTZERNAME/breeze-arch.git
git branch -M main
git push -u origin main
```
