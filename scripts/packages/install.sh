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

    # Communication & Productivity
    "signal-desktop"
    "spotify"

    # Development tools
    "docker"
    "docker-compose"
    # "git"
    # "neovim"
    # "tmux"

    # AI Tools (AUR packages - requires yay or paru)
    # "claude-desktop"
    # claude-code installed via: curl -fsSL https://claude.com/install.sh | bash

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
