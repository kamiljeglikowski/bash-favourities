#!/usr/bin/env bash
# Installer for the fav favourite-commands tool.
# Creates ~/.favourites/, copies the engine in, and tells you the exact line to
# add to your shell startup file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAV_DIR="$HOME/.favourites"

mkdir -p "$FAV_DIR"
cp "$SCRIPT_DIR/fav" "$FAV_DIR/fav"
echo "Installed fav engine to $FAV_DIR/fav"

# Pick the startup file for the user's login shell.
case "${SHELL:-}" in
    *zsh) rc="$HOME/.zshrc" ;;
    *)    rc="$HOME/.bash_profile" ;;
esac
rc_display="${rc/#"$HOME"/\~}"

line='[ -f ~/.favourites/fav ] && source ~/.favourites/fav'

cat <<EOF

To finish setup, add this line to ${rc_display}:

    ${line}

Then reload your shell:

    source ${rc_display}

After that, type 'fav' to start, or 'fav create' to add another list.
EOF
