#!/usr/bin/env bash
# Citrix Workspace setup for Ubuntu 26 LTS.
# Installs the client (if a local .deb is provided), applies network
# tuning sysctl, drops the env-var file, and copies the wfclient.ini
# tweaks. Run AFTER setup.sh.
#
# Run with: bash citrixSetup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CITRIX_CFG="$SCRIPT_DIR/configs/citrix"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)


# ============================================================
# 1. INSTALL CITRIX WORKSPACE CLIENT
# ============================================================
# Citrix doesn't expose a direct .deb URL (EULA gate on download page).
# Drop the downloaded icaclient_*.deb into ./configs/citrix/ before
# running this script. If none is found, we print instructions and skip.
echo ""
echo "=== Installing Citrix Workspace ==="

if command -v wfica >/dev/null && [ -d /opt/Citrix/ICAClient ]; then
    echo "Citrix Workspace is already installed, skipping"
else
    DEB=$(ls "$CITRIX_CFG"/icaclient_*.deb 2>/dev/null | head -n1 || true)

    if [ -n "$DEB" ]; then
        echo "Installing $DEB"
        # libidn isn't a dep of icaclient on modern Ubuntu but the client links it
        sudo apt install -y libxaw7 libxmu6 libxpm4 libidn12 || true
        sudo dpkg -i "$DEB" || sudo apt -f install -y
    else
        echo "No icaclient_*.deb found in $CITRIX_CFG/"
        echo "Download from: https://www.citrix.com/downloads/workspace-app/linux/"
        echo "Place the .deb in $CITRIX_CFG/ and re-run this script."
        echo "Skipping client install -- continuing with config only."
    fi
fi


# ============================================================
# 2. NETWORK TUNING (sysctl)
# ============================================================
# TCP buffer sizes, BBR congestion control, keepalive tuning -- all
# aimed at making ICA/HDX feel snappier over typical home/WAN links.
echo ""
echo "=== Applying network tuning sysctl ==="

SYSCTL_DST=/etc/sysctl.d/99-citrix-network.conf
sudo cp "$CITRIX_CFG/99-citrix-network.conf" "$SYSCTL_DST"
sudo sysctl --system >/dev/null
echo "sysctl applied from $SYSCTL_DST"


# ============================================================
# 3. CITRIX ENV VARS (~/.ICAClient/environment)
# ============================================================
# Sourced from ~/.bashrc so every shell that launches wfica/selfservice
# gets the AMD/Mesa/HDX tuning.
echo ""
echo "=== Installing Citrix environment file ==="

mkdir -p "$HOME/.ICAClient"
ENV_DST="$HOME/.ICAClient/environment"

if [ -f "$ENV_DST" ]; then
    cp "$ENV_DST" "$ENV_DST.bak.$TIMESTAMP"
    echo "Old $ENV_DST backed up"
fi
cp "$CITRIX_CFG/environment" "$ENV_DST"


# ============================================================
# 4. WIRE ENV FILE INTO ~/.bashrc
# ============================================================
echo ""
echo "=== Wiring Citrix env into ~/.bashrc ==="

MARKER="# ===== CITRIX ENV ====="
if grep -q "$MARKER" "$HOME/.bashrc"; then
    echo "Citrix env block is already in ~/.bashrc, skipping"
else
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak.$TIMESTAMP"
    {
        echo ""
        echo "$MARKER"
        echo "if [ -f \"\$HOME/.ICAClient/environment\" ]; then"
        echo "    source \"\$HOME/.ICAClient/environment\""
        echo "fi"
        echo "# ===== /CITRIX ENV ====="
    } >> "$HOME/.bashrc"
    echo "Citrix env source line appended to ~/.bashrc"
fi


# ============================================================
# 5. WFCLIENT.INI (Citrix client tuning)
# ============================================================
# H.264/H.265 enabled, hardware decode on, fullscreen 1920x1200,
# session reliability + tuned TCP buffers, UDP audio with latency
# control. Hotkeys remapped to Ctrl+Shift to avoid clashes with
# the local desktop's defaults.
echo ""
echo "=== Installing wfclient.ini ==="

WFCLIENT_DST="$HOME/.ICAClient/wfclient.ini"

