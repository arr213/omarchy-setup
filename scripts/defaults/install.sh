#!/bin/bash
# System Defaults Configuration Script

set -e

echo "⚙️  Configuring system defaults..."

# Set default browser to Brave
if command -v brave &> /dev/null; then
    echo "   Setting Brave as default browser..."

    # Set via xdg-settings
    xdg-settings set default-web-browser brave-browser.desktop

    # Set MIME types for HTTP/HTTPS
    xdg-mime default brave-browser.desktop x-scheme-handler/http
    xdg-mime default brave-browser.desktop x-scheme-handler/https
    xdg-mime default brave-browser.desktop text/html

    # Add BROWSER environment variable to uwsm config if it exists
    if [ -f "$HOME/.config/uwsm/default" ]; then
        echo "   Adding BROWSER variable to uwsm config..."

        # Check if BROWSER is already set
        if ! grep -q "^export BROWSER=" "$HOME/.config/uwsm/default"; then
            # Add after EDITOR line
            if grep -q "^export EDITOR=" "$HOME/.config/uwsm/default"; then
                sed -i '/^export EDITOR=/a\\\nexport BROWSER=brave' "$HOME/.config/uwsm/default"
            else
                # Just append at the end
                echo "" >> "$HOME/.config/uwsm/default"
                echo "export BROWSER=brave" >> "$HOME/.config/uwsm/default"
            fi
            echo "   ✓ Added BROWSER=brave to uwsm config"
        else
            echo "   ✓ BROWSER already set in uwsm config"
        fi
    fi

    echo "   ✓ Brave set as default browser"
else
    echo "   ⚠ Brave not found, skipping browser defaults"
fi

# TODO: Add more default configurations
# - XDG user directories
# - Shell defaults (bash/zsh/fish)
# - Other environment variables
# - System settings

echo "✅ Defaults configured"
