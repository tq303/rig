#!/bin/bash

set -e

# ghostty (skip if already installed — flatpak is the easiest fallback)
if ! command -v ghostty &>/dev/null; then
  sudo apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.mitchellh.ghostty
fi

# tools (apt)
sudo apt install -y ripgrep fd-find fzf bat ffmpeg tmux

# mkcert
sudo apt install -y libnss3-tools
MKCERT_VERSION=1.4.4
curl -Lo ~/.local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/mkcert-v${MKCERT_VERSION}-linux-amd64"
chmod +x ~/.local/bin/mkcert

bash "$(dirname "$0")/install-linux.sh"

go install github.com/tq303/valet@latest
~/go/bin/val sync --platform ubuntu

bash "$(dirname "$0")/install-tooling.sh"
