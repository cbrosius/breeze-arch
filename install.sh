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

echo "[1/6] Installing Plymouth theme..."
mkdir -p /usr/share/plymouth/themes/breeze-arch
cp -rf "$SCRIPT_DIR/plymouth/breeze-arch/"* /usr/share/plymouth/themes/breeze-arch/
plymouth-set-default-theme breeze-arch
echo "Active Plymouth theme: $(plymouth-set-default-theme)"

echo "[2/6] Installing SDDM theme..."
mkdir -p /usr/share/sddm/themes/breeze-arch
cp -rf "$SCRIPT_DIR/sddm/breeze-arch/"* /usr/share/sddm/themes/breeze-arch/
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/10-breeze-arch.conf
[Theme]
Current=breeze-arch
EOF

echo "[3/6] Installing KSplash theme..."
mkdir -p /usr/share/plasma/look-and-feel/breeze-arch
cp -rf "$SCRIPT_DIR/ksplash/breeze-arch/"* /usr/share/plasma/look-and-feel/breeze-arch/

# Also install for the invoking user if known
CALLER_USER="${SUDO_USER:-${PKEXEC_UID:-}}"
if [ -n "$CALLER_USER" ]; then
    USER_HOME=$(eval echo "~$CALLER_USER")
    USER_LOOKFEEL="$USER_HOME/.local/share/plasma/look-and-feel/breeze-arch"
    mkdir -p "$USER_LOOKFEEL"
    cp -rf "$SCRIPT_DIR/ksplash/breeze-arch/"* "$USER_LOOKFEEL/"
    chown -R "$CALLER_USER:" "$USER_LOOKFEEL" || true
    
    # Configure KSplash for caller
    su - "$CALLER_USER" -c "kwriteconfig6 --file ksplashrc --group KSplash --key Theme breeze-arch" || true
fi

echo "[4/6] Installing UKI boot splash bitmap..."
cp -f "$SCRIPT_DIR/assets/splash-arch.bmp" /usr/share/systemd/bootctl/splash-arch-breeze.bmp

echo "[5/6] Updating mkinitcpio preset..."
PRESET_FILE="/etc/mkinitcpio.d/linux.preset"
if [ -f "$PRESET_FILE" ]; then
    cp -vb "$PRESET_FILE" "$PRESET_FILE.bak" || true
    sed -i 's|--splash [^ "]*|--splash /usr/share/systemd/bootctl/splash-arch-breeze.bmp|' "$PRESET_FILE"
fi

echo "[6/6] Regenerating Unified Kernel Image (mkinitcpio -p linux)..."
mkinitcpio -p linux

echo "========================================="
echo "Breeze-Arch installed successfully!"
echo "========================================="
