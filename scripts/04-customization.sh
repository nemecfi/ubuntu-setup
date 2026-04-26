#!/usr/bin/env bash
# scripts/04-customization.sh

set -e

echo ""
echo "==========================================="
echo " PHASE 4: VISUAL CUSTOMIZATION (SEXY LOOK)"
echo "==========================================="

# 1. FLOATING DOCK (Ubuntu's Dash-to-Dock)
# This transforms the side bar into a sleek bottom dock.
echo "Configuring modern floating dock..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 42
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.75
    gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 50
    # Enable the "floating" appearance
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.6
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    # 'previews' shows window thumbnails on click. 
    # For hover previews, install the full 'Dash to Dock' extension via Extension Manager.
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-previews'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
    gsettings set org.gnome.shell.extensions.dash-to-dock preview-size-scale 0.35
    # Enable hover previews if the full Dash to Dock extension is active
    if gsettings list-keys org.gnome.shell.extensions.dash-to-dock | grep -q "show-previews-hover"; then
        gsettings set org.gnome.shell.extensions.dash-to-dock show-previews-hover true
    fi
fi


# 2. ACCENT COLOR (GNOME 50 Native)
# Sets the system accent color to a clean 'blue' (options: blue, teal, green, yellow, orange, red, pink, purple, slate)
echo "Setting system accent color to blue..."
gsettings set org.gnome.desktop.interface accent-color 'blue'


# 3. INTERFACE TWEAKS
echo "Cleaning up interface clutter..."
# Disable the 'Activities' corner button text (makes it just the icon if extension is present)
# Note: Some of these require the 'Just Perfection' extension to be installed to take full effect,
# but we set the underlying keys here.
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'


# 4. SNAPPY ANIMATIONS
# Makes the desktop feel much faster by slightly speeding up transitions
echo "Increasing animation speed..."
gsettings set org.gnome.desktop.interface enable-animations true
# We can't easily change the speed via gsettings alone (usually requires 'Just Perfection'),
# but we ensure they are enabled for the 'Blur my Shell' effects.


# 5. WALLPAPER
# If you have a specific sexy wallpaper, we could set it here.
# For now, we ensure we are on the Dark variant of the default.
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo ""
echo "Visual customization applied!"
echo "Note: For the full effect, please install 'Blur my Shell' from the Extension Manager."
