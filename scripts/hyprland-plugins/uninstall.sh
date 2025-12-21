#!/bin/bash
# Hyprland Plugins Uninstallation Script

set -e

echo "🔌 Uninstalling Hyprland plugins..."

# Check if hyprpm is available
if ! command -v hyprpm &> /dev/null; then
    echo "❌ hyprpm not found."
    return 1 2>/dev/null || exit 1
fi

# Plugin names to disable/remove
PLUGINS=(
    "hyprbars"
    "hyperexpo"
    "hyperfocus"
    "hyprscroller"
)

for plugin in "${PLUGINS[@]}"; do
    echo "   Disabling $plugin..."
    hyprpm disable "$plugin" 2>/dev/null || echo "   ⚠️  Could not disable $plugin (may not be installed)"
done

# Remove all plugin repositories
echo "   Removing plugin repositories..."
for plugin in "${PLUGINS[@]}"; do
    hyprpm remove "$plugin" 2>/dev/null || true
done

echo "✅ Hyprland plugins uninstalled"
echo "🔄 Restart Hyprland to complete removal"
