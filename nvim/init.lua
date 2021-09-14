-- Bootstrap packer plug-in manager
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Auto compile Packer when init.lua is written
vim.api.nvim_exec(
[[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]], false)

------ Vim Settings ------

-- Search
vim.opt.inccommand  = 'nosplit'   -- Incremental live completion 
vim.opt.hlsearch    = true        -- Set highlight on search
vim.opt.ignorecase  = true        -- Case insensitive searching
vim.opt.smartcase   = true        -- Unless /C or capital in search
vim.opt.showmatch   = true
vim.opt.undofile    = true        -- Save undo history

-- Scroll
vim.opt.mouse       = 'a'         -- Enable Mouse
vim.opt.scrolloff   = 10

-- Indent
vim.opt.expandtab   = true        -- Use Spaces
vim.opt.shiftwidth  = 2           -- Indent Width
vim.opt.tabstop     = 2           -- |
vim.opt.softtabstop = 2           -- |
vim.opt.autoindent  = true        -- Auto Indent
vim.opt.smartindent = true

-- Keymap
vim.api.nvim_set_keymap('v', '<Tab>',   '>',   {silent = true})   -- Indent: with tab, shift-tab 
vim.api.nvim_set_keymap('n', '<Tab>',   '>>^', {silent = true})   -- |
vim.api.nvim_set_keymap('v', '<S-Tab>', '<',   {silent = true})   -- |
vim.api.nvim_set_keymap('n', '<S-Tab>', '<<^', {silent = true})   -- |

vim.api.nvim_set_keymap('v', '<',       '<gv', {silent = true})   -- Indent: Keep selection in visual mode
vim.api.nvim_set_keymap('v', '>',       '>gv', {silent = true})   -- |

-- FileType
vim.opt.syntax    = 'on'          -- Enable filetype detection by syntax
vim.api.nvim_exec([[
augroup indent
  autocmd FileType *         setlocal ts=4 sts=4 sw=4 expandtab autoindent smartindent
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter syntax match Tab /\t/
  autocmd FileType terraform setlocal ts=2 sts=2 sw=2 expandtab autoindent smartindent
  autocmd FileType yaml      setlocal ts=2 sts=2 sw=2 expandtab autoindent smartindent
  autocmd FileType lua       setlocal ts=2 sts=2 sw=2 expandtab autoindent smartindent
augroup END
]], false)

-- Number Line
vim.opt.number = true             -- On by default

-- Auto-Toggle Relative and Absolute 
-- https://jeffkreeftmeijer.com/vim-number/
vim.api.nvim_exec(
[[
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
]], false)


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
]], false)



