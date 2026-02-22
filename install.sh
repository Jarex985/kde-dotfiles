#!/bin/bash
# Installs plasmoids, plasma themes and cursor themes from the KDE Store via the OCS API,
# then imports and applies the konsave profile.
# Run this from the repo root:
#   bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Colors
BOLD='\e[1m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RESET='\e[0m'
DIV='────────────────────────────────────────────'

# ask <question> <description> <var>
# Prints a styled prompt and stores the answer in <var>
ask() {
    local question="$1"
    local description="$2"
    local var="$3"
    echo ""
    echo -e "${CYAN}${DIV}${RESET}"
    echo -e "  ${BOLD}${question}${RESET}"
    [ -n "$description" ] && echo -e "  ${description}"
    echo -e "${CYAN}${DIV}${RESET}"
    read -p "  [y/n]: " "$var"
    echo ""
}

# === Backup ===

ask "Back up existing configs before applying?" \
    "Saves all configs that will be overwritten to ~/kde-backup-YYYYMMDD.tar.gz" \
    backup_answer
if [[ "$backup_answer" == "y" ]]; then
    BACKUP_PATHS=()
    for p in \
        "$HOME/.config/gtk-3.0" \
        "$HOME/.config/gtk-4.0" \
        "$HOME/.config/gtkrc" \
        "$HOME/.config/gtkrc-2.0" \
        "$HOME/.config/kdeglobals" \
        "$HOME/.config/plasmashellrc" \
        "$HOME/.config/ksplashrc" \
        "$HOME/.config/kdedefaults" \
        "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
        "$HOME/.config/kwinrc" \
        "$HOME/.config/kwinrulesrc" \
        "$HOME/.config/breezerc" \
        "$HOME/.config/klassy" \
        "$HOME/.config/panel-colorizer" \
        "$HOME/.config/kde-material-you-colors" \
        "$HOME/.config/kcminputrc" \
        "$HOME/.config/kitty" \
        "$HOME/.config/fastfetch" \
        "$HOME/.local/share/color-schemes" \
        "$HOME/.local/share/custom"; do
        [ -e "$p" ] && BACKUP_PATHS+=("$p")
    done
    BACKUP_FILE="$HOME/kde-backup-$(date +%Y%m%d).tar.gz"
    tar -czf "$BACKUP_FILE" "${BACKUP_PATHS[@]}"
    echo "   Backup saved to $BACKUP_FILE"
    echo "   Restore with: tar -xzf $BACKUP_FILE -C /"
    echo ""
fi

# === Plasmoids ===

declare -A PLASMOIDS=(
    ["Kurve (Audio Visualizer)"]="2299506"
    ["Spacer with Divider"]="2345513"
    ["Apdatifier"]="2135796"
    ["KDE Modern Clock"]="2135653"
)

echo "Installing plasmoids from KDE Store..."
echo ""

for name in "${!PLASMOIDS[@]}"; do
    id="${PLASMOIDS[$name]}"
    echo "-> $name (store.kde.org/p/$id)"

    # Skip if already installed
    if kpackagetool6 --list -t Plasma/Applet 2>/dev/null | grep -q "$id\|$(echo "$name" | tr '[:upper:]' '[:lower:]')"; then
        echo "   Already installed, skipping."
        continue
    fi

    url=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadlink1'])")

    if [ -z "$url" ]; then
        echo "   ERROR: Could not fetch download URL for $name"
        continue
    fi

    filename=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadname1'])")

    outfile="$TMPDIR/$filename"
    curl -sL "$url" -o "$outfile"

    if kpackagetool6 --install "$outfile" -t Plasma/Applet 2>/dev/null; then
        echo "   Installed."
    else
        kpackagetool6 --upgrade "$outfile" -t Plasma/Applet 2>/dev/null && echo "   Updated." || echo "   Already up to date."
    fi
done

# === Plasma Themes ===

declare -A PLASMA_THEMES=(
    ["Vinyl Plasma Theme"]="2313936"
)

# Package IDs for installed-check (kpackagetool6 uses these names)
declare -A PLASMA_THEME_PKGNAMES=(
    ["Vinyl Plasma Theme"]="com.ekaaty.vinyl-plasma"
)

echo ""
echo "Installing plasma themes from KDE Store..."
echo ""

for name in "${!PLASMA_THEMES[@]}"; do
    id="${PLASMA_THEMES[$name]}"
    pkgname="${PLASMA_THEME_PKGNAMES[$name]}"
    echo "-> $name (store.kde.org/p/$id)"

    # Skip if already installed
    if kpackagetool6 --list -t Plasma/Theme 2>/dev/null | grep -q "$pkgname"; then
        echo "   Already installed, skipping."
        continue
    fi

    url=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadlink1'])")

    if [ -z "$url" ]; then
        echo "   ERROR: Could not fetch download URL for $name"
        continue
    fi

    filename=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadname1'])")

    outfile="$TMPDIR/$filename"
    curl -sL "$url" -o "$outfile"

    if kpackagetool6 --install "$outfile" -t Plasma/Theme 2>/dev/null; then
        echo "   Installed."
    else
        kpackagetool6 --upgrade "$outfile" -t Plasma/Theme 2>/dev/null && echo "   Updated." || echo "   Already up to date."
    fi
done

# === Cursor Themes ===

declare -A CURSOR_THEMES=(
    ["Volantes Cursors (Light)"]="volantes-light-cursors"
)

declare -A CURSOR_THEME_IDS=(
    ["Volantes Cursors (Light)"]="1356095"
)

echo ""
echo "Installing cursor themes from KDE Store..."
echo ""

mkdir -p ~/.local/share/icons

for name in "${!CURSOR_THEMES[@]}"; do
    dirname="${CURSOR_THEMES[$name]}"
    id="${CURSOR_THEME_IDS[$name]}"
    echo "-> $name (store.kde.org/p/$id)"

    # Skip if already installed
    if [ -d "$HOME/.local/share/icons/$dirname" ]; then
        echo "   Already installed, skipping."
        continue
    fi

    url=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadlink2'])")

    if [ -z "$url" ]; then
        echo "   ERROR: Could not fetch download URL for $name"
        continue
    fi

    filename=$(curl -sf "https://api.kde-look.org/ocs/v1/content/data/$id" \
        -H "Accept: application/json" | \
        python3 -c "import sys,json; print(json.load(sys.stdin)['data'][0]['downloadname2'])")

    outfile="$TMPDIR/$filename"
    curl -sL "$url" -o "$outfile"

    tar -xzf "$outfile" -C ~/.local/share/icons/
    echo "   Installed."
done

# === Konsave Profile ===

echo ""
echo "Importing konsave profile..."
konsave -i "$SCRIPT_DIR/assets/rhyvor-v4.knsv" -f

echo "Applying konsave profile..."
konsave -a rhyvor-v4

# === Modern Clock Localization Patch ===

ask "Apply localization patch for Modern Clock?" \
    "Uses system language instead of English." \
    clock_answer
if [[ "$clock_answer" == "y" ]]; then
    CLOCK_QML="$HOME/.local/share/plasma/plasmoids/com.github.prayag2.modernclock/contents/ui/main.qml"
    if [ -f "$CLOCK_QML" ]; then
        sed -i \
            's/display_day\.text = Qt\.formatDate(curDate, "dddd")\.toUpperCase()/display_day.text = curDate.toLocaleString(Qt.locale(), "dddd").toUpperCase()/' \
            "$CLOCK_QML"
        sed -i \
            's/display_date\.text = Qt\.formatDate(curDate, dateFormat)\.toUpperCase()/display_date.text = curDate.toLocaleString(Qt.locale(), dateFormat).toUpperCase()/' \
            "$CLOCK_QML"
        echo "   Patch applied."
    else
        echo "   ERROR: main.qml not found - was Modern Clock installed correctly?"
    fi
fi

# === KDE Material You Colors Autostart ===

ask "Enable KDE Material You Colors autostart?" \
    "Starts automatically on login." \
    matyou_answer
if [[ "$matyou_answer" == "y" ]]; then
    AUTOSTART="$HOME/.config/autostart/kde-material-you-colors.desktop"
    if [ ! -f "$AUTOSTART" ]; then
        mkdir -p ~/.config/autostart
        cat > "$AUTOSTART" << 'EOF'
[Desktop Entry]
Exec=/usr/bin/kde-material-you-colors
Icon=color-management
Name=KDE Material You Colors
Comment=Starts/Restarts background process
Type=Application
X-KDE-AutostartScript=true
EOF
        echo "   Autostart enabled."
    else
        echo "   Autostart already configured, skipping."
    fi
fi

# === zsh Configuration ===

ask "Configure zsh?" \
    "Adds fastfetch autostart, pywal integration, sets zsh as default shell." \
    answer
if [[ "$answer" == "y" ]]; then

    # Insert lines at the top of ~/.zshrc if not already present
    if ! grep -q "fastfetch --pipe false" ~/.zshrc 2>/dev/null; then
        tmp=$(mktemp)
        cat > "$tmp" << 'EOF'
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
#cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh

fastfetch --pipe false

EOF
        cat ~/.zshrc >> "$tmp" 2>/dev/null || true
        mv "$tmp" ~/.zshrc
        echo "   .zshrc updated."
        echo ""
        echo "   NOTE: If you run 'p10k configure', it inserts an instant-prompt block at"
        echo "   the top of ~/.zshrc which will break pywal/fastfetch. If that happens,"
        echo "   manually move the pywal/fastfetch lines ABOVE the p10k instant-prompt block."
    else
        echo "   .zshrc already configured, skipping."
    fi

    # Set zsh as default shell if not already set
    if [[ "$SHELL" != */zsh ]]; then
        chsh -s /usr/bin/zsh
        echo "   zsh set as default shell."
    else
        echo "   zsh is already the default shell."
    fi
fi


echo "Done! A reboot is required for all changes to take effect."
ask "Reboot now?" "" reboot_answer
if [[ "$reboot_answer" == "y" ]]; then
    systemctl reboot
fi
