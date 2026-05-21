#!/bin/bash

set -e

bash "$(dirname "$0")/symlink.sh"

# ghostty (skip if already installed — flatpak is the easiest fallback)
if ! command -v ghostty &>/dev/null; then
  sudo apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.mitchellh.ghostty
fi

# tools (apt)
sudo apt install -y ripgrep fd-find fzf bat ffmpeg

# neovim (apt version is outdated)
sudo snap install nvim --classic

# fd and bat ship with different binary names on ubuntu
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
ln -sf "$(which batcat)" ~/.local/bin/bat

# lsd
LSD_VERSION=1.1.2
curl -Lo /tmp/lsd.deb "https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/lsd_${LSD_VERSION}_amd64.deb"
sudo dpkg -i /tmp/lsd.deb

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xzf /tmp/lazygit.tar.gz -C /tmp
sudo mv /tmp/lazygit /usr/local/bin/lazygit

# starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# gh
if ! command -v gh &>/dev/null; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update && sudo apt install -y gh
fi

# go
if ! command -v go &>/dev/null; then
  GO_VERSION=1.23.4
  curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  export PATH=$PATH:/usr/local/go/bin
fi

# uv
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# valet
go install github.com/tq303/valet@latest

# node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.17

# mkcert
sudo apt install -y libnss3-tools
MKCERT_VERSION=1.4.4
curl -Lo ~/.local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/mkcert-v${MKCERT_VERSION}-linux-amd64"
chmod +x ~/.local/bin/mkcert

# ai
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
npm install -g @anthropic-ai/claude-code opensrc

# basic-memory mcp
uv tool install basic-memory
if ! claude mcp list 2>/dev/null | grep -q basic-memory; then
  claude mcp add --scope user basic-memory -- uvx basic-memory mcp
fi
