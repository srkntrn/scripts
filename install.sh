#!/usr/bin/env bash
# Installer for srkntrn/scripts.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/srkntrn/scripts/main/install.sh | bash
#
# Override install directory:
#   curl -fsSL .../install.sh | INSTALL_DIR=/usr/local/bin bash

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/srkntrn/scripts/main"
SCRIPTS=(tm myip)
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

mkdir -p "$INSTALL_DIR"

for name in "${SCRIPTS[@]}"; do
    dest="$INSTALL_DIR/$name"
    echo "→ installing $name to $dest"
    curl -fsSL "$REPO_RAW/$name" -o "$dest"
    chmod +x "$dest"
done

echo
echo "Installed: ${SCRIPTS[*]}"
echo "Location:  $INSTALL_DIR"

case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        echo "PATH:      ✓ $INSTALL_DIR is on your PATH"
        ;;
    *)
        echo
        echo "⚠  $INSTALL_DIR is NOT on your PATH."
        echo "   Add it by appending this to your shell rc (~/.bashrc, ~/.zshrc):"
        echo "     export PATH=\"$INSTALL_DIR:\$PATH\""
        ;;
esac
