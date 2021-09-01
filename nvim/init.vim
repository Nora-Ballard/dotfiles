" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync |
\| endif

" Specify a directory for plugins
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" *** Install Plugins ***
Plug 'kaicataldo/material.vim', has('nvim') ? {} : { 'on': [] }
" Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'

" Language Server
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Smart Syntax Highlighting

"Plug 'mzlogin/vim-markdown-toc'
Plug 'airblade/vim-gitgutter'

" Telescope: Interactive fuzzy finder
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

"Plug 'tpope/vim-fugitive'
"Plug 'rhysd/git-messenger.vim'
"Plug 'tveskag/nvim-blame-line'
"Plug 'junegunn/fzf.vim'
"Plug 'machakann/vim-highlightedyank'
"
Plug 'tpope/vim-commentary'        " Comment Line (gc) like ctrl-/
Plug 'norcalli/nvim-colorizer.lua' " Highlight Color Codes
"Plug 'junegunn/vim-easy-align'
"Plug 'easymotion/vim-easymotion'

" UI
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ap/vim-buftabline'           " Tab Line
Plug 'hoob3rt/lualine.nvim'        " Status Line
"Plug 'vim-airline/vim-airline'

" Initialize plugin system
call plug#end()


" True Colors
if &term =~ '256color'
  " Enable true (24-bit) colors instead of (8-bit) 256 colors.
  " :h true-color
  if has('termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
  endif
endif


" Set Theme
if has('nvim')
  let g:material_theme_style = 'palenight'
  let g:airline_theme = 'material'
  colorscheme material
endif


" Ignore Case
set ignorecase

" Enable Mouse
set mouse=a

" Default Tabs
set tabstop=4 shiftwidth=4 softtabstop=4 autoindent expandtab smartindent

" Tab Indent
vmap <Tab> >
nmap <Tab> >>
vmap <S-Tab> <
nmap <S-Tab> <<
" Don't loose selection after indent
vmap < <gv
vmap > >gv



" Auto-Toggle Relative and Absolute line numbers
" https://jeffkreeftmeijer.com/vim-number/
set number

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END



" Always show signcolumns
" set signcolumn=yes

" Always show status bar (col,row)
set ruler

" Encoding
set encoding=utf-8
set fileencodings=utf-8


" ** Language **

" Toggle Comment (wip, ctrl-/ doesn't seem to remap)
vmap  gc
nmap  gcc

" vim-lsp
let g:lsp_auto_enable = 1

" Preview Window
" allow modifying the completeopt variable, or it will be overridden all the time
let g:asyncomplete_auto_completeopt = 0

set completeopt=menuone,noinsert,noselect,preview


" vim-lsp - performance
 let g:lsp_use_lua = has('nvim-0.4.0') || (has('lua') && has('patch-8.2.0775'))

" vim-lsp - configure buffer
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    inoremap <buffer> <expr><c-f> lsp#scroll(+4)
    inoremap <buffer> <expr><c-d> lsp#scroll(-4)

    " Use tab for trigger completion with characters ahead and navigate
    " Tab completion
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>" 
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
     " Auto-close preview when completion is done
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

   
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Terraform
if executable('terraform-ls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'terraform-ls',
        \ 'cmd': {server_info->['terraform-ls', 'serve']},
        \ 'whitelist': ['terraform'],
        \ })
else
    au BufRead,BufNewFile *.tf set filetype=terraform
    au BufRead,BufNewFile *.tfvars set filetype=terraform

    autocmd FileType terraform setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# foldmethod=indent nofoldenable
endif


" Tree-Sitter
lua <<EOT
require 'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "bash",
        "dockerfile",
        "go",
        "hcl", 
        "json",
        "regex",
        "rust",
        "vim",
        "yaml"
    },
    ignore_install = {},
    highlight = {
        enable = true, 
        disable = {}, 
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = { 
    enable = true
  } 
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.used_by = { "javascript", "typescript.tsx" }
EOT

" Tabs
nnoremap <silent><D-n> :enew<CR>
nnoremap <silent><c-n> :enew<CR>
nnoremap <silent><D-w> :bdelete!<CR>
nnoremap <silent><c-w> :bdelete!<CR>
nnoremap <silent><c-Tab> :bnext<CR>
set hidden " Edit multiple buffers without saving

" Status Bar
" https://blog.inkdrop.app/how-to-set-up-neovim-0-5-modern-plugins-lsp-treesitter-etc-542c3d9c9887
lua <<EOT
local status, lualine = pcall(require, "lualine")
if (not status) then return end
lualine.setup {
  options = {
    icons_enabled = true,
    theme = 'solarized_dark',
    section_separators = {'', ''},
    component_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {
      { 'diagnostics', sources = {"nvim_lsp"}, symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '} },
      'encoding',
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {'fugitive'}
}
EOT
" :wq Caps
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q

if executable('yaml-language-server')

else
  " YAML
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:> foldmethod=indent nofoldenable
endif
