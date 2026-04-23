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

bash "$(dirname "$0")/symlink.sh"

# tools
brew install neovim ripgrep fd fzf lsd bat lazygit starship

# language
# nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.17

brew install mkcert

# optional
# brew install imagemagick
# brew install ffmpeg

bash "$(dirname "$0")/macos-settings.sh"
