#!/bin/bash
# Auto-configure Hyprland monitor layout based on connected displays
# Features:
# - Dynamic scale calculation based on resolution
# - Left-to-right monitor positioning
# - Workspaces follow focused monitor (not bound to specific monitors)

# Physical position order (left to right)
MONITOR_ORDER=("DP-1" "DP-2" "HDMI-A-1" "eDP-1" "DP-8" "DP-9")


# Mirroring configuration: monitors that should mirror each other
# Format: "MIRROR_SOURCE:MIRROR_TARGET" (TARGET will mirror SOURCE)
MIRROR_PAIRS=(
    "HDMI-A-1:DP-2"     # DP-2 will mirror HDMI-A-1
)

# Calculate optimal scale based on resolution and physical size
calculate_scale() {
    local width=$1
    local height=$2
    local diagonal_pixels=$(awk "BEGIN {printf \"%.0f\", sqrt($width*$width + $height*$height)}")

    # Scale based on diagonal resolution
    # 4K displays (3840x2160): ~4400 diagonal -> scale 2.5-3
    # 1440p displays (2560x1440): ~2900 diagonal -> scale 1.5
    # 1080p displays (1920x1080): ~2200 diagonal -> scale 1.0-1.25
    # Low-res displays: scale 1.0

    if [ $diagonal_pixels -ge 4000 ]; then
        # 4K or higher
        echo "2.5"
    elif [ $diagonal_pixels -ge 3500 ]; then
        # ~3K
        echo "2.0"
    elif [ $diagonal_pixels -ge 2800 ]; then
        # 1440p
        echo "1.5"
    elif [ $diagonal_pixels -ge 2000 ]; then
        # 1080p
        if [ $width -le 1920 ]; then
            echo "1.25"
        else
            echo "1.5"
        fi
    else
        # Lower resolution
        echo "1.0"
    fi
}

# Get list of connected monitors with their resolutions
mapfile -t MONITOR_INFO < <(hyprctl monitors -j | jq -r '.[] | "\(.name):\(.width)x\(.height)@\(.refreshRate)"')

echo "Detected monitors: ${#MONITOR_INFO[@]}"
for info in "${MONITOR_INFO[@]}"; do
    echo "  $info"
done

# Build arrays of connected monitors
declare -a CONNECTED
declare -A RESOLUTIONS
for info in "${MONITOR_INFO[@]}"; do
    IFS=':' read -r name res <<< "$info"
    CONNECTED+=("$name")
    RESOLUTIONS[$name]="$res"
done

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
        # Get resolution
        res="${RESOLUTIONS[$monitor]}"
        IFS='x@' read -r width height refresh <<< "$res"

        # Calculate optimal scale
        scale=$(calculate_scale "$width" "$height")

        # Round refresh rate
        refresh=$(awk "BEGIN {printf \"%.0f\", $refresh}")

        # Check if this monitor should mirror another
        if [[ -n "${MIRROR_TARGETS[$monitor]}" ]]; then
            mirror_source="${MIRROR_TARGETS[$monitor]}"
            echo "Configuring $monitor to mirror $mirror_source (${width}x${height}@${refresh}Hz, scale $scale)"
            hyprctl keyword monitor "$monitor,${width}x${height}@${refresh},auto,$scale,mirror,$mirror_source"
        else
            # Apply normal monitor configuration
            echo "Configuring $monitor at position ${position}x0 (${width}x${height}@${refresh}Hz, scale $scale)"
            hyprctl keyword monitor "$monitor,${width}x${height}@${refresh},${position}x0,$scale"

            # Calculate next position (resolution width / scale)
            effective_width=$(awk "BEGIN {printf \"%.0f\", $width / $scale}")
            position=$((position + effective_width))
        fi
    fi
done

echo ""
echo "✅ Monitor layout updated successfully"
echo "   (Workspaces follow focused monitor)"
