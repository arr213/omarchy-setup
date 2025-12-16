#!/bin/bash
# Monitor Management Uninstallation Script

set -e

HYPR_CONFIG="$HOME/.config/hypr"
INSTALL_DIR="$HOME/.local/share/hyprland-scripts"

echo "🖥️  Uninstalling monitor management..."

# Remove scripts
rm -f "$INSTALL_DIR/auto-monitor-layout.sh"
rm -f "$INSTALL_DIR/monitor-event-listener.sh"

# Remove from autostart
if [ -f "$HYPR_CONFIG/autostart.conf" ]; then
    sed -i '/monitor-event-listener.sh/d' "$HYPR_CONFIG/autostart.conf"
    sed -i '/Auto-configure monitor layout/d' "$HYPR_CONFIG/autostart.conf"
fi

# Kill running event listener
pkill -f monitor-event-listener.sh || true

echo "✅ Monitor management uninstalled"
