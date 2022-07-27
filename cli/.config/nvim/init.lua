-- ############################## Plugins ##################################

-- Automatically install the packer plugin manager.
local install_path = vim.fn.stdpath("data") .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
        install_path })
end

require("packer").startup(function(use)
    -- Plugin manager
    use "wbthomason/packer.nvim"

    -- Grammar checker
    use "davidbeckingsale/writegood.vim"

    -- Colorschemes
    use "chriskempson/base16-vim"

    -- Automatically respect project-specific formatting.
    use "editorconfig/editorconfig-vim"

    -- Enable syntax highlighting for hundreds of file formats.
    use "sheerun/vim-polyglot"

    -- Enable LSP for better development experience.
    use {
        "neovim/nvim-lspconfig",
        -- Helper to install LSP servers.
        { "williamboman/mason-lspconfig.nvim", requires = { "williamboman/mason.nvim" } }
    }



    -- LSP works better with a completion engine.
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
        }
    }

    use {
        "L3MON4D3/LuaSnip",
        requires = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        }
    }

    -- Telescope for file navigation
    use "nvim-lua/popup.nvim" -- TODO: Figure out why this is here.
    use {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" }
    }

    -- Treesitter required for Neorg
    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end
    }

    -- Neorg for an org-mode experience
    use "vhyrro/neorg"

    use "tpope/vim-fugitive"
    use "mhinz/vim-signify"

    use {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function() require("hop").setup() end
    }

    use "jiangmiao/auto-pairs"

    use {
        "folke/trouble.nvim",
        requires = { "kyazdani42/nvim-web-devicons" }
    }

    -- For easily wrapping selections with characters
    use "tpope/vim-surround"

    -- Have a start screen with easy jumping to recent files
    use "mhinz/vim-startify"

    use {
        "numToStr/Comment.nvim",
        config = function() require("Comment").setup() end
    }

    if packer_bootstrap then
        require("packer").sync()
    end
end)

-- ########################### Base Vim configuration ##########################

-- Space is more convenient than \
vim.g.mapleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tab to spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Enable 24-bit color allowing color scheme to work without visual errors.
vim.opt.termguicolors = true
-- TODO: Convert this to Lua when API comes out.
vim.cmd("colorscheme base16-eighties")

-- Keep UI from shifting by always showing the signcolumn
vim.opt.signcolumn = "yes"

vim.keymap.set("n", "<leader>tt", function()
    -- TODO: Convert this to Lua code.
    vim.api.nvim_command('botright 24split +terminal')
    -- vim.go.equalalwaytrues = false
end)
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>")

-- Delegate folding to treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { silent = true })

vim.opt.scrolloff = 1
vim.opt.sidescrolloff = 5

-- ######################## Plugin-related configuration #######################

vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Writegood configuration
vim.api.nvim_create_autocmd({ "Filetype" }, {
    pattern = { "gitcommit", "mail" },
    callback = function()
        vim.cmd("WritegoodEnable")
        vim.wo.spell = true
    end
})

-- Autopair configuration
vim.api.nvim_create_autocmd({ "Filetype" }, {
    pattern = "java",
    callback = function()
        vim.b.AutoPairs = vim.fn.AutoPairsDefine({ ["<"] = ">" })
    end
})

-- Hop configuration
vim.keymap.set("n", "f", function() require("hop").hint_char1() end)

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

require("mason").setup()
local lspconfig = require("lspconfig")

-- Helper to reduce amount of config
local setup_server = function(server, settings)
    local opts = {
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 500,
        },
    }

    if settings then
        opts.settings = settings
    end

    lspconfig[server].setup(opts)
end

setup_server("hls")
setup_server("rust_analyzer")
setup_server("sumneko_lua", {
    Lua = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        runtime = { version = 'LuaJIT', },
        -- Get the language server to recognize the `vim` global
        diagnostics = { globals = { 'vim' }, },
        -- Make the server aware of Neovim runtime files
        workspace = { library = vim.api.nvim_get_runtime_file("", true), },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = { enable = false, },
    },
})



-- Setup luasnip
local luasnip = require("luasnip")

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

vim.keymap.set("i", "<c-l>", function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end)

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
    require('telescope.builtin').live_grep({ grep_open_files = true })
end)
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>")
vim.keymap.set("n", "<leader>ftr", "<cmd>Telescope resume<cr>")

-- Trouble configuration
require("trouble").setup({
    auto_open = true,
    auto_close = true,
})
