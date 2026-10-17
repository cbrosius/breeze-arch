#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Installing Breeze-Arch Theme Package"
echo "========================================="

# Require root for system installation
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (or via pkexec/sudo)."
    echo "Re-executing with pkexec..."
    exec pkexec bash "$0" "$@"
fi

echo "[1/7] Installing Plymouth theme..."
mkdir -p /usr/share/plymouth/themes/breeze-arch
cp -rf "$SCRIPT_DIR/plymouth/breeze-arch/"* /usr/share/plymouth/themes/breeze-arch/
plymouth-set-default-theme breeze-arch
echo "Active Plymouth theme: $(plymouth-set-default-theme)"

echo "[2/7] Installing SDDM theme..."
mkdir -p /usr/share/sddm/themes/breeze-arch
cp -rf "$SCRIPT_DIR/sddm/breeze-arch/"* /usr/share/sddm/themes/breeze-arch/
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/10-breeze-arch.conf
[Theme]
Current=breeze-arch
EOF

echo "[3/7] Configuring plasmalogin (Plasma 6 Login Manager)..."
mkdir -p /var/lib/plasmalogin/wallpapers
cp -f "$SCRIPT_DIR/assets/background-1920x1080.png" /var/lib/plasmalogin/wallpapers/background-1920x1080.png

if [ -f /etc/plasmalogin.conf ]; then
    cp -vb /etc/plasmalogin.conf /etc/plasmalogin.conf.bak || true
    if grep -q "\[Greeter\]\[Wallpaper\]\[org.kde.image\]\[General\]" /etc/plasmalogin.conf; then
        sed -i 's|^Image=.*|Image=file:///var/lib/plasmalogin/wallpapers/background-1920x1080.png|' /etc/plasmalogin.conf
    else
        cat <<EOF >> /etc/plasmalogin.conf

[Greeter][Wallpaper][org.kde.image][General]
Image=file:///var/lib/plasmalogin/wallpapers/background-1920x1080.png
EOF
    fi
else
    cat <<EOF > /etc/plasmalogin.conf
[Greeter][Wallpaper][org.kde.image][General]
Image=file:///var/lib/plasmalogin/wallpapers/background-1920x1080.png
EOF
fi
echo "plasmalogin wallpaper set: $(cat /etc/plasmalogin.conf)"

echo "[4/7] Installing KSplash theme..."
mkdir -p /usr/share/plasma/look-and-feel/breeze-arch
cp -rf "$SCRIPT_DIR/ksplash/breeze-arch/"* /usr/share/plasma/look-and-feel/breeze-arch/

# Also install for the invoking user if known
CALLER_NAME="${SUDO_USER:-}"
if [ -z "$CALLER_NAME" ] && [ -n "${PKEXEC_UID:-}" ]; then
    CALLER_NAME=$(id -un "$PKEXEC_UID" 2>/dev/null || true)
fi
if [ -z "$CALLER_NAME" ]; then
    CALLER_NAME="christian"
fi

if [ -n "$CALLER_NAME" ]; then
    USER_HOME=$(getent passwd "$CALLER_NAME" | cut -d: -f6)
    if [ -d "$USER_HOME" ]; then
        USER_LOOKFEEL="$USER_HOME/.local/share/plasma/look-and-feel/breeze-arch"
        mkdir -p "$USER_LOOKFEEL"
        cp -rf "$SCRIPT_DIR/ksplash/breeze-arch/"* "$USER_LOOKFEEL/"
        chown -R "$CALLER_NAME:" "$USER_LOOKFEEL" || true
        
        # Configure KSplash for caller
        su - "$CALLER_NAME" -c "kwriteconfig6 --file ksplashrc --group KSplash --key Theme breeze-arch" || true
        su - "$CALLER_NAME" -c "kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML" || true
    fi
fi

echo "[5/7] Installing UKI boot splash bitmap..."
cp -f "$SCRIPT_DIR/assets/splash-arch.bmp" /usr/share/systemd/bootctl/splash-arch-breeze.bmp

echo "[6/7] Updating mkinitcpio preset..."
PRESET_FILE="/etc/mkinitcpio.d/linux.preset"
if [ -f "$PRESET_FILE" ]; then
    cp -vb "$PRESET_FILE" "$PRESET_FILE.bak" || true
    sed -i 's|--splash [^ "]*|--splash /usr/share/systemd/bootctl/splash-arch-breeze.bmp|' "$PRESET_FILE"
fi

echo "[7/7] Regenerating Unified Kernel Image (mkinitcpio -p linux)..."
mkinitcpio -p linux

echo "========================================="
echo "Breeze-Arch installed successfully!"
echo "========================================="
