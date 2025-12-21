#!/bin/bash
# Package Installation Script

set -e

echo "📦 Installing packages..."

# TODO: Define your package list here
PACKAGES=(
    # Browser
    "brave-bin"

    # System utilities for Hyprland monitor management
    "socat"  # Required for monitor event listener
    "jq"     # Required for monitor overlap detection

    # Development tools
    # "git"
    # "neovim"
    # "tmux"

    # Additional system utilities
    # "htop"
    # "ripgrep"
    # "fd"

    # Add your packages here
)

if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo "   No packages defined yet. Edit scripts/packages/install.sh to add packages."
    return 0 2>/dev/null || exit 0
fi

# Detect package manager
if command -v pacman &> /dev/null; then
    echo "   Using pacman..."
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
elif command -v apt &> /dev/null; then
    echo "   Using apt..."
    sudo apt update && sudo apt install -y "${PACKAGES[@]}"
elif command -v dnf &> /dev/null; then
    echo "   Using dnf..."
    sudo dnf install -y "${PACKAGES[@]}"
else
    echo "❌ No supported package manager found"
    return 1 2>/dev/null || exit 1
fi

echo "✅ Packages installed"
