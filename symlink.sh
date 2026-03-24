#!/bin/bash

set -e

DOTFILES="$( cd "$(dirname "$0")" && pwd )"

mkdir -p ~/.config/ghostty ~/.config/nvim

ln -sf "$DOTFILES/ghostty" ~/.config/ghostty/config
ln -sf "$DOTFILES/nvim" ~/.config/nvim
ln -sf "$DOTFILES/.zshsource" ~/.zshsource

if ! grep -qF 'source ~/.zshsource' ~/.zshrc 2>/dev/null; then
  echo 'source ~/.zshsource' >> ~/.zshrc
fi
