#!/bin/bash
# Auto-configure Hyprland monitor layout based on connected displays
# This script detects connected monitors and positions them left-to-right automatically

# Monitor preferences (resolution@refresh, scale)
declare -A MONITOR_PREFS=(
    ["eDP-1"]="1920x1200@60,1.25"
    ["HDMI-A-1"]="3840x2160@60,2"
    ["DP-8"]="1920x1080@60,1.25"
    ["DP-9"]="1920x1080@60,1.25"
)

# Priority order (leftmost to rightmost)
MONITOR_ORDER=("eDP-1" "DP-8" "DP-9" "HDMI-A-1")

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
        echo "Configuring $monitor at position ${position}x0 with scale $scale"
        hyprctl keyword monitor "$monitor,$resolution,${position}x0,$scale"

        # Calculate next position (resolution width / scale)
        width=$(echo "$resolution" | cut -d'x' -f1 | cut -d'@' -f1)
        # Use awk for floating point division
        effective_width=$(awk "BEGIN {printf \"%.0f\", $width / $scale}")
        position=$((position + effective_width))
    fi
done

echo "Monitor layout updated successfully"
