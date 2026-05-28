#!/bin/bash

set -e

# tools (apt)
sudo apt update
sudo apt install -y git ripgrep fd-find fzf bat ffmpeg tmux zsh

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

bash "$(dirname "$0")/install-linux.sh"

go install github.com/tq303/valet@latest

bash "$(dirname "$0")/install-tooling.sh"

# valet — symlink configs
~/go/bin/val sync --platform server

# zsh — source .zshsource and set as default shell
if ! grep -q "zshsource" ~/.zshrc 2>/dev/null; then
  echo '[ -f ~/.zshsource ] && source ~/.zshsource' >> ~/.zshrc
fi
chsh -s "$(which zsh)"

# persistent tmux session on boot
mkdir -p ~/.config/systemd/user
cp "$(dirname "$0")/../tmux/tmux-session.service" ~/.config/systemd/user/tmux-session.service
systemctl --user enable tmux-session
systemctl --user start tmux-session
loginctl enable-linger "$USER"

echo "Done — log out and back in for zsh to take effect"
