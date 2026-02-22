# konsave-backup

KDE Plasma 6.6 theme backup managed with [konsave](https://github.com/Prayag2/konsave).

## Prerequisites

Install the following before restoring:

Arch / CachyOS:

```bash
sudo pacman -S --needed papirus-icon-theme fastfetch kitty ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono zsh
```

AUR:

```bash
paru -S --needed konsave klassy plasma6-applets-panel-colorizer kde-material-you-colors kwin-effects-better-blur-dx
```

> **Note:** Panel Colorizer and KDE Material You Colors are installed via `paru` above. The remaining plasmoids (Apdatifier, Spacer with Divider, Kurve, Modern Clock), Vinyl Plasma Theme, and Volantes Cursors (Light) are installed automatically by `install.sh`.

### Optional

- **Krohnkite** - https://store.kde.org/p/2144146
- **Klear** - https://store.kde.org/p/2216605


## Setup on a new system

### Step 1 - Clone this repo

```bash
git clone https://github.com/Jarex985/konsave-backup
```

### Step 2 - Install plasmoids and apply the profile

```bash
bash konsave-backup/install.sh
```

This imports and applies the konsave profile, installs plasmoids, the Vinyl Plasma Theme, and Volantes Cursors (Light) from the KDE Store. You will also be asked whether to:
- Back up existing configs that will be overwritten
- Apply a localization patch for Modern Clock (system language instead of English)
- Enable KDE Material You Colors autostart
- Configure zsh (fastfetch autostart, pywal integration, set zsh as default shell)

> **p10k users:** If you run `p10k configure`, it inserts an instant-prompt block at the top of `~/.zshrc` which breaks pywal/fastfetch. If that happens, manually move the pywal/fastfetch lines **above** the p10k instant-prompt block.

### Step 3 - Reboot

## What's included

- `kdeglobals` - Fonts, colors, general KDE settings
- `kwinrc` / `kwinrulesrc` - Window manager rules & effects
- `plasmashellrc` - Panel & desktop settings
- `plasma-org.kde.plasma.desktop-appletsrc` - Widgets & panel layout
- `kdedefaults/` - Cursor theme, splash screen, look-and-feel package
- `klassy/` - klassyrc + windecopresetsrc
- `panel-colorizer/presets/` - Rhyvor Bottom v3, Rhyvor Top v3
- `kde-material-you-colors/` - Material You config
- `gtk-3.0/` / `gtk-4.0/` / `gtkrc` - GTK theming
- `kitty/` - Kitty terminal config
- `fastfetch/` - Fastfetch config
- `~/.local/share/color-schemes/` - Material You color schemes
- `~/.local/share/custom/` - fastfetch sprite, Rhyvor_v4.klpw

## Wallpapers

- CachyOS Wallpapers: https://postimg.cc/gallery/0kps0HF
- CachyOS Logos: https://drive.google.com/file/d/1Y9w9sKaVO0dpNz_TN0-p34ZgUVHnhD5l/view?usp=sharing
