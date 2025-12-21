#!/bin/bash
# Hyprland Plugins Installation Script

set -e

echo "🔌 Installing Hyprland plugins..."

# Check if hyprpm is available
if ! command -v hyprpm &> /dev/null; then
    echo "❌ hyprpm not found. Please ensure Hyprland is installed."
    return 1 2>/dev/null || exit 1
fi

# Plugin repositories
PLUGINS=(
    "https://github.com/hyprwm/hyprland-plugins|hyprbars"
    "https://github.com/hyprwm/hyprland-plugins|hyperexpo"
    "https://github.com/VortexCoyote/hyperfocus"
    "https://github.com/dawsers/hyprscroller"
)

echo "   Updating hyprpm..."
hyprpm update

for plugin_entry in "${PLUGINS[@]}"; do
    # Parse repo and optional plugin name
    IFS='|' read -r repo plugin_name <<< "$plugin_entry"

    echo "   Installing from $repo..."

    # Add repository
    if hyprpm add "$repo" --verbose; then
        # Enable specific plugin if specified, otherwise enable all from repo
        if [ -n "$plugin_name" ]; then
            echo "   Enabling $plugin_name..."
            hyprpm enable "$plugin_name" || echo "   ⚠️  Could not enable $plugin_name (may already be enabled)"
        else
            # Extract repo name for enabling
            repo_name=$(basename "$repo" .git)
            echo "   Enabling $repo_name..."
            hyprpm enable "$repo_name" || echo "   ⚠️  Could not enable $repo_name (may already be enabled)"
        fi
    else
        echo "   ⚠️  Failed to add $repo (may already exist)"
    fi
done

echo ""
echo "✅ Hyprland plugins installed"
echo ""
echo "📝 Installed plugins:"
echo "   • hyprbars    - Window title bars for Hyprland"
echo "   • hyperexpo   - Workspace overview/expo"
echo "   • hyperfocus  - Dim/blur unfocused windows"
echo "   • hyprscroller - Better workspace scrolling"
echo ""
echo "💡 To configure plugins, edit your ~/.config/hypr/hyprland.conf"
echo "   Example plugin configurations can be found in each plugin's repository."
echo ""
echo "🔄 Restart Hyprland to load the plugins"
