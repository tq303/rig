#!/bin/bash

set -e

sudo -v

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

# install homebrew if missing
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# add homebrew to PATH for Apple Silicon (if not already in PATH)
if [[ -x /opt/homebrew/bin/brew ]] && ! command -v brew &>/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update

# terminal
brew install --cask ghostty
brew install --cask rectangle

# editors
brew install --cask visual-studio-code
brew install --cask claude

bash "$(dirname "$0")/symlink.sh"

# tools
brew install neovim ripgrep fd fzf lsd bat lazygit starship gh uv tmux

# language
# nodejs
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
fi
if ! command -v yarn &>/dev/null; then
  curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.17
fi

brew install mkcert go

go install github.com/tq303/valet@latest

# ai
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
npm install -g @anthropic-ai/claude-code opensrc

# vscode extension (requires code CLI — available after brew cask install)
if command -v code &>/dev/null; then
  code --install-extension anthropic.claude-code
fi

# basic-memory mcp
uv tool install basic-memory
if ! claude mcp list 2>/dev/null | grep -q basic-memory; then
  claude mcp add --scope user basic-memory -- uvx basic-memory mcp
fi

# optional
# brew install imagemagick
brew install ffmpeg

bash "$(dirname "$0")/macos-settings.sh"
