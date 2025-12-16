#!/bin/bash
# 1Password CLI Setup Script

set -e

echo "🔐 Setting up 1Password CLI..."

# Check if op is already installed
if command -v op &> /dev/null; then
    echo "   1Password CLI already installed: $(op --version)"
else
    echo "   Installing 1Password CLI..."

    # Install based on platform
    if command -v pacman &> /dev/null; then
        # Arch/Manjaro
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm 1password-cli
        elif command -v paru &> /dev/null; then
            paru -S --needed --noconfirm 1password-cli
        else
            echo "   Please install 1password-cli manually from AUR"
            return 1 2>/dev/null || exit 1
        fi
    else
        echo "   Please install 1password-cli manually"
        return 1 2>/dev/null || exit 1
    fi
fi

# TODO: Add 1Password configuration steps
# - Sign in: op account add --address <your-domain>.1password.com
# - Configure shell plugins
# - Set up SSH agent

echo "✅ 1Password CLI setup complete"
echo "   Next: Run 'op account add' to sign in"
