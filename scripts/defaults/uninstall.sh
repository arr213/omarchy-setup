#!/bin/bash
# System Defaults Uninstallation Script

set -e

echo "⚙️  Removing system defaults..."

# Remove BROWSER environment variable from uwsm config
if [ -f "$HOME/.config/uwsm/default" ]; then
    echo "   Removing BROWSER variable from uwsm config..."
    sed -i '/^export BROWSER=brave$/d' "$HOME/.config/uwsm/default"
    # Also remove the blank line before it if it exists
    sed -i '/^export EDITOR=/{n;/^$/d;}' "$HOME/.config/uwsm/default"
    echo "   ✓ Removed BROWSER from uwsm config"
fi

echo "   Note: XDG default browser settings will remain."
echo "   Run 'xdg-settings set default-web-browser <browser>.desktop' to change."

echo "✅ Defaults removed"
