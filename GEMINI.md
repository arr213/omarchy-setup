# Omarchy Workstation Setup

This repository contains modular installation scripts for setting up an Omarchy/Hyprland development environment on Arch Linux. It automates the configuration of monitors, packages, web applications, themes, and system defaults.

## Project Overview

*   **Type:** Infrastructure / Dotfiles / Setup Scripts
*   **Platform:** Arch Linux (Hyprland)
*   **Language:** Bash
*   **Key Dependencies:** `hyprctl`, `socat`, `jq`

## Architecture

The project uses a modular architecture where the main `install.sh` script orchestrates the execution of individual component scripts located in the `scripts/` directory.

### Directory Structure

```text
workstation_setup/
├── install.sh                  # Main entry point (orchestrator)
├── install-stow.sh             # Helper to install GNU Stow
├── scripts/                    # Component modules
│   ├── 1password/
│   ├── defaults/
│   ├── hyprland-plugins/
│   ├── monitors/               # Complex monitor management logic
│   ├── packages/
│   ├── themes/
│   └── webapps/
└── CLAUDE.md                   # Detailed context and architectural decisions
```

### Component Structure

Each directory in `scripts/` represents a component and typically contains:
*   `install.sh`: The setup logic for that specific component.
*   `uninstall.sh`: (Optional) Logic to revert changes.
*   Configuration files or auxiliary scripts (e.g., `auto-monitor-layout.sh` in `monitors/`).

## Usage

### Main Installer

Run the main installer to set up the entire environment:

```bash
./install.sh
```

### Partial Installation

Install specific components:

```bash
./install.sh --only monitors
```

Skip specific components:

```bash
./install.sh --skip packages --skip themes
```

### Uninstallation

Remove all installed components:

```bash
./install.sh --uninstall
```

## Key Components

*   **Monitors (`scripts/monitors/`)**:
    *   Dynamically manages monitor layouts using `hyprctl`.
    *   Uses `auto-monitor-layout.sh` to position monitors based on preference and connection order.
    *   Includes an event listener (`monitor-event-listener.sh`) that reacts to Hyprland socket events (monitor added/removed).
    *   Features a "fix" script (`fix-displays.sh`) for troubleshooting.

*   **Packages (`scripts/packages/`)**: Installs system utilities and applications (e.g., Docker, Brave, Signal).
*   **Webapps (`scripts/webapps/`)**: Configures keyboard shortcuts and wrappers for web applications.
*   **Hyprland Plugins (`scripts/hyprland-plugins/`)**: Manages Hyprland plugins.

## Development Guidelines

### Adding a New Component

1.  **Create Directory:** Create a new folder in `scripts/` (e.g., `scripts/my-tool/`).
2.  **Create Scripts:** Add an `install.sh` (required) and `uninstall.sh` (optional) inside that directory. Ensure they are executable (`chmod +x`).
3.  **Register:** Add the component name to the `COMPONENTS` array in the main `install.sh` file.

### Conventions

*   **Idempotency:** Scripts should be safe to run multiple times.
*   **Paths:** Use relative paths or dynamic paths (via `$(dirname ...)`).
*   **Output:** Use the color variables defined in `install.sh` (e.g., `${BLUE}`, `${GREEN}`) for consistent logging.
