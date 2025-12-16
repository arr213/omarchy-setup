#!/bin/bash
# Omarchy Workstation Setup - Main Installer
# Orchestrates installation of all components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Component installation order
COMPONENTS=(
    "packages"
    "monitors"
    "themes"
    "1password"
    "defaults"
)

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Omarchy Workstation Setup Installer  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Parse arguments
UNINSTALL=false
SKIP_COMPONENTS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --skip)
            SKIP_COMPONENTS+=("$2")
            shift 2
            ;;
        --only)
            ONLY_COMPONENT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --uninstall         Uninstall all components"
            echo "  --skip COMPONENT    Skip specific component"
            echo "  --only COMPONENT    Install only specific component"
            echo "  --help              Show this help message"
            echo ""
            echo "Components: ${COMPONENTS[*]}"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to check if component should be skipped
should_skip() {
    local component=$1

    # Check if we're doing --only and this isn't it
    if [ -n "$ONLY_COMPONENT" ] && [ "$component" != "$ONLY_COMPONENT" ]; then
        return 0
    fi

    # Check skip list
    for skip in "${SKIP_COMPONENTS[@]}"; do
        if [ "$component" = "$skip" ]; then
            return 0
        fi
    done

    return 1
}

# Function to run component script
run_component() {
    local component=$1
    local action=${2:-install}
    local script="$SCRIPT_DIR/scripts/$component/$action.sh"

    if should_skip "$component"; then
        echo -e "${YELLOW}⏭️  Skipping $component${NC}"
        return 0
    fi

    echo ""
    echo -e "${BLUE}▶ Running $component $action...${NC}"

    if [ -f "$script" ]; then
        chmod +x "$script"
        if bash "$script"; then
            echo -e "${GREEN}✓ $component $action successful${NC}"
            return 0
        else
            echo -e "${RED}✗ $component $action failed${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Script not found: $script${NC}"
        return 0
    fi
}

# Main installation loop
FAILED_COMPONENTS=()
ACTION="install"
[ "$UNINSTALL" = true ] && ACTION="uninstall"

for component in "${COMPONENTS[@]}"; do
    if ! run_component "$component" "$ACTION"; then
        FAILED_COMPONENTS+=("$component")
    fi
done

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Installation Summary          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ ${#FAILED_COMPONENTS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All components ${ACTION}ed successfully!${NC}"
    echo ""
    if [ "$ACTION" = "install" ]; then
        echo "🚀 Next steps:"
        echo "   - Review component configurations in scripts/"
        echo "   - Restart Hyprland to apply all changes"
        echo "   - Run './install.sh --uninstall' to remove everything"
    fi
else
    echo -e "${RED}❌ Some components failed:${NC}"
    for component in "${FAILED_COMPONENTS[@]}"; do
        echo -e "${RED}   - $component${NC}"
    done
    echo ""
    echo "Check the output above for details."
    exit 1
fi

echo ""
