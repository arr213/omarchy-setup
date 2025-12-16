#!/bin/bash
# Hyprland monitor event listener
# Automatically runs monitor layout script when displays connect/disconnect

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LAYOUT_SCRIPT="$SCRIPT_DIR/auto-monitor-layout.sh"

echo "Starting monitor event listener..."

# Run initial layout setup
"$LAYOUT_SCRIPT"

# Listen for monitor events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    # Trigger on monitor connect/disconnect events
    if [[ "$event" == "monitoradded" ]] || [[ "$event" == "monitorremoved" ]]; then
        monitor=$(echo "$line" | cut -d'>' -f2)
        echo "Monitor event: $event - $monitor"

        # Small delay to let the system settle
        sleep 0.5

        # Reconfigure layout
        "$LAYOUT_SCRIPT"
    fi
done
