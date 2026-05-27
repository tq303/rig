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
