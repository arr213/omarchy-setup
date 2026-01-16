#!/bin/bash
# Auto-configure Hyprland monitor layout - EXTERNAL MONITORS MIRRORED
# This script mirrors external monitors while keeping laptop screen separate

# Monitor preferences (resolution@refresh, scale)
declare -A MONITOR_PREFS=(
    ["eDP-1"]="1920x1200@60,1.67"
    ["DP-1"]="3840x2160@60,3"
    ["DP-2"]="3840x2160@60,3"
    ["HDMI-A-1"]="3840x2160@60,3"
    ["DP-8"]="1920x1080@60,1.67"
    ["DP-9"]="1920x1080@60,1.67"
)

# Mirroring configuration: monitors that should mirror each other
# Format: "MIRROR_SOURCE:MIRROR_TARGET" (TARGET will mirror SOURCE)
MIRROR_PAIRS=(
    "HDMI-A-1:DP-2"     # DP-2 will mirror HDMI-A-1
    "HDMI-A-1:DP-1"     # DP-1 will mirror HDMI-A-1 (if connected)
)

# Priority order (top to bottom)
MONITOR_ORDER=("DP-1" "DP-2" "HDMI-A-1" "eDP-1" "DP-8" "DP-9")

# Get list of connected monitors
mapfile -t CONNECTED < <(hyprctl monitors -j | jq -r '.[].name')

echo "Connected monitors: ${CONNECTED[*]}"
echo "Layout mode: EXTERNAL MONITORS MIRRORED"

# Build list of monitors that should be mirrored (targets)
declare -A MIRROR_TARGETS
for pair in "${MIRROR_PAIRS[@]}"; do
    IFS=':' read -r source target <<< "$pair"
    # Only set mirror if both monitors are connected
    if [[ " ${CONNECTED[*]} " =~ " ${source} " ]] && [[ " ${CONNECTED[*]} " =~ " ${target} " ]]; then
        MIRROR_TARGETS[$target]=$source
        echo "Mirror configuration: $target will mirror $source"
    fi
done

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

        # Check if this monitor should mirror another
        if [[ -n "${MIRROR_TARGETS[$monitor]}" ]]; then
            mirror_source="${MIRROR_TARGETS[$monitor]}"
            echo "Configuring $monitor to mirror $mirror_source"
            hyprctl keyword monitor "$monitor,$resolution,auto,$scale,mirror,$mirror_source"
        else
            # Apply normal monitor configuration
            echo "Configuring $monitor at position 0x${position} with scale $scale"
            hyprctl keyword monitor "$monitor,$resolution,0x${position},$scale"

            # Calculate next position (resolution height / scale)
            height=$(echo "$resolution" | cut -d'x' -f2 | cut -d'@' -f1)
            # Use awk for floating point division
            effective_height=$(awk "BEGIN {printf \"%.0f\", $height / $scale}")
            position=$((position + effective_height))
        fi
    fi
done

echo "Monitor layout updated successfully"
