#!/usr/bin/env bash
# scripts/01-debloat-and-perf.sh

set -e

echo ""
echo "==========================================="
echo " PHASE 1: DEBLOAT & PERFORMANCE"
echo "==========================================="

# 1. REMOVE BLOATWARE
echo ""
echo "=== Removing default bloatware ==="

# Remove specific snaps first
echo "Removing Firefox and Thunderbird snaps..."
for s in firefox thunderbird; do
    if snap list "$s" >/dev/null 2>&1; then
        sudo snap remove "$s"
    fi
done

BLOAT_PACKAGES=(
    totem
    rhythmbox
    gnome-mahjongg
    gnome-mines
    gnome-sudoku
    aisleriot
    thunderbird
    transmission-gtk
    yelp
    gnome-weather
    gnome-maps
    gnome-contacts
    geary
    firefox
)

for pkg in "${BLOAT_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        echo "Removing $pkg..."
        sudo apt purge -y "$pkg"
    fi
done
sudo apt autoremove -y


# 2. SWAPPINESS (Performance)
echo ""
echo "=== Tuning swappiness ==="
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    echo "Swappiness set to 10."
else
    echo "Swappiness is already tuned (set to 10)."
fi


# 3. NETWORK MANAGER WAIT ONLINE (Boot Speed)
echo ""
echo "=== Disabling NetworkManager-wait-online ==="
# Masking it is more effective at preventing it from being started by dependencies
if systemctl is-enabled NetworkManager-wait-online.service >/dev/null 2>&1; then
    sudo systemctl disable NetworkManager-wait-online.service
    sudo systemctl mask NetworkManager-wait-online.service
    echo "NetworkManager-wait-online disabled and masked."
else
    echo "NetworkManager-wait-online already disabled."
fi


# 4. GRUB TIMEOUT (Boot Speed)
echo ""
echo "=== Reducing GRUB timeout ==="
if grep -q "GRUB_TIMEOUT=10" /etc/default/grub; then
    sudo sed -i 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/' /etc/default/grub
    sudo update-grub
    echo "GRUB timeout reduced to 1 second."
else
    echo "GRUB timeout already tuned or not set to 10."
fi
