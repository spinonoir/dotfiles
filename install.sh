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

# Install or update dependencies based on OS
install_dependencies() {
    local os=$1
    
    log_info "Installing/updating dependencies for $os..."
    
    case "$os" in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            else
                log_info "Updating Homebrew..."
                brew update
            fi
            
            # Install/Update packages
            brew install neovim git curl ripgrep fd || brew upgrade neovim git curl ripgrep fd
            ;;
        ubuntu)
            sudo apt-get update
            sudo apt-get install -y neovim git curl
            
            # Install/Update ripgrep and fd-find if not latest
            if ! command -v rg >/dev/null 2>&1; then
                sudo apt-get install -y ripgrep
            fi
            if ! command -v fdfind >/dev/null 2>&1; then
                sudo apt-get install -y fd-find
            fi
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Install/Update Node.js (required for LSP)
install_nodejs() {
    local os=$1
    
    log_info "Checking Node.js installation..."
    
    case "$os" in
        macos)
            if ! command -v node >/dev/null 2>&1; then
                log_info "Installing Node.js..."
                brew install node
            else
                log_info "Updating Node.js..."
                brew upgrade node
            fi
            ;;
        ubuntu)
            if ! command -v node >/dev/null 2>&1; then
                log_info "Installing Node.js..."
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt-get install -y nodejs
            else
                log_info "Updating Node.js..."
                sudo apt-get update
                sudo apt-get install -y nodejs
            fi
            ;;
    esac
}

# Install/Update LSP servers
install_lsp_servers() {
    log_info "Installing/updating LSP servers..."
    
    # Ensure npm is available
    if ! command -v npm >/dev/null 2>&1; then
        log_error "npm not found. Please ensure Node.js is installed correctly."
        return 1
    fi
    
    # Update npm itself to latest version
    npm install -g npm@latest
    
    # Install/Update TypeScript LSP
    npm install -g typescript typescript-language-server
    
    # Install Python LSP
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user --upgrade pyright
    else
        log_warn "pip3 not found. Installing Python LSP server skipped."
    fi
    
    # Note about other LSP servers
    log_info "Other LSP servers (Lua, etc.) will be installed automatically by Mason when you open Neovim."
}

# Setup dot command
setup_dot_command() {
    log_info "Setting up dot command..."
    
    # Create bin directory if it doesn't exist
    mkdir -p "$BIN_DIR"
    
    # Copy dot script to bin directory
    cp "$DOTFILES_DIR/bin/dot" "$BIN_DIR/dot"
    chmod +x "$BIN_DIR/dot"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "Adding $BIN_DIR to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

# Main installation
main() {
    local os
    os=$(detect_os)
    
    log_info "Starting installation/update for OS: $os"
    
    # Install/Update system dependencies
    install_dependencies "$os"
    install_nodejs "$os"
    
    # Install/Update LSP servers
    install_lsp_servers
    
    # Setup dot command
    setup_dot_command
    
    # Initialize or update dotfiles
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_info "First time setup - please run 'dot init' to initialize your dotfiles."
    else
        log_info "Running sync to update configuration..."
        "$BIN_DIR/dot" sync
    fi
    
    log_info "Installation/update complete!"
}

# Run main function
main