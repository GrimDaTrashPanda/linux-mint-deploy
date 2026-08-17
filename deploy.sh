#!/usr/bin/env bash
# Linux Mint Baseline Deployment
# Idempotent: safe to re-run after adding new packages to this script.
set -e

echo "=== Linux Mint Baseline Deployment ==="

# --- Microcode ---
CPU_VENDOR=$(lscpu | grep -i "Vendor ID" | awk '{print $3}')
if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
  echo "Intel CPU detected — installing intel-microcode"
  sudo apt install -y intel-microcode
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
  echo "AMD CPU detected — installing amd64-microcode"
  sudo apt install -y amd64-microcode
fi

# --- Base update + native toolkit ---
echo "Updating package lists..."
sudo apt update

echo "Installing native toolkit..."
sudo apt install -y \
  firefox telegram-desktop shotcut gimp glances vlc p7zip-full \
  build-essential curl wget git software-properties-common

# --- fastfetch + duf (not reliably current in Mint's base repos) ---
if ! command -v fastfetch &> /dev/null; then
  echo "Installing fastfetch from GitHub release..."
  FF_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | grep "browser_download_url.*linux-amd64.deb" | cut -d '"' -f 4)
  curl -sL "$FF_URL" -o /tmp/fastfetch.deb
  sudo apt install -y /tmp/fastfetch.deb
else
  echo "fastfetch already installed, skipping"
fi

if ! command -v duf &> /dev/null; then
  echo "Installing duf from GitHub release..."
  DUF_URL=$(curl -s https://api.github.com/repos/muesli/duf/releases/latest \
    | grep "browser_download_url.*linux_amd64.deb" | cut -d '"' -f 4)
  curl -sL "$DUF_URL" -o /tmp/duf.deb
  sudo apt install -y /tmp/duf.deb
else
  echo "duf already installed, skipping"
fi

# --- Flatpak / Flathub ---
# Mint ships flatpak + Flathub preconfigured out of the box — this just
# confirms it rather than assuming, in case that's changed on your install.
if ! flatpak remote-list | grep -q flathub; then
  echo "Adding Flathub remote..."
  sudo apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
  echo "Flathub already configured, skipping"
fi

# --- Browser stack ---
# Chrome: no apt repo by default, direct .deb
if ! command -v google-chrome &> /dev/null; then
  echo "Installing Google Chrome..."
  curl -sL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb
  sudo apt install -y /tmp/chrome.deb
else
  echo "Chrome already installed, skipping"
fi

# Brave: official apt repo
if ! command -v brave-browser &> /dev/null; then
  echo "Installing Brave..."
  curl -fsS https://dl.brave.com/install.sh | sh
else
  echo "Brave already installed, skipping"
fi

# Edge: official apt repo
if ! command -v microsoft-edge-stable &> /dev/null; then
  echo "Installing Microsoft Edge..."
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
  sudo apt update
  sudo apt install -y microsoft-edge-stable
else
  echo "Edge already installed, skipping"
fi

# --- Update launchers ---
mkdir -p ~/.local/bin ~/.local/share/applications

cat > ~/.local/bin/update-core.sh << 'EOF'
#!/usr/bin/env bash
echo "=== Updating core system (apt) ==="
sudo apt update && sudo apt upgrade -y
EOF

cat > ~/.local/bin/update-apps.sh << 'EOF'
#!/usr/bin/env bash
echo "=== Updating Flatpak apps ==="
flatpak update -y
EOF

chmod +x ~/.local/bin/update-core.sh ~/.local/bin/update-apps.sh

cat > ~/.local/share/applications/update-core.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Update Core
Exec=gnome-terminal -- bash -c "~/.local/bin/update-core.sh; exec bash"
Icon=system-software-update
Terminal=false
Categories=System;
EOF

cat > ~/.local/share/applications/update-apps.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Update Apps
Exec=gnome-terminal -- bash -c "~/.local/bin/update-apps.sh; exec bash"
Icon=system-software-update
Terminal=false
Categories=System;
EOF

echo ""
echo "=== Done ==="
echo "Press Super, search 'Update' — confirm both launchers appear."
echo "No Wayland step needed — Mint Cinnamon runs X11 by default."