------ Plugins -------
do return require('packer').startup({function(use)
  use { -- Packer can manage itself
    [[wbthomason/packer.nvim]]
  }

  use { -- Material Theme
    [[marko-cerovac/material.nvim]],
    config = function() require("material").setup({
        contrast    = true,
        boarders    = false,
        italics     = {
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

      -- Fix italics for Vim with iTerm2
      vim.env.t_ZH="\\e[3m"
      vim.env.t_ZR="\\e[23m"
      -- Colorscheme
      vim.cmd[[colorscheme material]]
        require('material.functions').change_style("palenight")
    end
  }

  use { -- Treesitter: Smart Syntax Highlighting
    [[nvim-treesitter/nvim-treesitter]],
    run    = ":TSUpdate",
    config = function() require('nvim-treesitter.configs').setup {
        indent           = { enable = true },
        highlight        = { enable = true, additional_vim_regex_highlighting = false },
        ensure_installed = { 'bash', 'dockerfile', 'go', 'hcl', 'json', 'lua', 'regex', 'rust', 'vim', 'yaml'}
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
        'hrsh7th/nvim-cmp',
        'onsails/lspkind-nvim',
      },

      config   = function() 
        -- Advertize nvim-cmp capabilities to the LSP servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.completion.completionItem.preselectSupport = true
        capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
        capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
        capabilities.textDocument.completion.completionItem.deprecatedSupport = true
        capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
        capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
        capabilities.textDocument.completion.completionItem.resolveSupport = {
          properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
          },
        }
        capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
        

        -- LS: Ansible
        if vim.fn.executable('ansible-language-server') ==1 then
          -- Install:  yarn global add ansible-language-server
          -- https://github.com/ansible/ansible-language-server
          --
          require'lspconfig'.ansiblels.setup{
            cmd          = { "ansible-language-server", "--stdio" },
            filetypes    = { "yaml" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Bash
        if vim.fn.executable('bash-language-server') == 1 then
          -- Install:  npm i -g bash-language-server
          -- https://github.com/mads-hartmann/bash-language-server
          --
          require('lspconfig').bashls.setup{
            cmd          = { "bash-language-server", "start" },
            cmd_env      = { GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)" },
            filetypes    = { "sh" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Docker
        if vim.fn.executable('docker-langserver') == 1 then
          -- Install:  npm install -g dockerfile-language-server-nodejs
          -- https://github.com/iamcco/diagnostic-languageserver
          --
          require('lspconfig').dockerls.setup{
            cmd          = { "docker-langserver", "--stdio" },
            filetypes    = { "Dockerfile", "dockerfile" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Dot Graph
        if vim.fn.executable('dot-language-server') == 1 then
          -- Install: npm install -g dot-language-server
          -- https://github.com/nikeee/dot-language-server
          --
          require('lspconfig').dotls.setup{
            cmd          = { "dot-language-server", "--stdio" },
            filetypes    = { "dot" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Go
        if vim.fn.executable('gopls') == 1 then
          -- Install:  GO111MODULE=on go get golang.org/x/tools/gopls@latest
          -- https://github.com/golang/tools/tree/master/gopls
          --
          require('lspconfig').gopls.setup{
            cmd       = { "gopls" },
            filetypes = { "go", "gomod" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Rust
        if vim.fn.executable('rust-analyzer') == 1 then
          -- Install:  rustup component add rust-src
          -- https://github.com/rust-analyzer/rust-analyzer
          --
          require('lspconfig').rust_analyzer.setup {
            cmd       = { "rust-analyzer" },
            filetypes = { "rust" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        end

        -- LS: Terraform
        -- if vim.fn.executable('terraform-ls') == 1 then
          -- https://github.com/hashicorp/terraform-ls
          --
          require('lspconfig').terraformls.setup {
            cmd       = { "docker", "run", "--rm", "-i", "homelab:latest", "terraform-ls", "serve" },
            filetypes = { "terraform" },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        -- end

        -- LS: Yaml
        -- if vim.fn.executable('docker') == 1 then
          -- Install:  yarn global add yaml-language-server
          -- https://github.com/redhat-developer/yaml-language-server
          --
          vim.lsp.set_log_level("debug")
          require('lspconfig').yamlls.setup {
            cmd       = { "docker", "run", "--rm", "-i", "quay.io/redhat-developer/yaml-language-server:latest" },
            filetypes = { "yaml" },
            settings = {
              yaml    = { 
                schemaStore    = { enable = false },
                trace          = { server = "verbose" },
                -- schemaDownload = { enable = true },
                validate = true,
              },
            },
            capabilities = capabilities,
            on_attach = on_attach,
          }
        -- end

        local nvim_lsp = require('lspconfig')
        local on_attach = function(_, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          local opts = { noremap = true, silent = true }
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>',      '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',         '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q',  '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
          vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]

        end

        
        vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text     = false,        -- Disable Virtual Text (in line error message)
          signs            = true,         -- Show Signs (Default)
          underline        = true,         -- Underline (Default)
          update_in_insert = true,         -- Enable updating in insert mode
        })

        -- Change diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }

        for type, icon in pairs(signs) do
          local hl = "LspDiagnosticsSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Show line diagnostics in hover window
        vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

      end,
    },
    { -- CMP: Completion Engine
      [[hrsh7th/nvim-cmp]],
      requires = {
        'hrsh7th/cmp-buffer',       -- source: buffer words
        'hrsh7th/cmp-nvim-lsp',     -- source: nvim LSP
        'hrsh7th/cmp-nvim-lua',     -- source; nvim LUA
        'L3MON4D3/LuaSnip',         -- source: Snippets
        'saadparwaiz1/cmp_luasnip', -- source: Snippets
        'onsails/lspkind-nvim',     -- pictograms: vscode-like
      },
      after = {
        'nvim-lspconfig',
        'lspkind-nvim',
      },
      config   = function () 
        -- Set completeopt to have a better completion experience
        vim.o.completeopt = 'menuone,noselect'

        -- luasnip setup
        local luasnip = require 'luasnip'

        -- Setup CMP
        local cmp = require 'cmp'
        cmp.setup {
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          mapping = {
            ['<C-j>']     = cmp.mapping.select_prev_item(),
            ['<C-k>']     = cmp.mapping.select_next_item(), 
            ['<C-y>']     = cmp.mapping.confirm({ select = true }),
            ['<C-d>']     = cmp.mapping.scroll_docs(-4),
            ['<C-f>']     = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>']     = cmp.mapping.close(),
            ['<CR>']      = cmp.mapping.confirm({
              behavior    = cmp.ConfirmBehavior.Replace,
              select      = true,
            }),
            ['<Tab>'] = function(fallback)
              if vim.fn.pumvisible() == 1 then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
              elseif luasnip.expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
              else
                fallback()
              end
            end,
            ['<S-Tab>'] = function(fallback)
              if vim.fn.pumvisible() == 1 then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
              elseif luasnip.jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
              else
                fallback()
              end
            end,
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'nvim_lua' },
            { name = 'luasnip'  },
            { name = 'buffer'   },
          },
          formatting = {
            format = function(entry, vim_item)
              -- fancy icons and a name of kind
              vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
               -- set a name for each source
              vim_item.menu = ({
                luasnip  = "[LuaSnip]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[Lua]",
                buffer   = "[Buffer]",
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
          -- enable text annotations
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
    after    = {
      'nvim-lspconfig',
    },
    requires = {
      'kyazdani42/nvim-web-devicons',
      'folke/lsp-colors.nvim',
    },
    config   = function() require("trouble").setup {
        mode = "lsp_workspace_diagnostics",    -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
        position         = "bottom",           -- position of the list can be: bottom, top, left, right
        height           = 10,                 -- height of the trouble list when position is top or bottom
        width            = 50,                 -- width of the list when position is left or right
        icons            = true,               -- use devicons for filenames
        action_keys      = {                   -- key mappings for actions in the trouble list, map to {} to remove a mapping
          close          = "q",                -- close the list
          cancel         = "<esc>",            -- cancel the preview and get back to your last window / buffer / cursor
          refresh        = "r",                -- manually refresh
          jump           = {"<cr>", "<tab>"},  -- jump to the diagnostic or open / close folds
          open_split     = { "<c-x>" },        -- open buffer in new split
          open_vsplit    = { "<c-v>" },        -- open buffer in new vsplit
          open_tab       = { "<c-t>" },        -- open buffer in new tab
          jump_close     = {"o"},              -- jump to the diagnostic and close the list
          toggle_mode    = "m",                -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = "P",                -- toggle auto_preview
          hover          = "K",                -- opens a small popup with the full multiline message
          preview        = "p",                -- preview the diagnostic location
          close_folds    = {"zM", "zm"},       -- close all folds
          open_folds     = {"zR", "zr"},       -- open all folds
          toggle_fold    = {"zA", "za"},       -- toggle fold of current file
          previous       = "k",                -- preview item
          next           = "j"                 -- next item
        },
        indent_lines     = true,               -- add an indent guide below the fold icons
        auto_open        = true,               -- automatically open the list when you have diagnostics
        auto_close       = true,               -- automatically close the list when you have no diagnostics
        auto_preview     = true,               -- automatically preview the location of the diagnostic. <esc> to close preview 
        auto_fold        = false,              -- automatically fold a file trouble list at creation
        signs = {                              -- icons / text used for a diagnostic
            error        = "",                -- |
            warning      = "",                -- |
            hint         = "",                -- |
            information  = "",                -- |
            other        = "﫠"                -- |
        },
        fold_open        = "",                -- icon used for open folds
        fold_closed      = "",                -- icon used for closed folds
        use_lsp_diagnostic_signs = false,      -- enabling this will use the signs defined in your lsp client
      }
      vim.wo.signcolumn  = 'yes'               -- Show Sign Column
    end
  }

  use { -- GitSigns: Diff signcolumn
    [[lewis6991/gitsigns.nvim]],
    requires = [[nvim-lua/plenary.nvim]],
    config   = function() require("gitsigns").setup {
        linehl = false,
        numhl  = true,

        
        sign_priority           = 6,
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
      vim.wo.signcolumn = 'yes' -- Show Sign Column
      vim.o.updatetime  = 250   -- Decrease update time
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
    config = function () 
      -- True Colors
      if vim.fn.has('termguicolors') == 1 then
          vim.opt.termguicolors = true
          require'colorizer'.setup()
      end
    end,
  }

  use { -- OSCYank: System Clipboard Integration
    [[ojroques/vim-oscyank]],
    config = function ()
      -- Copy Text to the system clipboard (cmd+c)
      vim.api.nvim_set_keymap('v', '<D-c>', ':OSCYank<CR>', {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('v', '<c-c>', ':OSCYank<CR>', {expr = true, noremap = true, silent = true})
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
      -- vim.api.nvim_set_keymap('n', '<D-t>',   ':enew<CR>',     {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<c-t>',   ':enew<CR>',     { noremap = true, silent = true})
      -- vim.api.nvim_set_keymap('n', '<D-w>',   ':bdelete!<CR>', {expr = true, noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<c-w>',   ':bdelete!<CR>', { noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<c-Tab>', ':bnext<CR>',    { noremap = true, silent = true})
      -- Edit Multiple buffers without saving
      vim.opt.hidden = true
    end
  }

  use { -- LuaLine: Status Bar
    [[hoob3rt/lualine.nvim]],
    config = function() 
      local function lsp_buf_clients()
        buf_clients = {}
        vim.tbl_map(
          function(client) table.insert(buf_clients, client.name) end, 
          vim.lsp.buf_get_clients()
        )
        return table.concat(buf_clients, ", ")

      end
      local function indent() 
        if (vim.opt.expandtab:get()) then et = "Spaces" else et = "Tabs" end
        return string.format('%s: %s', et, (vim.opt.shiftwidth:get()))
      end
      require("lualine").setup {
        options = {
          icons_enabled        = true,
          theme                = 'material-nvim',
          section_separators   = {' ', ' '},
          component_separators = {'', ''},
          disabled_filetypes   = {},
        },
          sections = {
          lualine_a = {''},
          lualine_b = {
                      { 'branch' },
          },
          lualine_c = {
                      { 'diagnostics', sources = {'nvim_lsp'} },
                      { 'mode'   },
          },
          lualine_x = {
                      { 'location',   format = function () return [[Ln %l, Col %c]] end },
                      { indent     },
                      { 'encoding' },
                      { 'fileformat', icons_enabled = false },
                      { lsp_buf_clients },
                      { 'filetype' },
          },
          lualine_y = {''},
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

