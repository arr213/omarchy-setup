# Additional Setup Notes

This file contains manual setup steps that can't be fully automated.

## AI Tools

### Claude Code
Claude Code requires manual installation:
```bash
curl -fsSL https://claude.com/install.sh | bash
```

After installation, authenticate:
```bash
claude auth
```

### Claude Desktop
Install via AUR (requires yay or paru):
```bash
yay -S claude-desktop
# or
paru -S claude-desktop
```

## Email Setup

### Fastmail
- Open: `SUPER + SHIFT + ;`
- Login at https://app.fastmail.com
- Consider enabling 2FA in account settings

### Protonmail
- Open: `SUPER + SHIFT + ALT + ;`
- Login at https://mail.proton.me
- Configure ProtonMail Bridge for desktop email clients (optional)

## Communication Apps

### Signal Desktop
- Launch: `SUPER + SHIFT + G` (via Omarchy bindings)
- Link to your phone on first launch
- Enable disappearing messages for privacy

### WhatsApp Web
- Open: `SUPER + SHIFT + ALT + G`
- Scan QR code with your phone
- Enable desktop notifications in browser settings

### Spotify
- Launch: `SUPER + SHIFT + M` (via Omarchy bindings)
- Login with your Spotify account
- Configure streaming quality in settings

## Docker Setup

After installation, add your user to the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Enable and start Docker:
```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Test installation:
```bash
docker run hello-world
```

## Webapp Customization

All webapp shortcuts are in `~/.config/hypr/webapps.conf`. You can:
- Add new webapp shortcuts
- Change keybindings
- Remove apps you don't use

After editing, reload Hyprland:
```bash
hyprctl reload
```
