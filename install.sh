#!/usr/bin/env bash
# Install opencode-skills into $HOME/.config/opencode/skills/ or a project-local skills dir.
#
# Usage:
#   ./install.sh              # install to $HOME/.config/opencode/skills/
#   ./install.sh .opencode      # install to ./.opencode/skills/ for a project
#   ./install.sh --copy       # copy instead of symlink

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="symlink"
TARGET_BASE="$HOME/.config/opencode"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --copy) MODE="copy"; shift ;;
        --help|-h)
            sed -n '1,12p' "$0" | sed 's|^# ||; s|^#$||'
            exit 0
            ;;
        *) TARGET_BASE="$(cd "$1" && pwd)"; shift ;;
    esac
done

SKILLS_DIR="$TARGET_BASE/skills"
mkdir -p "$SKILLS_DIR"

install_entry() {
    local src="$1"
    local dest="$2"
    if [[ "$MODE" == "symlink" ]]; then
        ln -sfn "$src" "$dest"
    else
        rm -rf "$dest"
        cp -r "$src" "$dest"
    fi
    echo "  $MODE: $dest"
}

echo "Installing opencode-skills to: $SKILLS_DIR"

for group in planning-chain meta efficiency-kit; do
    [[ -d "$REPO_ROOT/$group" ]] || continue
    for d in "$REPO_ROOT/$group"/*/; do
        [[ -d "$d" ]] || continue
        install_entry "${d%/}" "$SKILLS_DIR/$(basename "$d")"
    done
done

if [[ -d "$REPO_ROOT/tools" ]]; then
    mkdir -p "$SKILLS_DIR/_shared"
    for f in "$REPO_ROOT"/tools/*.py; do
        [[ -f "$f" ]] || continue
        if [[ "$MODE" == "symlink" ]]; then
            ln -sf "$f" "$SKILLS_DIR/_shared/$(basename "$f")"
        else
            cp "$f" "$SKILLS_DIR/_shared/$(basename "$f")"
        fi
        echo "  $MODE: $SKILLS_DIR/_shared/$(basename "$f")"
    done
fi

install_entry "$REPO_ROOT/_template" "$SKILLS_DIR/_template"

echo ""
echo "Done. Skills installed at: $SKILLS_DIR"
echo "See $REPO_ROOT/CONSIDERATIONS.md for prerequisites and runtime-state details."
