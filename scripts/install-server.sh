#!/bin/bash

set -e

# tools (apt)
sudo apt update
sudo apt install -y git ripgrep fd-find fzf bat ffmpeg tmux zsh

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# docker
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"

bash "$(dirname "$0")/install-linux.sh"

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
go install github.com/tq303/valet@latest

bash "$(dirname "$0")/install-tooling.sh"

# valet — symlink configs
$HOME/go/bin/valet sync --platform server

# zsh — source .zshsource and set as default shell
if ! grep -q "zshsource" ~/.zshrc 2>/dev/null; then
  echo '[ -f ~/.zshsource ] && source ~/.zshsource' >> ~/.zshrc
fi
sudo chsh -s "$(which zsh)" "$USER"

# auto-login on boot (no monitor/keyboard required after reboot)
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF

# disable suspend/sleep (headless — monitor unplug drops SSH otherwise)
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 i915.enable_dc=0 mem_sleep_default=s2idle"/' /etc/default/grub
sudo update-grub
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo sh -c 'cat >> /etc/systemd/logind.conf << EOF
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF'
sudo systemctl restart systemd-logind

# persistent tmux session on boot
mkdir -p ~/.config/systemd/user
cp "$(dirname "$0")/../tmux/tmux-session.service" ~/.config/systemd/user/tmux-session.service
systemctl --user enable tmux-session
systemctl --user start tmux-session
loginctl enable-linger "$USER"

echo "Done — log out and back in for zsh to take effect"
