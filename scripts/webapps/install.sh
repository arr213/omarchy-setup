#!/bin/bash
# Webapp Shortcuts Installation Script

set -e

HYPR_CONFIG="$HOME/.config/hypr"
WEBAPP_BINDINGS="$HYPR_CONFIG/webapps.conf"

echo "🌐 Installing webapp shortcuts..."

# Ensure Hyprland config directory exists
if [ ! -d "$HYPR_CONFIG" ]; then
    echo "❌ Hyprland config directory not found: $HYPR_CONFIG"
    return 1 2>/dev/null || exit 1
fi

# Create webapp bindings configuration
cat > "$WEBAPP_BINDINGS" << 'EOF'
# Webapp Shortcuts
# These bindings launch webapps using Omarchy's webapp launcher

# Email
bindd = SUPER SHIFT, SEMICOLON, Fastmail, exec, omarchy-launch-webapp "https://app.fastmail.com"
bindd = SUPER SHIFT ALT, SEMICOLON, Protonmail, exec, omarchy-launch-webapp "https://mail.proton.me"

# AI Assistants
bindd = SUPER SHIFT, A, ChatGPT, exec, omarchy-launch-webapp "https://chatgpt.com"
bindd = SUPER SHIFT ALT, A, Claude, exec, omarchy-launch-webapp "https://claude.ai"

# Communication
bindd = SUPER SHIFT ALT, G, WhatsApp, exec, omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"

# Note: Signal and Spotify use desktop apps, not webapps
# They're launched via:
#   signal-desktop (SUPER + SHIFT + G)
#   spotify (SUPER + SHIFT + M)
EOF

# Add source line to hyprland.conf if not already present
if ! grep -q "source.*webapps.conf" "$HYPR_CONFIG/hyprland.conf" 2>/dev/null; then
    echo "" >> "$HYPR_CONFIG/hyprland.conf"
    echo "# Webapp shortcuts" >> "$HYPR_CONFIG/hyprland.conf"
    echo "source = ~/.config/hypr/webapps.conf" >> "$HYPR_CONFIG/hyprland.conf"
    echo "   Added webapp shortcuts to hyprland.conf"
fi

echo "✅ Webapp shortcuts installed"
echo ""
echo "Keybindings added:"
echo "  SUPER + SHIFT + ;           - Fastmail"
echo "  SUPER + SHIFT + ALT + ;     - Protonmail"
echo "  SUPER + SHIFT + A           - ChatGPT"
echo "  SUPER + SHIFT + ALT + A     - Claude"
echo "  SUPER + SHIFT + ALT + G     - WhatsApp"
echo ""
echo "Reload Hyprland config: hyprctl reload"
