#!/usr/bin/env bash
# GNOME desktop tweaks for Ubuntu 26 LTS.
# Each setting is applied via gsettings so it's reproducible and idempotent.
# Run AFTER setup.sh (font + apps need to be installed first).
#
# Run with: bash gnomeSetup.sh

set -e


# ============================================================
# GUARD: only run on GNOME with gsettings available
# ============================================================
if ! command -v gsettings >/dev/null; then
    echo "gsettings not found -- this script requires GNOME. Aborting."
    exit 1
fi

case "$XDG_CURRENT_DESKTOP" in
    *GNOME*) ;;
    *)
        echo "XDG_CURRENT_DESKTOP is '$XDG_CURRENT_DESKTOP', not GNOME. Aborting."
        echo "If you really do want to apply these settings, comment out this guard."
        exit 1
        ;;
esac


# ============================================================
# 1. DARK THEME
# ============================================================
echo ""
echo "=== Setting dark theme ==="

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'


# ============================================================
# 2. KEYBOARD LAYOUTS (US primary, Czech secondary)
# ============================================================
# Toggle between layouts via the default Super+Space.
echo ""
echo "=== Adding Czech keyboard layout ==="

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'cz')]"


# ============================================================
# 3. MONOSPACE FONT
# ============================================================
# Uses the JetBrainsMono Nerd Font installed by setup.sh section 5.
echo ""
echo "=== Setting monospace font to JetBrainsMono Nerd Font ==="

gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'


# ============================================================
# 4. FRACTIONAL SCALING
# ============================================================
# Required for non-integer display scaling on HiDPI laptops.
echo ""
echo "=== Enabling fractional scaling ==="

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"


# ============================================================
# 5. DOCK TWEAKS (Ubuntu uses dash-to-dock)
# ============================================================
echo ""
echo "=== Tweaking dock ==="

# Ubuntu's dash-to-dock schema only exists if the extension is installed,
# which it is by default on Ubuntu but not on vanilla GNOME. Guard accordingly.
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
else
    echo "dash-to-dock extension not present, skipping dock tweaks"
fi


# ============================================================
# 6. DISABLE HOT CORNER
# ============================================================
echo ""
echo "=== Disabling hot corner ==="

gsettings set org.gnome.desktop.interface enable-hot-corners false


# ============================================================
# 7. SHOW BATTERY PERCENTAGE
# ============================================================
echo ""
echo "=== Showing battery percentage in status bar ==="

gsettings set org.gnome.desktop.interface show-battery-percentage true


# ============================================================
# DONE
# ============================================================
echo ""
echo "==========================================="
echo "GNOME tweaks applied."
echo "Some settings may require logging out and back in to take full effect."
echo "==========================================="
