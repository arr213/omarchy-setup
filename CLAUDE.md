# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Workstation setup scripts and configurations for Hyprland on Arch Linux, focusing on automated monitor management and dynamic display configuration.

## Architecture

### Monitor Management System

**Auto Layout Script** (`scripts/auto-monitor-layout.sh`):
- Detects connected monitors via `hyprctl monitors -j`
- Positions monitors left-to-right based on `MONITOR_ORDER` preference array
- Calculates positions using effective width (physical resolution ÷ scale factor)
- Applies configuration using `hyprctl keyword monitor` commands

**Event Listener** (`scripts/monitor-event-listener.sh`):
- Listens to Hyprland socket events via `socat`
- Triggers layout script on `monitoradded` and `monitorremoved` events
- Runs on startup via `~/.config/hypr/autostart.conf`

**Display Fix Script** (`scripts/fix-displays.sh`):
- Comprehensive troubleshooting tool for display issues
- Handles GPU freezes by toggling DPMS
- Fixes monitor layout and scaling problems
- Restarts display-related services (waybar)
- Bound to `SUPER+F5` keyboard shortcut

**Key Design Decisions**:
- Uses dynamic detection rather than static config to handle multiple monitor setups
- Positions calculated in effective pixels (accounting for HiDPI scaling)
- Priority-based ordering allows consistent layout regardless of connection order

## Project Structure

```
workstation_setup/
├── install.sh                          # Main orchestrator script
└── scripts/
    ├── monitors/                       # Monitor management component
    ├── packages/                       # Package installation
    ├── themes/                         # Theme configuration
    ├── 1password/                      # 1Password CLI setup
    └── defaults/                       # System defaults
```

Each component has:
- `install.sh`: Installation script
- `uninstall.sh`: Removal script (optional)

## Common Commands

**Full installation**:
```bash
./install.sh
```

**Install specific component**:
```bash
./install.sh --only monitors
./install.sh --only packages
```

**Skip components**:
```bash
./install.sh --skip packages --skip themes
```

**Uninstall everything**:
```bash
./install.sh --uninstall
```

**Monitor management** (after installation):
```bash
# Keyboard shortcut (recommended)
SUPER+F5                                                 # Fix all display issues

# Manual commands
~/.local/share/hyprland-scripts/fix-displays.sh          # Fix display issues
~/.local/share/hyprland-scripts/auto-monitor-layout.sh  # Apply layout only
hyprctl monitors                                         # Check monitors
```

## Adding New Components

1. Create `scripts/new-component/install.sh`
2. Optionally create `scripts/new-component/uninstall.sh`
3. Add "new-component" to `COMPONENTS` array in main `install.sh`
4. The main installer will automatically discover and run it
