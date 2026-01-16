#!/bin/bash
# Monitor Management Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_CONFIG="$HOME/.config/hypr"
INSTALL_DIR="$HOME/.local/share/hyprland-scripts"

echo "🖥️  Installing monitor management..."

# Ensure Hyprland config directory exists
if [ ! -d "$HYPR_CONFIG" ]; then
    echo "❌ Hyprland config directory not found: $HYPR_CONFIG"
    echo "   Skipping monitor setup."
    return 1 2>/dev/null || exit 1
fi

# Create scripts directory
mkdir -p "$INSTALL_DIR"

# Copy monitor management scripts
echo "   Copying scripts to $INSTALL_DIR..."
cp "$SCRIPT_DIR/auto-monitor-layout.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/monitor-event-listener.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/fix-displays.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/auto-monitor-layout.sh"
chmod +x "$INSTALL_DIR/monitor-event-listener.sh"
chmod +x "$INSTALL_DIR/fix-displays.sh"

# Backup and update monitors.conf
if [ -f "$HYPR_CONFIG/monitors.conf" ]; then
    if ! grep -q "handled dynamically by monitor management scripts" "$HYPR_CONFIG/monitors.conf"; then
        cp "$HYPR_CONFIG/monitors.conf" "$HYPR_CONFIG/monitors.conf.backup.$(date +%Y%m%d-%H%M%S)"
        echo "   Backed up existing monitors.conf"
    fi
fi

cat > "$HYPR_CONFIG/monitors.conf" << 'EOF'
# See https://wiki.hyprland.org/Configuring/Monitors/
env = GDK_SCALE,1

# Monitor configuration is now handled dynamically by monitor management scripts
# This fallback catches any monitors not configured by the script
monitor = ,preferred,auto,1

# To customize: edit ~/.local/share/hyprland-scripts/auto-monitor-layout.sh
EOF

# Update autostart.conf
AUTOSTART_LINE="exec-once = $INSTALL_DIR/monitor-event-listener.sh"
if ! grep -q "monitor-event-listener.sh" "$HYPR_CONFIG/autostart.conf" 2>/dev/null; then
    echo "" >> "$HYPR_CONFIG/autostart.conf"
    echo "# Auto-configure monitor layout on connect/disconnect" >> "$HYPR_CONFIG/autostart.conf"
    echo "$AUTOSTART_LINE" >> "$HYPR_CONFIG/autostart.conf"
    echo "   Added to autostart"
fi

# Add display fix keybinding
KEYBIND_FILE="$HYPR_CONFIG/bindings.conf"
KEYBIND_LINE="bindd = SUPER, F5, Fix displays, exec, $INSTALL_DIR/fix-displays.sh"
if [ -f "$KEYBIND_FILE" ]; then
    if ! grep -q "fix-displays.sh" "$KEYBIND_FILE" 2>/dev/null; then
        echo "" >> "$KEYBIND_FILE"
        echo "# Display fix (handles GPU freezes, monitor layout, scaling issues)" >> "$KEYBIND_FILE"
        echo "$KEYBIND_LINE" >> "$KEYBIND_FILE"
        echo "   Added keybinding: SUPER+F5"
    fi
else
    echo "   ⚠️  Keybindings file not found at $KEYBIND_FILE"
    echo "   Add this line to your Hyprland config manually:"
    echo "   $KEYBIND_LINE"
fi

# Run initial layout
"$INSTALL_DIR/auto-monitor-layout.sh"

echo "✅ Monitor management installed"
