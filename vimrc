" Install vim-plug if not found
let data_dir = '~/.vim'
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
Plug 'pangloss/vim-javascript' | Plug 'kaicataldo/material.vim'
Plug 'kyazdani42/nvim-web-devicons'

" Language Server
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'        " Git Integration

Plug 'tpope/vim-commentary'        " Toggle comment for a line (gc) like ctrl-/
Plug 'ojroques/vim-oscyank' " Copy text to the system clipboard

" UI
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }     " File system tree
Plug 'ap/vim-buftabline'                                    " Buffer tabLine

" Initialize plugin system
call plug#end()

" Copy Text to the system clipboard (cmd+c)
vnoremap <D-c> :OSCYank<CR>

" True Colors
if &term =~ '256color'
  " Enable true (24-bit) colors instead of (8-bit) 256 colors.
  " :h true-color
  if has('termguicolors')
    set termguicolors
  endif
endif


" Set Theme
let g:material_theme_style = 'palenight'
let g:material_terminal_icalics = 1
" Fix italics for Vim with iTerm2
if !has('nvim')
  let &t_ZH="\e[3m"
  let &t_ZR="\e[23m"
endif
colorscheme material

" Tabs
nnoremap <silent><D-n> :enew<CR>
nnoremap <silent><c-n> :enew<CR>
nnoremap <silent><D-w> :bdelete!<CR>
nnoremap <silent><c-w> :bdelete!<CR>
nnoremap <silent><c-Tab> :bnext<CR>
let g:buftabline_show = 1       " Only show if there are at least two buffers
let g:buftabline_numbers = 0    " No numberinglet g:buftabline_indicators = 1 " Show state indicator (modified)
set hidden " Edit multiple buffers without saving

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
let g:lsp_async_completion = 1

" Preview Window
" allow modifying the completeopt variable, or it will be overridden all the time
let g:asyncomplete_auto_completeopt = 0

set completeopt=menuone,noinsert,noselect,preview

let g:lsp_preview_autoclose = 1

let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_signs_priority = 100

let g:lsp_diagnostics_signs_error         = { 'text': '' }
let g:lsp_diagnostics_signs_warning       = { 'text': '' }
let g:lsp_diagnostics_signs_information   = { 'text': '' }
let g:lsp_diagnostics_signs_hint          = { 'text': '' }
let g:lsp_document_code_action_signs_hint = { 'text': '' }
let g:lsp_tree_incoming_prefix = '⬅️    '

let g:lsp_semantic_enabled = 1

" Tab completion
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>" 
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ asyncomplete#force_refresh()
" inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" Force completion ctrl-space
imap <c-space> <Plug>(asyncomplete_force_refresh)

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


" Syntax Highlighting


" Folding
let g:lsp_fold_enabled = 1


if g:lsp_fold_enabled == 1
    set foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
      \ foldtext=lsp#ui#vim#folding#foldtext()
endif


" :wq Caps
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q


autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:> foldmethod=indent nofoldenable

set ruler
set rulerformat=Ln\ %l,\ Col\ %c\ %y

