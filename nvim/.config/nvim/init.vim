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

"######################## Plugin-related configuration #######################

" Writegood Configuration
autocmd Filetype gitcommit,mail  WritegoodEnable
