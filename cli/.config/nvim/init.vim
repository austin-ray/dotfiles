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
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/nvim-lsp-installer' " Helper to install LSP servers.

    " LSP works better with a completion engine.
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/vim-vsnip'
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'rafamadriz/friendly-snippets'

    " Telescope for file navigation
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " Treesitter required for Neorg
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " Neorg for an org-mode experience
    Plug 'vhyrro/neorg'

    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'

    Plug 'easymotion/vim-easymotion'

    Plug 'pwntester/octo.nvim'
    Plug 'kyazdani42/nvim-web-devicons'

    Plug 'jiangmiao/auto-pairs'
call plug#end()

let g:EasyMotion_do_mapping = 0
nmap f <Plug>(easymotion-overwin-f)

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

" Keep UI from shifting by always showing the signcolumn
set signcolumn=yes

"######################## Plugin-related configuration #######################

" Writegood Configuration
autocmd Filetype gitcommit,mail  WritegoodEnable
autocmd Filetype gitcommit,mail  set spell
autocmd Filetype java let b:AutoPairs = AutoPairsDefine({"<":">"})

" Completion configuration
set completeopt=menu,menuone,noselect

if exists('g:plugs["telescope.nvim"]')
    nnoremap <leader>ff <cmd>Telescope find_files<cr>
    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>
endif

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)

nmap <leader>tt <Cmd>bot 24split +terminal<CR><Cmd>set noea<CR>
tnoremap <ESC><ESC> <C-\><C-N>

lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
      })
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'buffer' },
    }
  })

    -- LSP configurations
    -- Override default Vim with sensible LSP verisons.
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
        buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '[g', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']g', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', '<leader>a', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('v', '<leader>a', '<Cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)

        vim.api.nvim_command[[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync{timeout_ms=100}]]
    end

    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    local function setup_servers()
      local lsp_installer = require("nvim-lsp-installer")

      lsp_installer.on_server_ready(function(server)
          local opts = {
                capabilities = capabilities,
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 500,
                }
            }
          -- (optional) Customize the options passed to the server
          -- if server.name == "tsserver" then
          --     opts.root_dir = function() ... end
          -- end

          -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
          server:setup(opts)
          vim.cmd [[ do User LspAttachBuffers ]]
      end)
    end


    setup_servers()

    -- neorg configuration
    require('neorg').setup {
        -- Tell Neorg what modules to load
        load = {
            ["core.defaults"] = {}, -- Load all the default modules
            ["core.norg.concealer"] = {}, -- Allows for use of icons
            ["core.norg.dirman"] = { -- Manage your directories with Neorg
                config = {
                    workspaces = {
                        my_workspace = "~/neorg"
                    }
                }
            }
        },
    }

    -- Tree-sitter configuration
    local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()

    parser_configs.norg = {
        install_info = {
            url = "https://github.com/vhyrro/tree-sitter-norg",
            files = { "src/parser.c", "src/scanner.cc" },
            branch = "main"
        },
    }

    require('nvim-treesitter.configs').setup {
      ensure_installed = { "norg", "haskell", "cpp", "c", "javascript", "rust", "go"},
      highlight = {
        enable = true,
      }
    }
EOF
