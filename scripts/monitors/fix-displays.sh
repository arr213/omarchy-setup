#!/bin/bash
# Comprehensive display fix script
# Handles GPU freezes, monitor layout issues, scaling problems, and general display glitches

INSTALL_DIR="$HOME/.local/share/hyprland-scripts"

echo "🔧 Fixing display issues..."

# 1. Force compositor refresh (helps with GPU freezes)
echo "   Refreshing compositor..."
hyprctl dispatch dpms off
sleep 0.5
hyprctl dispatch dpms on

# 2. Reload Hyprland config (fixes config-related issues)
echo "   Reloading Hyprland configuration..."
hyprctl reload

# 3. Reset all monitors to auto (clears any bad state)
echo "   Resetting monitors..."
hyprctl keyword monitor ,preferred,auto,1

# 4. Clear workspace-to-monitor bindings (allows workspaces to follow focus)
echo "   Clearing workspace bindings..."
for ws in {1..10}; do
    hyprctl keyword workspace "$ws,default:true" 2>/dev/null
done

# 5. Reapply proper monitor layout
echo "   Reapplying monitor layout..."
if [ -f "$INSTALL_DIR/auto-monitor-layout.sh" ]; then
    "$INSTALL_DIR/auto-monitor-layout.sh"
else
    echo "   ⚠️  Monitor layout script not found at $INSTALL_DIR/auto-monitor-layout.sh"
fi

# 6. Restart waybar if it exists (fixes bar display issues)
if pgrep -x waybar > /dev/null; then
    echo "   Restarting waybar..."
    pkill waybar
    sleep 0.3
    waybar &>/dev/null &
    disown
fi

# 7. Force workspace refresh (sometimes workspaces get stuck)
echo "   Refreshing workspaces..."
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
# Switch away and back to force refresh
hyprctl dispatch workspace $(( (current_workspace % 10) + 1 ))
sleep 0.1
hyprctl dispatch workspace "$current_workspace"

echo "✅ Display fix complete!"
