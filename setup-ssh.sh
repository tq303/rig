#!/bin/bash

set -e

read -p "Username (e.g. tq303): " username
read -p "Email: " email

ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/$username"

echo ""
echo "Add this public key to GitHub (Settings > SSH and GPG keys)"
echo "Add it twice: once as Authentication key, once as Signing key"
echo ""
cat "$HOME/.ssh/$username.pub"
