-- ############################## Plugins ##################################

-- Automatically install the packer plugin manager.
local install_path = vim.fn.stdpath("data") .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
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
            "hrsh7th/cmp-nvim-lsp-signature-help",
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
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings()
        end
    }

    use {
        "ggandor/flit.nvim",
        requires = { "ggandor/leap.nvim" },
        config = function()
            require("flit").setup()
        end
    }

    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }

    use {
        "folke/trouble.nvim",
        requires = { "kyazdani42/nvim-web-devicons" }
    }

    -- For easily wrapping selections with characters
    use {
        "kylechui/nvim-surround",
        config = function() require("nvim-surround").setup() end,
    }

    -- Make it easier to access the registers.
    use {
        "tversteeg/registers.nvim",
        config = function()
            require("registers").setup()
        end
    }

    -- Have a start screen with easy jumping to recent files
    use {
        "goolord/alpha-nvim",
        require = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("alpha").setup(require("alpha.themes.startify").config)
        end
    }

    use {
        "numToStr/Comment.nvim",
        config = function() require("Comment").setup() end
    }

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

-- ########################### Base Vim configuration ##########################

-- Space is more convenient than \
vim.g.mapleader = " "

-- Quick access to configuration file.
vim.keymap.set("n", "<leader>ce", "<cmd>e $MYVIMRC<cr>")
vim.keymap.set("n", "<leader>cr", "<cmd>source $MYVIMRC<cr>")

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

-- Setup nvim-cmp.
local cmp = require("cmp")
if not cmp then return end

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
        ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }),
            { "i", "c" }
        ),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 5 },
    },
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
    experimental = {
        ghost_text = true,
    },
})

-- Create a helper function for adding `autocmd`s to a group.
--
-- Example usage:
-- ```lua
-- local some_plugin_augroup = nvim.nvim_create_augroup("some_plugin", {})
-- local plugin_autocmd = grouped_autocmd(some_plugin_augroup)
--
-- plugin_autocmd("BufWritePre", { command = "some vim command" })
-- plugin_autocmd("BufWritePost", { command = "some vim command" })
-- ```
local grouped_autocmd = function(group)
    return function(event, opts)
        opts.group = group
        vim.api.nvim_create_autocmd(event, opts)
    end
end

-- LSP configurations
-- Override default Vim with sensible LSP verisons.
local on_attach = function(client)
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

    local opts = { buffer = true, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, opts)
    vim.keymap.set("n", "gS", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<M-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)


    local lsp_ag = vim.api.nvim_create_augroup("LSP", {})
    local lsp_autocmd = grouped_autocmd(lsp_ag)

    lsp_autocmd("BufWritePre", { buffer = 0, command = "lua vim.lsp.buf.format()" })
    if client.server_capabilities.documentHighlightProvider then
        lsp_autocmd("CursorHold", { buffer = 0, callback = vim.lsp.buf.document_highlight })
        lsp_autocmd("CursorHoldI", { buffer = 0, callback = vim.lsp.buf.document_highlight })
        lsp_autocmd("CursorMoved", { buffer = 0, callback = vim.lsp.buf.clear_references })
    end

    -- Define highlight groups for document highlights
    vim.api.nvim_command([[
        highlight link LspReferenceText  Visual
        highlight link LspReferenceRead  Visual
        highlight link LspReferenceWrite Visual
    ]])
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason").setup()
local lspconfig = require("lspconfig")
lspconfig.util.default_config = vim.tbl_deep_extend(
    "force",
    lspconfig.util.default_config,
    {
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 500,
        }
    })

lspconfig.clangd.setup {}
lspconfig.hls.setup {}
lspconfig.pylsp.setup {}
lspconfig.rnix.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.sumneko_lua.setup {
    settings = {
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
    }
}

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
    ensure_installed = { "norg", "haskell", "cpp", "c", "javascript", "rust", "go", "proto" },
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
        layout_strategy = "vertical",
        layout_config = {
            vertical = {
                preview_cutoff = 10,
                width = 0.9
            },
        },
        mappings = {
            i = {
                ["<C-j>"] = require("telescope.actions").cycle_history_next,
                ["<C-k>"] = require("telescope.actions").cycle_history_prev,
            },
        },
    },
})

local telescope_fn = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_fn.find_files)
vim.keymap.set("n", "<leader>fgg", telescope_fn.live_grep)
vim.keymap.set("n", "<leader>fgo", function()
    telescope_fn.live_grep({ grep_open_files = true })
end)
vim.keymap.set("n", "<leader>fb", telescope_fn.buffers)
vim.keymap.set("n", "<leader>fh", telescope_fn.help_tags)
vim.keymap.set("n", "<leader>ftr", telescope_fn.resume)
vim.keymap.set("n", "<leader>fsw", telescope_fn.lsp_workspace_symbols)
vim.keymap.set("n", "<leader>fss", telescope_fn.lsp_document_symbols)

-- Trouble configuration
require("trouble").setup({
    auto_open = true,
    auto_close = true,
})
