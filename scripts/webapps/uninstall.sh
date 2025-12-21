#!/bin/bash
# Webapp Shortcuts Uninstallation Script

set -e

HYPR_CONFIG="$HOME/.config/hypr"
WEBAPP_BINDINGS="$HYPR_CONFIG/webapps.conf"

echo "🌐 Uninstalling webapp shortcuts..."

# Remove webapp bindings file
if [ -f "$WEBAPP_BINDINGS" ]; then
    rm "$WEBAPP_BINDINGS"
    echo "   Removed webapps.conf"
fi

# Remove source line from hyprland.conf
if [ -f "$HYPR_CONFIG/hyprland.conf" ]; then
    sed -i '/source.*webapps.conf/d' "$HYPR_CONFIG/hyprland.conf"
    sed -i '/# Webapp shortcuts/d' "$HYPR_CONFIG/hyprland.conf"
    echo "   Removed webapp shortcuts from hyprland.conf"
fi

echo "✅ Webapp shortcuts uninstalled"
