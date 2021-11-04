#!/bin/bash

# terminal
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# tools
brew install neovim
brew install glow
brew install ripgrep
brew install fd
brew install fzf
brew install lsd
brew install bat
brew install lazygit
brew install starship

# language
# nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.17

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rls rust-analysis rust-src

brew install mkcert

# optional
# brew install imagemagick
# brew install ffmpeg

# hide dock auto appear
defaults write com.apple.dock autohide-delay -float 0
killall Dock
# defaults delete com.apple.dock autohide-delay; killall Dock (undo)

# create dock spacers
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}' && killall Dock
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}' && killall Dock
