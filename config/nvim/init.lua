-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Platform detection
local is_mac = vim.fn.has('macunix') == 1
local is_arm_mac = is_mac and vim.fn.system('uname -m'):find('arm64') ~= nil
local is_linux = vim.fn.has('unix') == 1 and not is_mac
local is_wsl = vim.fn.has('wsl') == 1

-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'
vim.opt.completeopt = 'menuone,noselect'
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false

-- Plugin configuration
require("lazy").setup({
  -- Color scheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = false,
        terminal_colors = true,
      })
      vim.cmd[[colorscheme tokyonight]]
    end
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local has_treesitter, ts = pcall(require, 'nvim-treesitter.configs')
      if not has_treesitter then
        print('Warning: nvim-treesitter not found')
        return
      end

      ts.setup({
        ensure_installed = {
          "lua", "python", "rust", "c", "cpp", 
          "javascript", "typescript", "go", 
          "java", "markdown", "bash"
        },
        sync_install = false,
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end
  },

  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "j-hui/fidget.nvim",
    },
    config = function()
      local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
      if not has_lspconfig then
        print('Warning: nvim-lspconfig not found')
        return
      end

      local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
      if not has_cmp_nvim_lsp then
        print('Warning: cmp_nvim_lsp not found')
        return
      end

      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- LSP servers setup
      local servers = {
        'lua_ls',
        'pyright',
        'rust_analyzer',
        'clangd',
        'tsserver',
        'gopls',
      }

      -- Special config for Java on ARM Mac
      if is_arm_mac then
        local jdtls_config = {
          cmd = {
            '/opt/homebrew/opt/java/bin/java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms1g',
            '-Xmx2g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          },
        }
        lspconfig.jdtls.setup(vim.tbl_extend('force', {
          capabilities = capabilities,
        }, jdtls_config))
      else
        table.insert(servers, 'jdtls')
      end

      -- Generic LSP setup for each server
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            -- Enable completion
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

            -- LSP Keymaps
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<space>f', function() 
              vim.lsp.buf.format { async = true } 
            end, bufopts)
          end,
        })
      end
    end
  },

  -- Mason for LSP server management
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },

  -- Mason LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "clangd",
          "tsserver",
          "gopls",
          "jdtls",
        },
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local has_cmp, cmp = pcall(require, 'cmp')
      if not has_cmp then
        print('Warning: nvim-cmp not found')
        return
      end

      local has_luasnip, luasnip = pcall(require, 'luasnip')
      if not has_luasnip then
        print('Warning: luasnip not found')
        return
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end
  },

  -- File navigation
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      }
    },
    config = function()
      local has_telescope, telescope = pcall(require, 'telescope')
      if not has_telescope then
        print('Warning: telescope not found')
        return
      end

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", ".cache" },
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })

      telescope.load_extension('fzf')

      -- Telescope keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup()
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')
    end
  },
})

-- Additional keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Platform specific settings
if is_wsl then
  vim.g.clipboard = {
    name = 'win32yank-wsl',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = 0,
  }
end

if is_arm_mac then
  -- Use Homebrew Python on ARM Macs
  vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
  
  -- Additional ARM Mac specific settings
  vim.g.node_host_prog = '/opt/homebrew/bin/node'
  
  -- Adjust PATH for ARM-specific binaries
  vim.env.PATH = string.format('/opt/homebrew/bin:%s', vim.env.PATH)
end

-- Diagnostic signs
local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " "
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Global diagnostic settings
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

-- Hover settings
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = "rounded" }
)

-- Signature help settings
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = "rounded" }
)

-- Format on save for supported files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.py", "*.rs", "*.go", "*.java", "*.cpp", "*.h", "*.jsx", "*.tsx" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Auto save buffers when leaving them
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  command = "silent! wall",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remember last editing position
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.api.nvim_win_set_cursor(0, {last_pos, 0})
    end
  end,
})

-- Additional key mappings for better usability
local keymap_opts = { noremap = true, silent = true }

-- Better window navigation
vim.keymap.set('n', '<M-h>', ':wincmd h<CR>', keymap_opts)
vim.keymap.set('n', '<M-j>', ':wincmd j<CR>', keymap_opts)
vim.keymap.set('n', '<M-k>', ':wincmd k<CR>', keymap_opts)
vim.keymap.set('n', '<M-l>', ':wincmd l<CR>', keymap_opts)

-- Better indenting
vim.keymap.set('v', '<', '<gv', keymap_opts)
vim.keymap.set('v', '>', '>gv', keymap_opts)

-- Move selected line / block of text in visual mode
vim.keymap.set('x', 'K', ":move '<-2<CR>gv-gv", keymap_opts)
vim.keymap.set('x', 'J', ":move '>+1<CR>gv-gv", keymap_opts)

-- Better terminal navigation
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', keymap_opts)
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', keymap_opts)
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', keymap_opts)
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', keymap_opts)

-- Quick save and quit
vim.keymap.set('n', '<leader>w', ':w<CR>', keymap_opts)
vim.keymap.set('n', '<leader>q', ':q<CR>', keymap_opts)
vim.keymap.set('n', '<leader>Q', ':qa!<CR>', keymap_opts)

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', keymap_opts)
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', keymap_opts)
vim.keymap.set('n', '<leader>c', ':bdelete<CR>', keymap_opts)

-- Diagnostics navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, keymap_opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, keymap_opts)
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, keymap_opts)
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, keymap_opts)

-- Search improvements
vim.keymap.set('n', 'n', 'nzzzv', keymap_opts)  -- Center screen when searching
vim.keymap.set('n', 'N', 'Nzzzv', keymap_opts)
vim.keymap.set('n', '*', '*zzzv', keymap_opts)
vim.keymap.set('n', '#', '#zzzv', keymap_opts)

-- Split screen and navigation improvements
vim.keymap.set('n', '<leader>v', ':vsplit<CR>', keymap_opts)
vim.keymap.set('n', '<leader>h', ':split<CR>', keymap_opts)

-- Quick fix list navigation
vim.keymap.set('n', ']q', ':cnext<CR>', keymap_opts)
vim.keymap.set('n', '[q', ':cprev<CR>', keymap_opts)
vim.keymap.set('n', '<leader>qo', ':copen<CR>', keymap_opts)
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', keymap_opts)

-- Additional clipboard support for WSL
if is_wsl then
  vim.g.clipboard = {
    name = 'wslclipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

-- Load local machine-specific configuration if it exists
local local_config = vim.fn.stdpath('config') .. '/local.lua'
if vim.fn.filereadable(local_config) == 1 then
  dofile(local_config)
end