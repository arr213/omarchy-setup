#!/bin/bash
# Auto-configure Hyprland monitor layout - ALL MONITORS MIRRORED
# This script mirrors all displays to show the same content

# Monitor preferences (resolution@refresh, scale)
declare -A MONITOR_PREFS=(
    ["eDP-1"]="1920x1200@60,1.67"
    ["DP-1"]="3840x2160@60,3"
    ["DP-2"]="3840x2160@60,3"
    ["HDMI-A-1"]="3840x2160@60,3"
    ["DP-8"]="1920x1080@60,1.67"
    ["DP-9"]="1920x1080@60,1.67"
)

# Priority order (first connected monitor becomes the primary/source)
MONITOR_ORDER=("HDMI-A-1" "DP-1" "DP-2" "eDP-1" "DP-8" "DP-9")

# Get list of connected monitors
mapfile -t CONNECTED < <(hyprctl monitors -j | jq -r '.[].name')

echo "Connected monitors: ${CONNECTED[*]}"
echo "Layout mode: ALL MONITORS MIRRORED"

# Find the primary monitor (first in priority order that is connected)
PRIMARY_MONITOR=""
for monitor in "${MONITOR_ORDER[@]}"; do
    if [[ " ${CONNECTED[*]} " =~ " ${monitor} " ]]; then
        PRIMARY_MONITOR="$monitor"
        break
    fi
done

if [[ -z "$PRIMARY_MONITOR" ]]; then
    echo "Error: No monitors detected!"
    exit 1
fi

echo "Primary monitor (source): $PRIMARY_MONITOR"

# Configure monitors
for monitor in "${CONNECTED[@]}"; do
    # Get preferences
    prefs="${MONITOR_PREFS[$monitor]}"
    if [[ -z "$prefs" ]]; then
        prefs="preferred,auto,1"
    fi

    IFS=',' read -r resolution scale <<< "$prefs"

    if [[ "$monitor" == "$PRIMARY_MONITOR" ]]; then
        # Configure primary monitor at position 0x0
        echo "Configuring $monitor (primary) at position 0x0 with scale $scale"
        hyprctl keyword monitor "$monitor,$resolution,0x0,$scale"
    else
        # Configure all other monitors to mirror the primary
        echo "Configuring $monitor to mirror $PRIMARY_MONITOR"
        hyprctl keyword monitor "$monitor,$resolution,auto,$scale,mirror,$PRIMARY_MONITOR"
    fi
done

echo "Monitor layout updated successfully - all displays mirroring $PRIMARY_MONITOR"
