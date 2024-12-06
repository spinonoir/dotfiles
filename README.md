# Dotfiles

A streamlined dotfiles management system, currently focused on Neovim configuration management with room for future expansion.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles

# Install the dot command
~/.dotfiles/install.sh

# Initialize your dotfiles
dot init
```

## Features

- 🚀 Single command interface for dotfiles management
- 📦 Comprehensive Neovim configuration with LSP support
- 🔄 Easy synchronization across machines
- 🛠 Extensible framework for future tools

## Prerequisites

### Required
- Git
- Neovim (>= 0.9.0)
- Node.js (for LSP servers)
- Python3 + pip
- GCC/Clang (for Treesitter)
- ripgrep (for telescope search)

### Optional but Recommended
- fd-find (for better file finding)
- A Nerd Font (for icons)

## Installation

1. **Clone the repository:**
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
```

2. **Run the installation script:**
```bash
~/.dotfiles/install.sh
```

3. **Initialize dotfiles:**
```bash
dot init
```

4. **Install Neovim configuration:**
```bash
dot install nvim
```

## Usage

### Core Commands

```bash
# Install Neovim configuration
dot install nvim

# Edit Neovim configuration
dot config edit nvim

# Show current configuration
dot config show nvim

# Update configuration
dot update nvim

# Sync across machines
dot sync
```

### Synchronization

To sync changes across machines:

1. **Push changes from source machine:**
```bash
cd ~/.dotfiles
git add .
git commit -m "Update configuration"
git push
```

2. **Sync on target machine:**
```bash
dot sync
```

## Neovim Configuration Features

- 🌟 Modern LSP support
- 🔍 Fuzzy finding with Telescope
- 📝 Intelligent code completion
- 🎨 Syntax highlighting via Treesitter
- 🔧 Built-in terminal support
- 📁 File explorer with neo-tree
- 🎯 Git integration with gitsigns
- 📊 Status line with lualine

### Key Bindings

#### General
- `<Space>` - Leader key
- `<Leader>w` - Save file
- `<Leader>q` - Close window
- `<Leader>Q` - Quit all

#### Navigation
- `<Leader>ff` - Find files
- `<Leader>fg` - Live grep
- `<Leader>fb` - Browse buffers
- `<Leader>e` - Toggle file explorer

#### LSP
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover
- `<Leader>rn` - Rename
- `<Leader>ca` - Code action
- `<Leader>f` - Format file

#### Windows
- `<C-h/j/k/l>` - Navigate windows
- `<Leader>v` - Vertical split
- `<Leader>h` - Horizontal split

## Customization

### Local Configurations

Machine-specific configurations can be added in:
```
~/.config/nvim/local.lua
```

This file is automatically loaded if it exists but is not tracked in git.

## Troubleshooting

Run the doctor command to check for common issues:
```bash
dot doctor
```

This will:
- Verify all required dependencies
- Check Neovim health
- Validate configuration files

## Future Plans

- [ ] Add support for tmux configuration
- [ ] Integrate zsh configuration
- [ ] Add support for more development tools
- [ ] Enhanced multi-machine synchronization

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details