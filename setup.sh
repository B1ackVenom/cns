cat << 'EOF' > setup.sh
#!/usr/bin/env bash

# Exit on undefined variables, pipefail, and catch errors cleanly
set -uo pipefail

# --- Styling ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

GITHUB_USER="krolyxon"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_DATA_DIR="$HOME/.local/share/nvim"
NVIM_STATE_DIR="$HOME/.local/state/nvim"
NVIM_CACHE_DIR="$HOME/.cache/nvim"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# --- 1. Pre-flight Checks ---
if [[ $EUID -eq 0 ]]; then
   warn "You are running this as root. Neovim configs are user-specific (~/.config/nvim)."
   read -p "Are you sure you want to configure Neovim for the ROOT user? (y/N): " -n 1 -r
   echo
   [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

info "Checking internet & GitHub connectivity..."
if ! curl -s --head --request GET https://github.com | grep -E "200|301|302" > /dev/null; then
    error "Cannot reach GitHub. Check your network/VPN connection and try again."
fi
success "GitHub is reachable."

# --- 2. Install System Dependencies ---
info "Updating apt and installing required Neovim dependencies..."
sudo apt-get update -qq || warn "apt-get update encountered minor issues, continuing..."

# Core tools needed by Telescope, Treesitter, Mason, and LSPs
DEPS=(
    git
    curl
    wget
    unzip
    ripgrep
    fd-find
    build-essential
    gcc
    g++
    make
    cmake
    nodejs
    npm
    python3
    python3-pip
    python3-venv
    xclip
)

sudo apt-get install -y "${DEPS[@]}" || error "Failed to install base dependencies."
success "Base system dependencies installed."

# --- 3. Install / Verify Modern Neovim (v0.10+) ---
install_latest_nvim() {
    info "Installing latest stable Neovim AppImage/tarball to /usr/local..."
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        EXTRACTED_DIR="nvim-linux-x86_64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        EXTRACTED_DIR="nvim-linux-arm64"
    else
        error "Unsupported architecture: $ARCH"
    fi

    TMP_DIR=$(mktemp -d)
    curl -fLo "$TMP_DIR/nvim.tar.gz" "$NVIM_URL" || error "Failed to download Neovim release."
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf "$TMP_DIR/nvim.tar.gz"
    sudo mv "/opt/$EXTRACTED_DIR" /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm -rf "$TMP_DIR"
    success "Latest Neovim installed at /usr/local/bin/nvim."
}

if ! command -v nvim &> /dev/null; then
    warn "Neovim is not installed."
    install_latest_nvim
else
    NVIM_VER=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
    MINOR_VER=$(echo "$NVIM_VER" | cut -d. -f2)
    MAJOR_VER=$(echo "$NVIM_VER" | cut -d. -f1)
    if [[ "$MAJOR_VER" -eq 0 && "$MINOR_VER" -lt 10 ]]; then
        warn "Installed Neovim ($NVIM_VER) is older than 0.10. Upgrading to avoid plugin errors..."
        install_latest_nvim
    else
        success "Neovim v$NVIM_VER detected."
    fi
fi

# --- 4. Backup Existing Configurations ---
backup_dir() {
    local target=$1
    if [[ -e "$target" || -L "$target" ]]; then
        mv "$target" "${target}.bak_${TIMESTAMP}"
        warn "Backed up existing $target -> ${target}.bak_${TIMESTAMP}"
    fi
}

info "Backing up any existing Neovim directories..."
mkdir -p "$HOME/.config"
backup_dir "$NVIM_CONFIG_DIR"
backup_dir "$NVIM_DATA_DIR"
backup_dir "$NVIM_STATE_DIR"
backup_dir "$NVIM_CACHE_DIR"

# --- 5. Smart Clone from github.com/krolyxon ---
info "Locating Neovim repository for $GITHUB_USER..."
TMP_CLONE=$(mktemp -d)
CLONED=false

# Try common repository naming conventions
for REPO in "nvim" "nvim-config" "neovim" "dotfiles"; do
    REPO_URL="https://github.com/${GITHUB_USER}/${REPO}.git"
    if git ls-remote "$REPO_URL" &> /dev/null; then
        info "Found repository: $REPO_URL"
        git clone --depth 1 "$REPO_URL" "$TMP_CLONE/$REPO" || error "Git clone failed."

        if [[ "$REPO" == "dotfiles" ]]; then
            # Search inside dotfiles for the nvim folder
            FOUND_NVIM=$(find "$TMP_CLONE/$REPO" -maxdepth 3 -type d -name "nvim" | head -n 1)
            if [[ -n "$FOUND_NVIM" ]]; then
                cp -r "$FOUND_NVIM" "$NVIM_CONFIG_DIR"
                CLONED=true
            else
                error "Found dotfiles repo, but could not locate an 'nvim' directory inside it."
            fi
        else
            cp -r "$TMP_CLONE/$REPO" "$NVIM_CONFIG_DIR"
            CLONED=true
        fi
        break
    fi
done

rm -rf "$TMP_CLONE"

if [[ "$CLONED" = false ]]; then
    error "Could not find a public repo named nvim, nvim-config, neovim, or dotfiles under github.com/$GITHUB_USER."
fi
success "Cloned configuration into $NVIM_CONFIG_DIR."

# --- 6. Install JetBrainsMono Nerd Font (Prevents Broken Icons) ---
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    TMP_FONT=$(mktemp -d)
    if curl -fLo "$TMP_FONT/JetBrainsMono.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
        unzip -q "$TMP_FONT/JetBrainsMono.zip" -d "$FONT_DIR/JetBrainsMono"
        fc-cache -fv > /dev/null
        success "JetBrainsMono Nerd Font installed. (Select it in your Kali Terminal Preferences)"
    else
        warn "Could not download Nerd Font automatically. Icons may appear as boxes."
    fi
    rm -rf "$TMP_FONT"
else
    success "JetBrainsMono Nerd Font is already installed."
fi

# --- 7. Headless Plugin Bootstrap ---
info "Bootstrapping Neovim plugins headless (this may take 30-60 seconds)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || nvim --headless "+PackerSync" +qa 2>/dev/null || true

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN} Neovim setup complete!${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "1. Set your terminal font to ${YELLOW}JetBrainsMono Nerd Font${NC}."
echo -e "2. Run ${BLUE}nvim${NC} to finish any remaining Treesitter/Mason installs."
echo -e "3. If anything acts up, run ${BLUE}:checkhealth${NC} inside Neovim."
EOF
chmod +x setup.sh && ./setup.sh
