"############################## Plugins ##################################

" Automatically install vim-plug plugin manager.
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . ' --create-dirs
    \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet autoload_plug_path

call plug#begin()
    Plug 'davidbeckingsale/writegood.vim'

    " Colorschemes
    Plug 'chriskempson/base16-vim'

    " Automatically respect project-specific formatting.
    Plug 'editorconfig/editorconfig-vim'

    " Enable syntax highlighting for hundreds of file formats.
    Plug 'sheerun/vim-polyglot'

    " Enable LSP for better development experience.
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings' " Convienent settings.

    " LSP works better wtih deoplete
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'lighttiger2505/deoplete-vim-lsp'

call plug#end()

"########################### Base Vim configuration ##########################

" Space is more convenient than \
let mapleader=" "

" Line numbers
set number
set relativenumber

" Tab to spaces
set expandtab
set shiftwidth=4
set softtabstop=4

" Enable 24-bit color allowing color scheme to work without visual errors.
set termguicolors
colorscheme base16-eighties

" Delegate folding to LSP
"set foldmethod=expr
"set foldexpr=lsp#ui#vim#folding#foldexpr()
"set foldtext=lsp#ui#vim#folding#foldtext()
"set foldlevelstart=99 " Don't fold buffer on open.

"######################## Plugin-related configuration #######################

" Deoplete configuration
let g:deoplete#enable_at_startup = 1

" Writegood Configuration
autocmd Filetype gitcommit,mail  WritegoodEnable

" LSP configurations
" Override default Vim with sensible LSP verisons.
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

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
