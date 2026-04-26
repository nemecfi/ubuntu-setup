#!/usr/bin/env bash
# Bootstrap script for a fresh Ubuntu 26 LTS install.
# Run with: bash setup.sh

set -e  # exit on first error

# Path to this script (so we can find the configs/ folder next to it)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Log all output (stdout and stderr) to setup.log
exec > >(tee -a "$SCRIPT_DIR/setup.log") 2>&1



# ============================================================
# 1. INSTALL APT PACKAGES
# ============================================================
echo ""
echo "=== Installing base packages ==="

# Add or remove packages here -- they are installed one by one in the loop below.
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
)

sudo apt update

for pkg in "${PACKAGES[@]}"; do
    echo ""
    echo "--- Installing $pkg ---"
    sudo apt install -y "$pkg"
done


# ============================================================
# 2. VIM CONFIG
# ============================================================
echo ""
echo "=== Setting up Vim ==="

cp "$SCRIPT_DIR/configs/vimrc" "$HOME/.vimrc"


# ============================================================
# 3. TMUX CONFIG
# ============================================================
echo ""
echo "=== Setting up Tmux ==="

cp "$SCRIPT_DIR/configs/tmux.conf" "$HOME/.tmux.conf"


# ============================================================
# 4. HSTR (appended into ~/.bashrc)
# ============================================================
echo ""
echo "=== Adding HSTR to ~/.bashrc ==="

# Only append if the marker isn't already present (idempotent)
if grep -q "# ===== HSTR =====" "$HOME/.bashrc"; then
    echo "HSTR is already in ~/.bashrc, skipping"
else
    echo "" >> "$HOME/.bashrc"
    cat "$SCRIPT_DIR/configs/hstr.bashrc" >> "$HOME/.bashrc"
    echo "HSTR appended to ~/.bashrc"
fi


# ============================================================
# 5. NERD FONT (JetBrainsMono)
# ============================================================
echo ""
echo "=== Installing JetBrainsMono Nerd Font ==="

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Font is already installed, skipping"
else
    # Download the zip directly from the Nerd Fonts GitHub release
    URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TMP=$(mktemp -d)

    echo "Downloading $URL"
    curl -fLo "$TMP/JetBrainsMono.zip" "$URL"
    unzip -o "$TMP/JetBrainsMono.zip" -d "$FONT_DIR"
    rm -rf "$TMP"

    fc-cache -f "$FONT_DIR"
    echo "Font installed"
fi


# ============================================================
# 6. VISUAL STUDIO CODE (Microsoft apt repo)
# ============================================================
echo ""
echo "=== Installing Visual Studio Code ==="

if command -v code >/dev/null; then
    echo "VS Code is already installed, skipping"
else
    # Add Microsoft signing key
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg

    # Add the repo
    echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list

    sudo apt update
    sudo apt install -y code
fi


# ============================================================
# 7. MICROSOFT EDGE (Microsoft apt repo)
# ============================================================
echo ""
echo "=== Installing Microsoft Edge ==="

if command -v microsoft-edge-stable >/dev/null; then
    echo "Edge is already installed, skipping"
else
    # Same key as VS Code, but stored under a separate name for clarity
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft-edge.gpg

    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" \
        | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

    sudo apt update
    sudo apt install -y microsoft-edge-stable
fi


# ============================================================
# 8. STEAM (via snap)
# ============================================================
echo ""
echo "=== Installing Steam ==="

if command -v steam >/dev/null || snap list steam >/dev/null 2>&1; then
    echo "Steam is already installed, skipping"
else
    sudo snap install steam
fi


# ============================================================
# 9. GHOSTTY TERMINAL (debian.griffo.io apt repo)
# ============================================================
# The griffo.io repo only ships a "noble" suite. Hardcode it instead of
# using lsb_release -- the noble package works fine on newer Ubuntus.
echo ""
echo "=== Installing Ghostty ==="

if command -v ghostty >/dev/null; then
    echo "Ghostty is already installed, skipping"
else
    # Add the griffo.io signing key
    curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
        | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg

    # Add the repo (hardcoded to noble -- griffo.io only publishes that suite)
    echo "deb https://debian.griffo.io/apt noble main" \
        | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list

    sudo apt update
    sudo apt install -y ghostty
