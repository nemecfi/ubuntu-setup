#!/usr/bin/env bash
# scripts/03-configure-system.sh

set -e

echo ""
echo "==========================================="
echo " PHASE 3: CONFIGURE SYSTEM"
echo "==========================================="

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 1. CONFIG FILES (Vim, Tmux, HSTR, Ghostty)
echo ""
echo "=== Setting up application configs ==="

cp "$SCRIPT_DIR/configs/vimrc" "$HOME/.vimrc"
cp "$SCRIPT_DIR/configs/tmux.conf" "$HOME/.tmux.conf"

if ! grep -q "# ===== HSTR =====" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    cat "$SCRIPT_DIR/configs/hstr.bashrc" >> "$HOME/.bashrc"
    echo "HSTR config added to ~/.bashrc"
fi

mkdir -p "$HOME/.config/ghostty"
cp "$SCRIPT_DIR/configs/ghostty.config" "$HOME/.config/ghostty/config"


# 2. GIT GLOBAL CONFIG
echo ""
echo "=== Setting up Git global config ==="
cp "$SCRIPT_DIR/configs/gitconfig" "$HOME/.gitconfig"
cp "$SCRIPT_DIR/configs/gitignore_global" "$HOME/.gitignore_global"


# 3. SSH CONFIG + KEY BOOTSTRAP
echo ""
echo "=== Setting up SSH ==="
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "nemecfi99@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    echo "Generated new ed25519 key."
fi
cp "$SCRIPT_DIR/configs/ssh_config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"


# 4. DEFAULT APPLICATIONS
echo ""
echo "=== Setting default applications ==="
xdg-settings set default-web-browser microsoft-edge.desktop
xdg-mime default vlc.desktop video/mp4 video/x-matroska video/avi video/quicktime audio/mpeg audio/x-wav audio/flac audio/ogg

# 4.1 FLATPAK SETUP
echo ""
echo "=== Setting up Flatpak & Flathub ==="
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 4.2 SYSTEM MONITORING & TRAY FIXES
echo ""
echo "=== Configuring Sensors & App Tray ==="
# Detect sensors automatically
sudo sensors-detect --auto > /dev/null

# Signal Desktop Tray Fix (Wayland/GNOME)
echo "Applying Signal tray icon fix..."
mkdir -p "$HOME/.local/share/applications"
if [ -f "/usr/share/applications/signal-desktop.desktop" ]; then
    cp /usr/share/applications/signal-desktop.desktop "$HOME/.local/share/applications/"
    sed -i 's|Exec=/opt/Signal/signal-desktop|Exec=/opt/Signal/signal-desktop --use-tray-icon|' "$HOME/.local/share/applications/signal-desktop.desktop"
fi


# 5. GNOME TWEAKS
echo ""
echo "=== Applying GNOME tweaks ==="

# UI & Theme Tweaks
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Workflow Tweaks
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Fix search providers (Settings, Files, etc.)
echo "Configuring search providers..."
gsettings set org.gnome.desktop.search-providers disable-external false
gsettings set org.gnome.desktop.search-providers disabled "['firefox_firefox.desktop', 'firefox.desktop']"
gsettings set org.gnome.desktop.search-providers enabled "['org.gnome.Settings.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.Characters.desktop']"

# Nautilus (File Manager) Tweaks
echo "Applying File Manager tweaks..."
gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

# Dock tweaks
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    echo "Hiding trash bin and enabling minimize on click..."
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
fi
