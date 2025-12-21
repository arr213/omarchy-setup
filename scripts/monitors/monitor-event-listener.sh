#!/bin/bash
# Hyprland monitor event listener
# Automatically runs monitor layout script when displays connect/disconnect

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LAYOUT_SCRIPT="$SCRIPT_DIR/auto-monitor-layout.sh"

echo "Starting monitor event listener..."

# Function to check for overlapping monitors
check_monitor_overlap() {
    # Get monitor positions and dimensions
    local monitors_data=$(hyprctl monitors -j)

    # Check if any monitors overlap by comparing positions
    local overlap=$(echo "$monitors_data" | jq -r '
        . as $all |
        [.[] | select(.disabled == false)] |
        length as $count |
        if $count < 2 then false
        else
            [
                combinations(2) |
                select(
                    .[0].name != .[1].name and
                    (
                        (.[0].x < (.[1].x + .[1].width) and (.[0].x + .[0].width) > .[1].x and
                         .[0].y < (.[1].y + .[1].height) and (.[0].y + .[0].height) > .[1].y)
                    )
                )
            ] | length > 0
        end
    ')

    if [[ "$overlap" == "true" ]]; then
        echo "⚠️  Monitor overlap detected! Auto-fixing..."
        "$LAYOUT_SCRIPT"
    fi
}

# Run initial layout setup
"$LAYOUT_SCRIPT"

# Start periodic overlap checker in background (every 5 seconds)
(
    while true; do
        sleep 5
        check_monitor_overlap
    done
) &
OVERLAP_CHECKER_PID=$!

# Listen for monitor events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)

    # Trigger on monitor connect/disconnect events
    if [[ "$event" == "monitoradded" ]] || [[ "$event" == "monitorremoved" ]]; then
        monitor=$(echo "$line" | cut -d'>' -f2)
        echo "Monitor event: $event - $monitor"

        # Small delay to let the system settle
        sleep 0.5

        # Reconfigure layout immediately
        "$LAYOUT_SCRIPT"

        # Schedule retries to handle race conditions
        # Run in background to not block the event listener
        (sleep 10 && echo "Monitor retry check (10s)..." && "$LAYOUT_SCRIPT") &
        (sleep 30 && echo "Monitor retry check (30s)..." && "$LAYOUT_SCRIPT") &
        (sleep 60 && echo "Monitor retry check (60s)..." && "$LAYOUT_SCRIPT") &
    fi

    # Also check for overlaps on config reload
    if [[ "$event" == "configreloaded" ]]; then
        echo "Config reloaded, checking for overlaps..."
        sleep 1
        check_monitor_overlap
    fi
done

# Cleanup on exit
kill $OVERLAP_CHECKER_PID 2>/dev/null
