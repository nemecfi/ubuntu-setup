#!/usr/bin/env bash
# scripts/02-install-packages.sh

set -e

echo ""
echo "==========================================="
echo " PHASE 2: INSTALL PACKAGES"
echo "==========================================="

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Add Microsoft signing keys directory
sudo install -d -m 0755 /etc/apt/keyrings

# 1. INSTALL BASE APT PACKAGES
echo ""
echo "=== Installing base packages ==="
PACKAGES=(
    vim
    tmux
    hstr
    git
    curl
    unzip
    wl-clipboard
    apt-transport-https
    ca-certificates
    gnupg
    gnome-tweaks
    gnome-shell-extension-manager
    ubuntu-restricted-extras
    amd64-microcode
    mesa-vulkan-drivers
    vulkan-tools
    mesa-utils
    fzf
    fastfetch
    flatpak
    gnome-software-plugin-flatpak
    lm-sensors
    gnome-shell-extension-appindicator
    lazygit
)

# Automate EULA acceptance for ttf-mscorefonts-installer
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
sudo apt update

for pkg in "${PACKAGES[@]}"; do
    echo "--- Installing $pkg ---"
    sudo apt install -y "$pkg"
done


# 2. NERD FONT
echo ""
echo "=== Installing JetBrainsMono Nerd Font ==="
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Font is already installed, skipping"
else
    URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TMP=$(mktemp -d)
    echo "Downloading $URL"
    curl -fLo "$TMP/JetBrainsMono.zip" "$URL"
    unzip -o "$TMP/JetBrainsMono.zip" -d "$FONT_DIR"
    rm -rf "$TMP"
    fc-cache -f "$FONT_DIR"
    echo "Font installed"
fi


# 3. VISUAL STUDIO CODE
echo ""
echo "=== Installing Visual Studio Code ==="
if command -v code >/dev/null; then
    echo "VS Code is already installed, skipping"
else
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
fi


# 4. MICROSOFT EDGE
echo ""
echo "=== Installing Microsoft Edge ==="
if command -v microsoft-edge-stable >/dev/null; then
    echo "Edge is already installed, skipping"
else
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/microsoft-edge.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    sudo apt update
    sudo apt install -y microsoft-edge-stable
fi


# 5. STEAM
echo ""
echo "=== Installing Steam ==="
if command -v steam >/dev/null || snap list steam >/dev/null 2>&1; then
    echo "Steam is already installed, skipping"
else
    sudo snap install steam
fi


# 6. GHOSTTY
echo ""
echo "=== Installing Ghostty ==="
if command -v ghostty >/dev/null; then
    echo "Ghostty is already installed, skipping"
else
    curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
    echo "deb https://debian.griffo.io/apt noble main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
    sudo apt update
    sudo apt install -y ghostty
fi


# 7. EXTRA APPS (Discord, Bitwarden, Obsidian, Signal, Antigravity)
echo ""
echo "=== Installing extra apps ==="

if command -v discord >/dev/null; then
    echo "Discord is already installed, skipping"
else
    TMP_DEB=$(mktemp --suffix=.deb)
    echo "Downloading Discord..."
    curl -fLo "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y "$TMP_DEB"
    rm -f "$TMP_DEB"
fi

if snap list bitwarden >/dev/null 2>&1; then
    echo "Bitwarden is already installed, skipping"
else
    sudo snap install bitwarden
fi

if command -v obsidian >/dev/null; then
    echo "Obsidian is already installed, skipping"
else
    TMP_DEB=$(mktemp --suffix=.deb)
    echo "Downloading Obsidian..."
    URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb"
    curl -fLo "$TMP_DEB" "$URL"
    sudo apt install -y "$TMP_DEB"
    rm -f "$TMP_DEB"
fi

if command -v signal-desktop >/dev/null; then
    echo "Signal is already installed, skipping"
else
    curl -fsSL https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/signal-desktop-keyring.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update
    sudo apt install -y signal-desktop
fi

if command -v antigravity >/dev/null; then
    echo "Antigravity is already installed, skipping"
else
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    sudo apt update
    sudo apt install -y antigravity
fi


# 8. NODE.JS & AI CLIs
echo ""
echo "=== Installing Node.js & AI CLIs ==="
if command -v node >/dev/null && node --version | grep -qE '^v(2[0-9]|[3-9][0-9])'; then
    echo "Node $(node --version) already installed, skipping"
else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

if command -v claude >/dev/null; then
    echo "Claude Code already installed, skipping"
else
    sudo npm install -g @anthropic-ai/claude-code
fi

if command -v gemini >/dev/null; then
    echo "Gemini CLI already installed, skipping"
else
    sudo npm install -g @google/gemini-cli
fi
