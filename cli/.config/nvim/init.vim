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
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
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
    Plug 'mhinz/vim-signify'

    Plug 'easymotion/vim-easymotion'

    Plug 'jiangmiao/auto-pairs'

    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'folke/trouble.nvim'

    " For easily wrapping selections with characters
    Plug 'tpope/vim-surround'

    " Have a start screen with easy jumping to recent files
    Plug 'mhinz/vim-startify'

    if !empty(glob("~/.config/nvim/private-plugins.vim"))
        source ~/.config/nvim/private-plugins.vim
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

" Keep UI from shifting by always showing the signcolumn
set signcolumn=yes

nmap <leader>tt <Cmd>bot 24split +terminal<CR><Cmd>set noea<CR>
tnoremap <ESC><ESC> <C-\><C-N>

" Delegate folding to treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=99

nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>

set scrolloff=1
set sidescrolloff=5

"######################## Plugin-related configuration #######################

let g:EasyMotion_do_mapping = 0
nmap f <Plug>(easymotion-overwin-f)

" Writegood Configuration
autocmd Filetype gitcommit,mail  WritegoodEnable
autocmd Filetype gitcommit,mail  set spell
autocmd Filetype java let b:AutoPairs = AutoPairsDefine({"<":">"})

" Completion configuration
set completeopt=menu,menuone,noselect

lua <<EOF
-- Setup nvim-cmp.
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping(
			cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = true,
			}),
			{ "i", "c" }
		),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_length = 5 },
	},
})

-- LSP configurations
-- Override default Vim with sensible LSP verisons.
local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local function buf_set_opt(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	buf_set_opt("omnifunc", "v:lua.vim.lsp.omnifunc")

	local opts = { noremap = true, silent = true }

	buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	buf_set_keymap("n", "gs", "<Cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
	buf_set_keymap("n", "gS", "<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
	buf_set_keymap("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
	buf_set_keymap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	buf_set_keymap("n", "gt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	buf_set_keymap("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "[d", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<M-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "<leader>a", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	buf_set_keymap("v", "<leader>a", "<Cmd>lua vim.lsp.buf.range_code_action()<CR>", opts)

	vim.api.nvim_command("augroup LSP")
	vim.api.nvim_command("autocmd!")
	vim.api.nvim_command("autocmd BufWritePre * lua vim.lsp.buf.formatting_sync{timeout_ms=50}")
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_command("autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()")
		vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
		vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()")
	end
	vim.api.nvim_command("augroup END")

	-- Define highlight groups for document highlights
	vim.api.nvim_command([[
        highlight link LspReferenceText  Visual
        highlight link LspReferenceRead  Visual
        highlight link LspReferenceWrite Visual
    ]])
end

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local function setup_servers()
	local lsp_installer = require("nvim-lsp-installer")

	lsp_installer.on_server_ready(function(server)
		local opts = {
			capabilities = capabilities,
			on_attach = on_attach,
			flags = {
				debounce_text_changes = 500,
			},
		}
		-- (optional) Customize the options passed to the server
		-- if server.name == "tsserver" then
		--     opts.root_dir = function() ... end
		-- end

		-- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
		server:setup(opts)
		vim.cmd([[ do User LspAttachBuffers ]])
	end)
end

setup_servers()

-- Setup luasnip
local luasnip = require("luasnip")
local luasnip_types = require("luasnip.util.types")

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

luasnip.config.set_config({
	history = true,
	updateevents = "TextChanged,TextChangedI",
	enable_autosnippets = true,
})

-- Expand snippet or jump to next snippet node.
vim.keymap.set({ "i", "s" }, "<c-j>", function()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	end
end, { silent = true })

-- Jump to previous snippet node.
vim.keymap.set({ "i", "s" }, "<c-k>", function()
	if luasnip.jumpable(-1) then
		luasnip.jump(-1)
	end
end, { silent = true })

-- neorg configuration
require("neorg").setup({
	-- Tell Neorg what modules to load
	load = {
		["core.defaults"] = {}, -- Load all the default modules
		["core.norg.concealer"] = {}, -- Allows for use of icons
		["core.norg.dirman"] = { -- Manage your directories with Neorg
			config = {
				workspaces = {
					my_workspace = "~/neorg",
				},
			},
		},
	},
})

-- Tree-sitter configuration
local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

parser_configs.norg = {
	install_info = {
		url = "https://github.com/vhyrro/tree-sitter-norg",
		files = { "src/parser.c", "src/scanner.cc" },
		branch = "main",
	},
}

require("nvim-treesitter.configs").setup({
	ensure_installed = { "norg", "haskell", "cpp", "c", "javascript", "rust", "go" },
	highlight = {
		enable = true,
	},
})

-- Telescope configuration
require("telescope").setup({
	pickers = {
		buffers = {
			mappings = {
				i = {
					["<C-d>"] = "delete_buffer",
				},
			},
		},
	},
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = require("telescope.actions").cycle_history_next,
				["<C-k>"] = require("telescope.actions").cycle_history_prev,
			},
		},
	},
})

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fgg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fgo", function()
    require('telescope.builtin').live_grep({grep_open_files = true})
end)
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>ftr", "<cmd>Telescope resume<cr>")

-- Trouble configuration
require("trouble").setup({
	auto_open = true,
	auto_close = true,
})
EOF
