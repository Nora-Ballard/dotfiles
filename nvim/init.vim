" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

if has('nvim')
	" Specify a directory for plugins
  call plug#begin(stdpath('data') . '/plugged')
else
	" Specify a directory for plugins
  call plug#begin('~/.vim/plugged')
endif

if has('nvim')
  "Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'kaicataldo/material.vim', { 'branch': 'main' }
endif
"#Plug 'neovim/nvim-lspconfig'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
"Plug 'ryanoasis/vim-devicons'
"Plug 'mzlogin/vim-markdown-toc'
"Plug 'norcalli/nvim-colorizer.lua'
"Plug 'airblade/vim-gitgutter'
"Plug 'tpope/vim-fugitive'
"Plug 'rhysd/git-messenger.vim'
"Plug 'tveskag/nvim-blame-line'
"Plug 'junegunn/fzf.vim'
"Plug 'machakann/vim-highlightedyank'
"Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tssm/fairyfloss.vim'
"Plug 'junegunn/vim-easy-align'
"Plug 'easymotion/vim-easymotion'

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

if has('nvim')
  let g:material_theme_style = 'palenight'
  let g:airline_theme = 'material'
  colorscheme material
endif

" Enable Mouse
set mouse=a

set tabstop=4 shiftwidth=4 softtabstop=4 autoindent expandtab

" Auto-Toggle Relative and Absolute line numbers
" https://jeffkreeftmeijer.com/vim-number/
:set number

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

set ruler

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" Language
" vim-lsp
" Tab completion
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" Preview Window
" allow modifying the completeopt variable, or it will
" be overridden all the time
let g:asyncomplete_auto_completeopt = 0

set completeopt=menuone,noinsert,noselect,preview
" Auto-close preview when completion is done
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif


if executable('yamlls')

else
  " YAML
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:> foldmethod=indent nofoldenable
endif
