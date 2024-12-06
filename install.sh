#!/usr/bin/env bash

set -euo pipefail

# Constants
DOTFILES_DIR="$HOME/.dotfiles"
BIN_DIR="$HOME/.local/bin"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Install dependencies based on OS
install_dependencies() {
    local os=$1
    
    log_info "Installing dependencies for $os..."
    
    case "$os" in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            brew install neovim git curl ripgrep fd
            ;;
        ubuntu)
            sudo apt-get update
            sudo apt-get install -y neovim git curl ripgrep fd-find
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Install Node.js (required for LSP)
install_nodejs() {
    local os=$1
    
    if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js..."
        
        case "$os" in
            macos)
                brew install node
                ;;
            ubuntu)
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
                ;;
        esac
    fi
}

# Main installation
main() {
    local os
    os=$(detect_os)
    
    log_info "Starting installation for OS: $os"
    
    # Create bin directory
    mkdir -p "$BIN_DIR"
    
    # Install dependencies
    install_dependencies "$os"
    install_nodejs "$os"
    
    # Copy dot script to bin directory
    cp "$DOTFILES_DIR/bin/dot" "$BIN_DIR/dot"
    chmod +x "$BIN_DIR/dot"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "Adding $BIN_DIR to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    log_info "Installation complete!"
    log_info "Please run 'dot init' to initialize your dotfiles."
}

# Run main function
main