# Touchpad Gestures Setup

## Quick Setup

Add this to your `~/.config/hypr/input.conf`:

```conf
# Enable touchpad gestures for changing workspaces
# See https://wiki.hyprland.org/Configuring/Gestures/
gesture = 3, horizontal, workspace
```

Then reload Hyprland config:
```bash
hyprctl reload
```

## Usage

- **3-finger swipe right** → Next workspace
- **3-finger swipe left** → Previous workspace

## Additional Gesture Options

```conf
# 4-finger swipes
gesture = 4, horizontal, workspace

# Vertical gestures for other actions
gesture = 3, vertical, exec, <command>
```

## Troubleshooting

**Gestures not working?**
1. Check if touchpad is detected: `hyprctl devices | grep -i touchpad`
2. Verify natural scroll is enabled in input.conf
3. Make sure you have at least 3 fingers on the trackpad

**See also:** [Hyprland Gestures Documentation](https://wiki.hyprland.org/Configuring/Gestures/)
