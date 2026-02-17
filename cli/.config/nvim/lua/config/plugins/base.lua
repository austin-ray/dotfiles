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
        event = "VeryLazy",
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
        "echasnovski/mini.base16",
        config = function()
            require("mini.base16").setup({
                palette = {
                    base00 = "#2d2d2d",
                    base01 = "#393939",
                    base02 = "#515151",
                    base03 = "#747369",
                    base04 = "#a09f93",
                    base05 = "#d3d0c8",
                    base06 = "#e8e6df",
                    base07 = "#f2f0ec",
                    base08 = "#f2777a",
                    base09 = "#f99157",
                    base0A = "#ffcc66",
                    base0B = "#99cc99",
                    base0C = "#66cccc",
                    base0D = "#6699cc",
                    base0E = "#cc99cc",
                    base0F = "#d27b53",
                }
            })
        end
    },

    -- Enable syntax highlighting for hundreds of file formats.
    {
        "sheerun/vim-polyglot",
        event = "VeryLazy",
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
            end

            require("mason").setup()
            require("mason-lspconfig").setup()
            vim.lsp.config['*'] = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 500,
                },
            }

            vim.lsp.enable("clangd")
            vim.lsp.enable("hls")
            vim.lsp.enable("pylsp")
            vim.lsp.enable("nil_ls", {
                settings = {
                    ["nil"] = {
                        formatting = {
                            command = { "nixfmt" },
                        },
                    },
                },
            })
            vim.lsp.enable("rust_analyzer")
            vim.lsp.enable("lua_ls")
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
                            n = {
                                ["dd"] = "delete_buffer",
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
        event = "VeryLazy",
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
        "mhinz/vim-signify",
        event = "VeryLazy",
    },

    {
        url = "https://codeberg.org/andyg/leap.nvim",
        event = "VeryLazy",
        config = function()
            vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
            vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
        end
    },

    {
        "ggandor/flit.nvim",
        dependencies = {
            url = "https://codeberg.org/andyg/leap.nvim",
        },
        event = "VeryLazy",
        config = true
    },

    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        config = true
    },

    -- For easily wrapping selections with characters
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function() require("nvim-surround").setup() end,
    },

    -- Make it easier to access the registers.
    {
        "tversteeg/registers.nvim",
        event = "VeryLazy",
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
        event = "VeryLazy",
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
