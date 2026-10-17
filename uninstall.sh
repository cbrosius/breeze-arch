#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "Uninstalling Breeze-Arch Theme Package"
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (or via pkexec/sudo)."
    echo "Re-executing with pkexec..."
    exec pkexec bash "$SCRIPT_DIR/uninstall.sh" "$@"
fi

echo "[1/6] Restoring Plymouth default theme to breeze..."
plymouth-set-default-theme breeze
rm -rf /usr/share/plymouth/themes/breeze-arch

echo "[2/6] Restoring SDDM theme..."
rm -f /etc/sddm.conf.d/10-breeze-arch.conf
rm -rf /usr/share/sddm/themes/breeze-arch

echo "[3/6] Restoring plasmalogin configuration..."
if [ -f /etc/plasmalogin.conf.bak ]; then
    cp -vf /etc/plasmalogin.conf.bak /etc/plasmalogin.conf
fi
rm -f /var/lib/plasmalogin/wallpapers/background-1920x1080.png

echo "[4/6] Restoring KSplash..."
rm -rf /usr/share/plasma/look-and-feel/breeze-arch

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
        rm -rf "$USER_HOME/.local/share/plasma/look-and-feel/breeze-arch"
        su - "$CALLER_NAME" -c "kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.kde.breeze.desktop" || true
    fi
fi

echo "[5/6] Restoring mkinitcpio UKI splash..."
rm -f /usr/share/systemd/bootctl/splash-arch-breeze.bmp
PRESET_FILE="/etc/mkinitcpio.d/linux.preset"
if [ -f "$PRESET_FILE.bak" ]; then
    cp -vf "$PRESET_FILE.bak" "$PRESET_FILE"
else
    sed -i 's|--splash [^ "]*|--splash /usr/share/systemd/bootctl/splash-arch.bmp|' "$PRESET_FILE"
fi

echo "[6/6] Regenerating Unified Kernel Image (mkinitcpio -p linux)..."
mkinitcpio -p linux

echo "========================================="
echo "Breeze-Arch uninstalled successfully!"
echo "========================================="
