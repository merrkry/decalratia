#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <extensions-list-file> [--dry-run]"
    exit 1
fi

EXT_FILE=$1
DRY_RUN=false

if [ "${2:-}" == "--dry-run" ]; then
    DRY_RUN=true
    echo "Executing in dry run mode."
fi

if [ ! -f "$EXT_FILE" ]; then
    echo "Error: File $EXT_FILE not found."
    exit 1
fi

# Discard annoying warnings about Chromium flags on Waland.
function vsc() {
    code "$@" 2>/dev/null
}

# Use `__HEADER__` and `|| true` to handle empty result

INSTALLED_EXTS=${ echo "__HEADER__"; vsc --list-extensions | tr '[:upper:]' '[:lower:]' | sort || true; }

DECLARED_EXTS=${ echo "__HEADER__"; grep -vE '^\s*(#|$)' "$EXT_FILE" | tr '[:upper:]' '[:lower:]' | sort || true; }

TO_INSTALL=$(comm -23 <(echo "$DECLARED_EXTS") <(echo "$INSTALLED_EXTS"))

TO_UNINSTALL=$(comm -13 <(echo "$DECLARED_EXTS") <(echo "$INSTALLED_EXTS"))

if [ -n "$TO_INSTALL" ]; then
    echo "Installing missing extensions:"
    for ext in $TO_INSTALL; do
        if [ "$DRY_RUN" = true ]; then
            echo "Would install: $ext"
        else
            echo "Installing: $ext"
            vsc --install-extension "$ext"
        fi
    done
fi


# 处理卸载逻辑
if [ -n "$TO_UNINSTALL" ]; then
    echo "Uninstalling redundant extensions:"
    for ext in $TO_UNINSTALL; do
        if [ "$DRY_RUN" = true ]; then
            echo "Would uninstall: $ext"
        else
            echo "Uninstalling: $ext"
            vsc --uninstall-extension "$ext"
        fi
    done
fi


echo "Done."
