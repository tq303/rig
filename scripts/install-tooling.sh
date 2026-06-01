#!/bin/bash

set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
npm install -g @anthropic-ai/claude-code oxfmt

# basic-memory mcp
uv tool install basic-memory
if ! claude mcp list 2>/dev/null | grep -q basic-memory; then
  claude mcp add --scope user basic-memory -- uvx basic-memory mcp
fi

# config/setup
git config --global user.name "tq303"
git config --global user.email "tq303@loc.org"