fi

# Drop the Ghostty config (theme, font, mouse scroll tuning)
mkdir -p "$HOME/.config/ghostty"
cp "$SCRIPT_DIR/configs/ghostty.config" "$HOME/.config/ghostty/config"


# ============================================================
# 10. EXTRA APPS
# ============================================================
echo ""
echo "=== Installing extra apps ==="

# Discord (apt via direct deb download)
if command -v discord >/dev/null; then
    echo "Discord is already installed, skipping"
else
    TMP_DEB=$(mktemp)
    echo "Downloading Discord..."
    curl -fLo "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y "$TMP_DEB"
    rm -f "$TMP_DEB"
fi

# Bitwarden (snap)
if snap list bitwarden >/dev/null 2>&1; then
    echo "Bitwarden is already installed, skipping"
else
    sudo snap install bitwarden
fi

# Signal (official apt repo). The repo's only suite is "xenial" -- this is
# intentional from upstream and works on every newer Ubuntu release.
if command -v signal-desktop >/dev/null; then
    echo "Signal is already installed, skipping"
else
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://updates.signal.org/desktop/apt/keys.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/signal-desktop-keyring.gpg

    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" \
        | sudo tee /etc/apt/sources.list.d/signal-xenial.list

    sudo apt update
    sudo apt install -y signal-desktop
fi

# Antigravity
if command -v antigravity >/dev/null; then
    echo "Antigravity is already installed, skipping"
else
    echo "Installing Antigravity..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
      sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
      sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    sudo apt update
    sudo apt install -y antigravity
fi


# ============================================================
# 11. GIT GLOBAL CONFIG
# ============================================================
echo ""
echo "=== Setting up Git global config ==="

cp "$SCRIPT_DIR/configs/gitconfig" "$HOME/.gitconfig"
cp "$SCRIPT_DIR/configs/gitignore_global" "$HOME/.gitignore_global"


# ============================================================
# 12. SSH CONFIG + KEY BOOTSTRAP
# ============================================================
echo ""
echo "=== Setting up SSH ==="

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate an ed25519 key only if one doesn't exist yet
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "SSH key ~/.ssh/id_ed25519 already exists, skipping keygen"
else
    ssh-keygen -t ed25519 -C "nemecfi99@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    echo "Generated new ed25519 key at ~/.ssh/id_ed25519"
fi

cp "$SCRIPT_DIR/configs/ssh_config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"


# ============================================================
# 13. NODE.JS + AI CLI TOOLS (Claude Code, Gemini CLI)
# ============================================================
# Both CLIs are distributed as npm packages and need a recent Node (>= 18).
# Use NodeSource's LTS repo so we don't depend on whatever Node version
# Ubuntu happens to ship.
echo ""
echo "=== Installing Node.js (NodeSource LTS) ==="

if command -v node >/dev/null && node --version | grep -qE '^v(2[0-9]|[3-9][0-9])'; then
    echo "Node $(node --version) already installed, skipping NodeSource setup"
else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

echo ""
echo "=== Installing Claude Code ==="
if command -v claude >/dev/null; then
    echo "Claude Code already installed, skipping"
else
    sudo npm install -g @anthropic-ai/claude-code
fi

echo ""
echo "=== Installing Gemini CLI ==="
if command -v gemini >/dev/null; then
    echo "Gemini CLI already installed, skipping"
else
    sudo npm install -g @google/gemini-cli
fi


# ============================================================
# 14. DEFAULT APPLICATIONS
# ============================================================
echo ""
echo "=== Setting default applications ==="

# Set Microsoft Edge as default browser
xdg-settings set default-web-browser microsoft-edge.desktop

# Set VLC as default media player
xdg-mime default vlc.desktop video/mp4 video/x-matroska video/avi video/quicktime audio/mpeg audio/x-wav audio/flac audio/ogg


# ============================================================
# DONE
# ============================================================
echo ""
echo "==========================================="
echo "Setup complete."
echo "Open a new shell or run: source ~/.bashrc"
echo "==========================================="
