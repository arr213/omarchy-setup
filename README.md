# Omarchy Workstation Setup

Modular installation scripts for setting up a complete Omarchy/Hyprland development environment.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/arr213/omarchy-setup.git ~/code/workstation_setup
cd ~/code/workstation_setup

# Install everything
./install.sh

# Or install specific components only
./install.sh --only monitors
./install.sh --skip packages

# Uninstall everything
./install.sh --uninstall
```

## Components

### 📦 Packages (`scripts/packages/`)
Install/uninstall development tools and system utilities.

Edit `scripts/packages/install.sh` to define your package list.

### 🖥️ Monitors (`scripts/monitors/`)
Dynamic monitor management for Hyprland - automatically positions monitors without gaps based on which displays are connected.

**Features:**
- Auto-detects connected monitors
- Calculates proper positioning accounting for DPI scaling
- Listens for monitor connect/disconnect events
- **Auto-detects and fixes overlapping monitors** (checks every 5 seconds)
- **Retry logic** (10s, 30s, 60s) to handle race conditions after monitor changes
- Configures on startup and after config reloads

**Dependencies:** `socat`, `jq` (auto-installed via packages component)

**Customize:** Edit `~/.local/share/hyprland-scripts/auto-monitor-layout.sh` after installation:
- `MONITOR_PREFS`: Set resolution, refresh rate, and scale for each monitor
- `MONITOR_ORDER`: Define top-to-bottom monitor positioning order

**Touchpad Gestures:** See `scripts/monitors/GESTURES.md` for 3-finger swipe setup

**Manual commands:**
```bash
# Apply layout manually
~/.local/share/hyprland-scripts/auto-monitor-layout.sh

# Check current monitors
hyprctl monitors
```

### 🎨 Themes (`scripts/themes/`)
GTK themes, icon packs, cursor themes, and color schemes.

TODO: Add your theme preferences to `scripts/themes/install.sh`

### 🔐 1Password (`scripts/1password/`)
1Password CLI installation and configuration.

TODO: Complete setup in `scripts/1password/install.sh`

### ⚙️ Defaults (`scripts/defaults/`)
System defaults - default applications, shell configuration, environment variables.

TODO: Add your preferences to `scripts/defaults/install.sh`

## Usage

### Install All Components
```bash
./install.sh
```

### Install Specific Component
```bash
./install.sh --only monitors
```

### Skip Components
```bash
./install.sh --skip packages --skip themes
```

### Uninstall
```bash
./install.sh --uninstall
```

### Get Help
```bash
./install.sh --help
```

## Directory Structure

```
workstation_setup/
├── install.sh                          # Main orchestrator
├── scripts/
│   ├── monitors/
│   │   ├── install.sh                  # Monitor setup installer
│   │   ├── uninstall.sh                # Monitor setup remover
│   │   ├── auto-monitor-layout.sh      # Dynamic layout script
│   │   └── monitor-event-listener.sh   # Event handler
│   ├── packages/
│   │   ├── install.sh                  # Package installer
│   │   └── uninstall.sh                # Package remover
│   ├── themes/
│   │   └── install.sh                  # Theme setup
│   ├── 1password/
│   │   └── install.sh                  # 1Password CLI setup
│   └── defaults/
│       └── install.sh                  # System defaults
├── CLAUDE.md                           # AI assistant context
└── README.md                           # This file
```

## Adding New Components

1. Create a new directory in `scripts/`
2. Add `install.sh` (and optionally `uninstall.sh`)
3. Add the component name to `COMPONENTS` array in `install.sh`
4. Make scripts executable: `chmod +x scripts/your-component/*.sh`

## Requirements

- Arch Linux (or compatible distro)
- Hyprland with Omarchy configuration
- Basic command-line tools: bash, awk, sed

## License

MIT
