# rig

No place like home.

## getting started

```sh
git clone https://github.com/tq303/rig.git ~/code/rig
cd ~/code/rig
bash scripts/setup-ssh.sh        # generate SSH key, add to GitHub
nvm install --lts                # install a Node version
```

```sh
bash scripts/install-macos.sh             # macOS
bash scripts/install-ubuntu.sh            # Ubuntu desktop
bash scripts/install-server.sh <hostname> # headless server (e.g. nuc)
```

After server install:
- `tailscale up`
- Log out and back in for zsh to take effect
- Machine will be reachable at `<hostname>.local` on the network

## tmux

Prefix: `ctrl+a`

| Key                  | Action                 |
| -------------------- | ---------------------- |
| `prefix + enter`     | split down             |
| `prefix + space`     | split right            |
| `prefix + h/j/k/l`   | navigate panes         |
| `prefix + p`         | display pane numbers   |
| `prefix + backspace` | resize pane left       |
| `prefix + \`         | resize pane right      |
| `prefix + a/s`       | previous/next window   |
| `prefix + [/]`       | move window left/right |
| `prefix + ,`         | rename window          |
| `prefix + z`         | zoom/unzoom pane       |

Zoomed panes are indicated by `[]` in the status bar.
