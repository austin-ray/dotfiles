local treesitter_languages = {
    "c",
    "cpp",
    "go",
    "haskell",
    "javascript",
    "lua",
    "markdown",
    "markdown_inline",
    "norg",
    "proto",
    "python",
    "query",
    "rust",
}

return {
    -- Plugin manager
    "folke/lazy.nvim",

    -- Grammar checker
    {
        "davidbeckingsale/writegood.vim",
        config = function()
            vim.api.nvim_create_autocmd({ "Filetype" }, {
                pattern = { "gitcommit", "mail", "jjdescription" },
                callback = function()
                    vim.cmd.WritegoodEnable()
                    vim.wo.spell = true
                end
            })
            vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
                pattern = "*.jjdescription",
                callback = function()
                    vim.cmd.WritegoodEnable()
                end
            })
        end,
    },

    -- Colorschemes
    {
        "chriskempson/base16-vim",
        config = function()
            vim.cmd.colorscheme("base16-eighties")
        end,
    },

    -- Automatically respect project-specific formatting.
    "editorconfig/editorconfig-vim",

    -- Enable syntax highlighting for hundreds of file formats.
    {
        "sheerun/vim-polyglot",
        lazy = true
    },

    -- Enable LSP for better development experience.
    {
        "neovim/nvim-lspconfig",
        ft = {
            "c",
            "cpp",
            "rust",
            "haskell",
            "nix",
            "lua",
            "python",
        },
        -- Helper to install LSP servers.
        dependencies = {
            {
                "williamboman/mason-lspconfig.nvim",
                dependencies = { "williamboman/mason.nvim" },
            },
            { "folke/neodev.nvim", opts = {} }
        },
        config = function()
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
            local on_attach = function(client, bufnr)
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
                vim.keymap.set("n", "<M-k>", vim.lsp.buf.signature_help, opts)
                vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)


                local lsp_ag = vim.api.nvim_create_augroup("LSP", {})
                local lsp_autocmd = grouped_autocmd(lsp_ag)

                lsp_autocmd("BufWritePre",
                    { buffer = bufnr, callback = function() vim.lsp.buf.format { async = false } end })
                if client.server_capabilities.documentHighlightProvider then
                    lsp_autocmd("CursorHold", { buffer = bufnr, callback = vim.lsp.buf.document_highlight })
                    lsp_autocmd("CursorHoldI", { buffer = bufnr, callback = vim.lsp.buf.document_highlight })
                    lsp_autocmd("CursorMoved", { buffer = bufnr, callback = vim.lsp.buf.clear_references })
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
            require("mason-lspconfig").setup()
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
            lspconfig.lua_ls.setup {}
        end
    },

    -- LSP works better with a completion engine.
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = function()
            vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
                    {
                        name = "buffer",
                        keyword_length = 5
                    },
                },
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
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
        end
    },

    {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
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
        end
    },

    -- Telescope for file navigation
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
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
        end,
        keys = {
            { "<leader>ff",  function() require("telescope.builtin").find_files() end },
            { "<leader>fgg", function() require("telescope.builtin").live_grep() end },
            { "<leader>fgo", function()
                require("telescope.builtin").live_grep({ grep_open_files = true })
            end
            },
            { "<leader>fb",  function() require("telescope.builtin").buffers() end },
            { "<leader>fh",  function() require("telescope.builtin").help_tags() end },
            { "<leader>ftr", function() require("telescope.builtin").resume() end },
            { "<leader>fsw", function() require("telescope.builtin").lsp_workspace_symbols() end },
            { "<leader>fss", function() require("telescope.builtin").lsp_document_symbols() end },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        ft = treesitter_languages,
        build = ":TSUpdate",
        config = function()
            -- Delegate folding to treesitter
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldlevel = 99

            require("nvim-treesitter.configs").setup({
                ensure_installed = treesitter_languages,
                highlight = {
                    enable = true,
                },
            })
        end,
    },

    {
        "epwalsh/obsidian.nvim",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("obsidian").setup({
                workspaces = {
                    {
                        name = "personal",
                        path = "~/syncthing/notes",
                    },
                }
            })
        end,
    },

    "tpope/vim-fugitive",
    "mhinz/vim-signify",

    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings()
        end
    },

    {
        "ggandor/flit.nvim",
        dependencies = { "ggandor/leap.nvim" },
        config = true
    },

    {
        "windwp/nvim-autopairs",
        config = true
    },

    {
        "folke/trouble.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("trouble").setup({
                auto_open = true,
                auto_close = true,
            })
        end,
    },

    -- For easily wrapping selections with characters
    {
        "kylechui/nvim-surround",
        config = function() require("nvim-surround").setup() end,
    },

    -- Make it easier to access the registers.
    {
        "tversteeg/registers.nvim",
        config = true
    },

    -- Have a start screen with easy jumping to recent files
    {
        "goolord/alpha-nvim",
        require = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("alpha").setup(require("alpha.themes.startify").config)
        end
    },
    {
        "numToStr/Comment.nvim",
        config = true
    },
    {
        "dstein64/vim-startuptime",
        cmd = "StartupTime",
        config = function()
            vim.g.startuptime_tries = 100
        end
    },
    {
        "akinsho/toggleterm.nvim",
        keys = "<leader>tt",
        opts = {
            hide_numbers = false,
            open_mapping = "<leader>tt",
            insert_mappings = false,
            terminal_mappings = false,
            size = function(term)
                if term.direction == "horizontal" then
                    return vim.o.lines * 0.35
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            shade_terminals = false,
        },
    }
}
