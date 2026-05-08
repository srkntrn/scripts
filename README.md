# scripts

Small CLI helpers I keep around.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/srkntrn/scripts/main/install.sh | bash
```

This drops every script into `~/.local/bin`. To install elsewhere:

```sh
curl -fsSL https://raw.githubusercontent.com/srkntrn/scripts/main/install.sh | INSTALL_DIR=/usr/local/bin bash
```

If `~/.local/bin` isn't on your `PATH`, the installer will tell you how to add it.

## Tools

### `tm` — tmux session picker / creator

```
tm                attach to an existing session, or create one (interactive)
tm <name>         attach to <name>, creating it if missing
tm -l, --list     list sessions
tm -k <name>      kill session <name>
tm -K, --kill-all kill the tmux server
tm -h, --help     show help
```

The interactive picker uses [`fzf`](https://github.com/junegunn/fzf) when available, otherwise falls back to a numbered menu. When run from inside tmux, `tm` uses `switch-client` instead of nesting an attach.

### `myip` — print public IP

```sh
myip
```

Hits `ifconfig.me` with a 5s timeout and prints the result. Exits non-zero on failure, so it's safe to use in scripts.

## Uninstall

```sh
rm ~/.local/bin/{tm,myip}
```