if [ -f "$WFCLIENT_DST" ]; then
    cp "$WFCLIENT_DST" "$WFCLIENT_DST.bak.$TIMESTAMP"
    echo "Old $WFCLIENT_DST backed up"
fi
cp "$CITRIX_CFG/wfclient.ini" "$WFCLIENT_DST"


# ============================================================
# 6. CITRIX SSL CERTIFICATES
# ============================================================
# Citrix doesn't trust the system CA store by default; symlink the
# Ubuntu CA bundle into the client's cert dir so StoreFront URLs with
# regular HTTPS certs work without "SSL error 61".
echo ""
echo "=== Linking system CA certs into Citrix client ==="

CITRIX_CACERTS=/opt/Citrix/ICAClient/keystore/cacerts
if [ -d "$CITRIX_CACERTS" ] && [ -d /etc/ssl/certs ]; then
    sudo cp -n /etc/ssl/certs/*.pem "$CITRIX_CACERTS"/ 2>/dev/null || true
    sudo /opt/Citrix/ICAClient/util/ctx_rehash >/dev/null 2>&1 || true
    echo "System CA certs copied to $CITRIX_CACERTS and rehashed"
else
    echo "Citrix cert dir $CITRIX_CACERTS not present, skipping (install client first)"
fi


# ============================================================
# 7. AMD / VIDEO ACCELERATION VERIFICATION
# ============================================================
# Install Mesa + verification tools and print what HW accel the GPU
# actually exposes. Citrix wfclient.ini has H264HWDecode=True, which
# only pays off if VAAPI advertises an H.264/H.265 profile here.
echo ""
echo "=== Verifying AMD video acceleration ==="

sudo apt install -y mesa-vulkan-drivers vulkan-tools vainfo radeontop

echo ""
echo "--- vainfo (VAAPI) ---"
vainfo 2>&1 | head -20 || true

echo ""
echo "--- vulkaninfo --summary ---"
vulkaninfo --summary 2>&1 | head -20 || true

echo ""
if vainfo 2>/dev/null | grep -qE "VAProfileH264|VAProfileHEVC"; then
    echo "VAAPI exposes H.264/HEVC -- the Citrix H264HWDecode=True setting will take effect."
else
    echo "WARNING: VAAPI does not expose H.264/HEVC profiles."
    echo "Citrix HW decode will fall back to software. Consider flipping H264HWDecode=False"
    echo "in ~/.ICAClient/wfclient.ini if you see decode glitches."
fi


# ============================================================
# 8. CITRIX USB REDIRECTION + OPTIONAL FIREWALL RULES
# ============================================================
# ctxusbd is the Citrix USB daemon. The icaclient .deb usually pulls
# it in, but installing explicitly is harmless and works as a no-op
# when already present.
echo ""
echo "=== Setting up Citrix USB redirection ==="

sudo apt install -y ctxusbd 2>/dev/null || \
    echo "ctxusbd package not in apt repos -- it ships inside icaclient.deb on most builds, should already be installed"

if [ -d /opt/Citrix/ICAClient/usb ]; then
    echo "USB redirection support directory present at /opt/Citrix/ICAClient/usb"
else
    echo "Note: /opt/Citrix/ICAClient/usb missing -- install Citrix Workspace first if you need USB passthrough"
fi

# Optional firewall allow-rules for ICA. Only added if ufw is already
# active -- system hardening (enabling ufw) was deliberately not part
# of this setup.
echo ""
echo "=== Citrix firewall rules (only if ufw is active) ==="

if command -v ufw >/dev/null && sudo ufw status | grep -q "Status: active"; then
    sudo ufw allow out 1494/tcp comment "Citrix ICA"
    sudo ufw allow out 2598/tcp comment "Citrix CGP / session reliability"
    sudo ufw allow out 443/tcp comment "Citrix StoreFront / NetScaler Gateway"
    echo "Citrix outbound rules added to ufw"
else
    echo "ufw not active, skipping firewall rules"
fi


# ============================================================
# DONE
# ============================================================
echo ""
echo "==========================================="
echo "Citrix setup complete."
echo "Open a new shell so the env vars take effect, then launch"
echo "Citrix Workspace from your app menu or run: selfservice"
echo "==========================================="
