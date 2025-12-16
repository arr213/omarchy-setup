#!/bin/bash
# Package Uninstallation Script

set -e

echo "📦 Uninstalling packages..."

# TODO: Define packages to remove
PACKAGES=(
    # Add packages to uninstall here
)

if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo "   No packages defined. Edit scripts/packages/uninstall.sh to add packages."
    return 0 2>/dev/null || exit 0
fi

# Detect package manager
if command -v pacman &> /dev/null; then
    sudo pacman -Rs --noconfirm "${PACKAGES[@]}" || true
elif command -v apt &> /dev/null; then
    sudo apt remove -y "${PACKAGES[@]}" || true
elif command -v dnf &> /dev/null; then
    sudo dnf remove -y "${PACKAGES[@]}" || true
fi

echo "✅ Packages uninstalled"
