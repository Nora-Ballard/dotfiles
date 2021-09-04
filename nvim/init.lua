-- Bootstrap packer plug-in manager
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Auto compile
vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerSync
  augroup end
]],
  false
)


-- Plugins
do return require('packer').startup({function(use)
  use { -- Packer can manage itself
    [[wbthomason/packer.nvim]]
  }

  use { -- Material Theme
    [[marko-cerovac/material.nvim]],
    config = function() require("material").setup({
        contrast = true,
        boarders = false,
        italics  = {
          comments  = true,  -- Enable italic comments
          keywords  = true,  -- Enable italic keywords
          functions = true,  -- Enable italic functions
          strings   = false, -- Enable italic strings
          variables = false, -- Enable italic variables
        },
        contrast_windows = {
          "terminal",
          "packer",
          "qf",
        },
        text_contrast = {
          lighter = false,
          darker  = false,
        },
        disable = {
          background  = false,
          term_colors = false,
          eob_lines   = false,
        },
        custom_highlights = {}
      })

      -- True Colors
      if vim.fn.exists('+termguicolors') == 1 then 
        vim.opt.termguicolors = true
        -- Enable true (24-bit) colors instead of (8-bit) 256 colors.
        vim.env.t_8f = '\\<Esc>[38;2;%lu;%lu;%lum'
        vim.env.t_8b = '\\<Esc>[48;2;%lu;%lu;%lum'
      end 
      -- Colorscheme
      vim.cmd[[colorscheme material]]
	    require('material.functions').change_style("palenight")
    end
  }

  use { -- Treesitter: Smart Syntax Highlighting
    [[nvim-treesitter/nvim-treesitter]],     run    = ":TSUpdate",
    config = function() require('nvim-treesitter.configs').setup {
        indent           = { enable = true },
        highlight        = { enable = true, additional_vim_regex_highlighting = false },
        ensure_installed = { 'bash', 'dockerfile', 'go', 'hcl', 'json', 'regex', 'rust', 'vim', 'yaml'}
      }
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      parser_config.tsx.used_by = { "terraform" }
    end
  }

  use { -- Language Server
    {
      [[neovim/nvim-lspconfig]],
      requires = {},
      wants    = {
        'williamboman/nvim-lsp-installer',
        'hrsh7th/nvim-cmp',
        'onsails/lspkind-nvim',
      },
    },
    { -- LSP Server Installer
      [[williamboman/nvim-lsp-installer]],
      requires = 'neovim/nvim-lspconfig',
      after    = 'nvim-lspconfig',
      config   = function () require('nvim-lsp-installer').on_server_ready(function(server)
          local opts = {}
           -- (optional) Customize the options passed to the server
          -- if server.name == "tsserver" then
          --     opts.root_dir = function() ... end
          -- end
           -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
          server:setup(opts)
          vim.cmd [[ do User LspAttachBuffers ]]
        end)
      end
    },
    { -- CMP: Completion Engine
      [[hrsh7th/nvim-cmp]],
      wants = {
        'hrsh7th/cmp-buffer',
        'onsails/lspkind-nvim'
      },
      after = {
        'lspkind-nvim'
      },
      config   = function () require('cmp').setup {
          snippet = {
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end,
          },
          mapping = {
            ['<C-y>']     = require('cmp').mapping.confirm({ select = true }),
            ['<C-d>']     = require('cmp').mapping.scroll_docs(-4),
            ['<C-f>']     = require('cmp').mapping.scroll_docs(4),
            ['<C-Space>'] = require('cmp').mapping.complete(),
            ['<C-e>']     = require('cmp').mapping.close(),
            ['<CR>']      = require('cmp').mapping.confirm({
              behavior    = require('cmp').ConfirmBehavior.Replace,
              select      = true,
            }),
          },
          sources = {
            { name = 'buffer'   },
            { name = 'nvim_lsp' },
            { name = 'nvim_lua' },
          },
          formatting = {
            format = function(entry, vim_item)
              -- fancy icons and a name of kind
              vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
               -- set a name for each source
              vim_item.menu = ({
                buffer   = "[Buffer]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[Lua]",
              })[entry.source.name]
              return vim_item
            end,
          },
        }
      end,
    },
    { -- Completion Dialog Icons
      [[onsails/lspkind-nvim]],
      config = function () require('lspkind').init {
          -- enables text annotations
          --
          -- default: true
          with_text = true,

          -- default symbol map
          -- can be either 'default' (requires nerd-fonts font) or
          -- 'codicons' for codicon preset (requires vscode-codicons font)
          --
          -- default: 'default'
          preset = 'default',
        }
      end
    }
  }

  use { -- Trouble: Problem List
    [[folke/trouble.nvim]],
    requires = [[kyazdani42/nvim-web-devicons]],
    config   = function() require("trouble").setup {
      }
    end
  }

  use { -- GitSigns: Diff signcolumn
    [[lewis6991/gitsigns.nvim]],
    requires = [[nvim-lua/plenary.nvim]],
    config   = function() require("gitsigns").setup {
        linehl = false,
        numhl  = true,

        current_line_blame      = true,
        current_line_blame_opts = {
          virt_text             = true,
          virt_text_pos         = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay                 = 500,
        },
        current_line_blame_formatter_opts = {
          relative_time = false
        },
      }
      vim.opt.signcolumn = 'yes'
    end
  }

  use { -- Telescope: Search
    {
      [[nvim-telescope/telescope.nvim]],
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
      },
      wants = {
        'popup.nvim',
        'plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
      },
      cmd = 'Telescope',
      module = 'telescope',
      config = function() require("telescope").setup {
	      }
      end
    },
    {
      [[nvim-telescope/telescope-frecency.nvim]],
      after    = 'telescope.nvim',
      requires = 'tami5/sql.nvim',
    },
    {
      [[nvim-telescope/telescope-fzf-native.nvim]],
      run = 'make',
    },
  }

  use { -- Commentary: Toggle comment for a line (gc) like ctrl-/
    [[tpope/vim-commentary]],
  }

  use { -- Colorizer: Highlight Color Codes
    [[norcalli/nvim-colorizer.lua]],
    config = function () require'colorizer'.setup() end,
  }

  use { -- OSCYank: System Clipboard Integration
    [[ojroques/vim-oscyank]],
    config = function ()
      -- Copy Text to the system clipboard (cmd+c)
      vim.api.nvim_set_keymap('v', '<D-c>', ':OSCYank<CR>', {expr = true, noremap = true, silent = true})
    end
  }

  use { -- Autopairs: Automatically close brackets, quotes, etc
    [[windwp/nvim-autopairs]],
  }
   use { -- NERDtree
    [[scrooloose/nerdtree]],
  }

  use { -- BufTabLine: Tabline (buffers only)
    [[akinsho/bufferline.nvim]],
    requires = 'kyazdani42/nvim-web-devicons',
    config   = function () require("bufferline").setup {
        options = {
          diagnostics            = "nvim_lsp",
          separator_style        = "thin",
          always_show_bufferline = false,
        }
      }
      -- Key Bindings
      vim.api.nvim_set_keymap('n', '<D-n>',   ':enew<CR>',     {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<C-n>',   ':enew<CR>',     {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<D-w>',   ':bdelete!<CR>', {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<C-w>',   ':bdelete!<CR>', {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<C-Tab>', ':bnext<CR>',    {expr = true, noremap = true, silent = true})
      -- Edit Multiple buffers without saving
      vim.opt.hidden = true
    end
  }

  use { -- LuaLine: Status Bar
    [[hoob3rt/lualine.nvim]],
    config = function() require("lualine").setup {
        options = {
          icons_enabled        = true,
          theme                = 'material-nvim',
          section_separators   = {' ', ' '},
          component_separators = {'', ''},
          disabled_filetypes   = {},
        },
	      sections = {
          lualine_a = {
                      { 'branch' },
          },
          lualine_b = {
                      { 'diagnostics', sources = {'nvim_lsp'} },
                      { 'mode'   },
          },
          lualine_c = {''},
          lualine_x = {''},
          lualine_y = {
                      { 'location',   format = function () return [[Ln %l, Col %c]] end },
                      { 'encoding' },
                      { 'fileformat', icons_enabled = false },
                      { 'filetype' },
          },
          lualine_z = {''}
        },
        inactive_sections = {
         -- lualine_a = {},
         -- lualine_b = {},
         -- lualine_c = {},
         -- lualine_x = {},
         -- lualine_y = {},
         -- lualine_z = {},
        },
        extensions = {'nerdtree'}
      }
    end
  }
end,
config = { -- Packer
  display   = {
    open_fn = require('packer.util').float,
  }
}}); end

-- Case Insensitive
vim.opt.ignorecase = true

-- Enable Mouse
vim.opt.mouse = 'a'

-- Indent
vim.opt.expandtab   = true  -- Use Spaces
vim.opt.shiftwidth  = 4     -- Indent Width
vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.autoindent  = true  -- Auto Indent
vim.opt.smartindent = true

-- Indent with Tab key
vim.api.nvim_set_keymap('v', '<Tab>',   '>',  {silent = true})
vim.api.nvim_set_keymap('n', '<Tab>',   '>>', {silent = true})
vim.api.nvim_set_keymap('v', '<S-Tab>', '<',  {silent = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', '<<', {silent = true})

-- Indent: Keep selection in visual mode
vim.api.nvim_set_keymap('v', '<', '<gv',  {silent = true})
vim.api.nvim_set_keymap('v', '>', '>gv',  {silent = true})


-- Number Lines
vim.opt.number = true
-- Auto-Toggle Relative and Absolute 
-- https://jeffkreeftmeijer.com/vim-number/
vim.api.nvim_exec(
[[
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
]], false
)


-- Encoding
vim.opt.encoding      = 'utf-8'
vim.opt.fileencodings = 'utf-8'

-- :wq Caps
vim.api.nvim_exec(
[[
  cnoreabbrev W! w!
  cnoreabbrev Q! q!
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev W w
  cnoreabbrev Q q
]], false
)