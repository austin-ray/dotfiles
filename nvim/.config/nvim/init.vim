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
    if has('nvim-0.5')
        Plug 'neovim/nvim-lspconfig'
        Plug 'kabouzeid/nvim-lspinstall' " Helper to install LSP servers.
    else
        Plug 'prabirshrestha/vim-lsp'
        Plug 'mattn/vim-lsp-settings' " Convienent settings.
    endif

    " LSP works better with deoplete
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    if has('nvim-0.5')
        Plug 'deoplete-plugins/deoplete-lsp'
    else
        Plug 'lighttiger2505/deoplete-vim-lsp'
    endif

    if has('nvim-0.5')
        " Telescope for file navigation
        Plug 'nvim-lua/popup.nvim'
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim'
    endif
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
if has('nvim-0.5')
lua << EOF
    local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_opt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

        local opts = {noremap = true, silent = true}

        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'gs', '<Cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
        buf_set_keymap('n', 'gS', '<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', 'gt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.rename()<CR>', opts)
        buf_set_keymap('n', '[g', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']g', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    end

    local function setup_servers()
      require'lspinstall'.setup()
      local servers = require'lspinstall'.installed_servers()
      for _, server in pairs(servers) do
        require'lspconfig'[server].setup {
            on_attach = on_attach,
            flags = {
                debounce_text_changes = 500,
            }
        }
      end
    end

    setup_servers()

    -- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
    require'lspinstall'.post_install_hook = function ()
      setup_servers() -- reload installed servers
      vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
    end
EOF
else
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
endif

if exists('g:plugs["telescope.nvim"]')
    nnoremap <leader>ff <cmd>Telescope find_files<cr>
    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>
endif
