#!/usr/bin/env bash
set -euo pipefail

echo "========================================="
echo "Uninstalling Breeze-Arch Theme Package"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (or via pkexec/sudo)."
    echo "Re-executing with pkexec..."
    exec pkexec bash "$0" "$@"
fi

echo "[1/5] Restoring Plymouth default theme to breeze..."
plymouth-set-default-theme breeze
rm -rf /usr/share/plymouth/themes/breeze-arch

echo "[2/5] Restoring SDDM theme..."
rm -f /etc/sddm.conf.d/10-breeze-arch.conf
rm -rf /usr/share/sddm/themes/breeze-arch

echo "[3/5] Restoring KSplash..."
rm -rf /usr/share/plasma/look-and-feel/breeze-arch

CALLER_USER="${SUDO_USER:-${PKEXEC_UID:-}}"
if [ -n "$CALLER_USER" ]; then
    USER_HOME=$(eval echo "~$CALLER_USER")
    rm -rf "$USER_HOME/.local/share/plasma/look-and-feel/breeze-arch"
    su - "$CALLER_USER" -c "kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.kde.breeze.desktop" || true
fi

echo "[4/5] Restoring mkinitcpio UKI splash..."
rm -f /usr/share/systemd/bootctl/splash-arch-breeze.bmp
PRESET_FILE="/etc/mkinitcpio.d/linux.preset"
if [ -f "$PRESET_FILE.bak" ]; then
    cp -vf "$PRESET_FILE.bak" "$PRESET_FILE"
else
    sed -i 's|--splash [^ "]*|--splash /usr/share/systemd/bootctl/splash-arch.bmp|' "$PRESET_FILE"
fi

echo "[5/5] Regenerating Unified Kernel Image (mkinitcpio -p linux)..."
mkinitcpio -p linux

echo "========================================="
echo "Breeze-Arch uninstalled successfully!"
echo "========================================="
