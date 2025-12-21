#!/bin/bash
# Auto-configure Hyprland monitor layout based on connected displays
# This script detects connected monitors and positions them top-to-bottom automatically

# Monitor preferences (resolution@refresh, scale)
declare -A MONITOR_PREFS=(
    ["eDP-1"]="1920x1200@60,1.67"
    ["DP-1"]="3840x2160@60,3"
    ["DP-2"]="3840x2160@60,3"
    ["HDMI-A-1"]="3840x2160@60,3"
    ["DP-8"]="1920x1080@60,1.67"
    ["DP-9"]="1920x1080@60,1.67"
)

# Priority order (top to bottom)
MONITOR_ORDER=("DP-1" "DP-2" "HDMI-A-1" "eDP-1" "DP-8" "DP-9")

# Get list of connected monitors
mapfile -t CONNECTED < <(hyprctl monitors -j | jq -r '.[].name')

echo "Connected monitors: ${CONNECTED[*]}"

# Calculate positions and apply configuration
position=0
for monitor in "${MONITOR_ORDER[@]}"; do
    # Check if this monitor is connected
    if [[ " ${CONNECTED[*]} " =~ " ${monitor} " ]]; then
        # Get preferences
        prefs="${MONITOR_PREFS[$monitor]}"
        if [[ -z "$prefs" ]]; then
            prefs="preferred,auto,1"
        fi

        IFS=',' read -r resolution scale <<< "$prefs"

        # Apply monitor configuration
        echo "Configuring $monitor at position 0x${position} with scale $scale"
        hyprctl keyword monitor "$monitor,$resolution,0x${position},$scale"

        # Calculate next position (resolution height / scale)
        height=$(echo "$resolution" | cut -d'x' -f2 | cut -d'@' -f1)
        # Use awk for floating point division
        effective_height=$(awk "BEGIN {printf \"%.0f\", $height / $scale}")
        position=$((position + effective_height))
    fi
done

echo "Monitor layout updated successfully"
