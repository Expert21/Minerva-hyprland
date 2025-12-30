# Minerva - Hyprland Rice

## 🌙 Obsidian Arcana + 👻 Ghost Mode

A **dual-mode** Hyprland configuration:
- **Obsidian Arcana** - Dark fantasy aesthetic with deep purples and mystical glows
- **Ghost Mode** - Minimalistic pentesting environment with VPN and security tools

## 🔄 Mode Switching

Toggle between modes with: **`SUPER + SHIFT + G`**

| Mode | Description | Visual |
|------|-------------|--------|
| **Obsidian Arcana** | Aesthetic dark fantasy | Purple accents, blur, rounded corners |
| **Ghost Mode** | Pentesting focus | Black/Cyan, no gaps, sharp edges |

## ✨ Features

### Obsidian Arcana
- Deep blacks, royal purples, mystic lavender accents
- Blur, transparency, smooth animations
- Beautiful dark fantasy wallpapers

### Ghost Mode
- Auto-connects **ProtonVPN**
- Activates **UFW kill-switch** (VPN drops = internet drops)
- Auto-launches **Burpsuite, Wireshark, Terminal**
- Minimalistic black UI with cyan/red/green accents

## 📦 Components

| Component | Package |
|-----------|---------|
| Window Manager | Hyprland |
| Bar | Waybar |
| Terminal | Kitty |
| Launcher | Rofi (wayland) |
| Notifications | Dunst |
| Lock Screen | Hyprlock |
| Idle Daemon | Hypridle |
| Wallpaper | Swww / Swaybg |

## 🚀 Quick Start

### 1. Install Packages
```bash
./install.sh
```

### 2. Deploy Configs
```bash
./deploy.sh
```

### 3. Add Wallpaper
```
~/.config/hypr/wallpapers/wallpaper.jpg
```

### 4. Launch Hyprland
Log out and select **Hyprland** from your display manager.

## ⌨️ Keybindings

### Core
| Key | Action |
|-----|--------|
| `Super + Enter` | Terminal (Kitty) |
| `Super + Tab` | App Launcher (Rofi) |
| `Super + Q` | Close Window |
| `Super + V` | Toggle Floating |
| `Super + F` | Fullscreen |
| `Super + L` | Lock Screen |
| `Super + Shift + G` | **Toggle Ghost Mode** |

### Ghost Mode Only
| Key | Action |
|-----|--------|
| `Super + B` | Launch Burpsuite |
| `Super + W` | Launch Wireshark |

### Navigation
| Key | Action |
|-----|--------|
| `Super + Arrow Keys` | Move Focus |
| `Super + Shift + Arrow Keys` | Move Window |
| `Super + Ctrl + Arrow Keys` | Resize Window |
| `Super + 1-9` | Switch Workspace |
| `Super + Shift + 1-9` | Move to Workspace |

### Utilities
| Key | Action |
|-----|--------|
| `Print` | Screenshot (Full) |
| `Super + Print` | Screenshot (Window) |
| `Super + Shift + Print` | Screenshot (Region) |
| `Super + Shift + V` | Clipboard History |

## 🎨 Color Palettes

### Obsidian Arcana
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0d0d0d` | Deep black base |
| Primary | `#7b2cbf` | Active borders |
| Accent | `#c77dff` | Text accents |
| Text | `#e0e0e0` | Primary text |

### Ghost Mode
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#000000` | Pure black |
| Cyan | `#00ffff` | Active, connected |
| Red | `#ff3333` | Errors, critical |
| Green | `#00ff00` | Success, VPN active |
| Gray | `#555555` | Muted elements |

## 📁 Structure

```
~/.config/hypr/
├── hyprland.conf          → symlink to active theme
├── themes/
│   ├── arcana/            # Aesthetic theme
│   │   ├── hyprland.conf
│   │   ├── waybar/
│   │   ├── kitty.conf
│   │   ├── rofi/
│   │   └── dunst/
│   └── ghost/             # Pentesting theme
│       ├── hyprland.conf
│       ├── waybar/
│       ├── kitty.conf
│       ├── rofi/
│       └── dunst/
├── scripts/
│   ├── switch-mode.sh     # Mode toggler
│   ├── vpn-status.sh      # Waybar VPN module
│   └── wallpaper.sh
└── .current-mode          # Current mode state
```

## 🔧 Ghost Mode Requirements

```bash
# ProtonVPN CLI
yay -S protonvpn-cli
protonvpn signin

# UFW (for kill-switch)
sudo pacman -S ufw
sudo systemctl enable --now ufw

# Pentesting tools
sudo pacman -S burpsuite wireshark-qt
```

---

*Crafted with ✨ for the Obsidian Arcana aesthetic and 👻 for serious pentesting*
