return {
    -- Plugin manager
    "folke/lazy.nvim",

    -- Grammar checker
    "davidbeckingsale/writegood.vim",

    -- Colorschemes
    "chriskempson/base16-vim",

    -- Automatically respect project-specific formatting.
    "editorconfig/editorconfig-vim",

    -- Enable syntax highlighting for hundreds of file formats.
    "sheerun/vim-polyglot",

    -- Enable LSP for better development experience.
    {
        "neovim/nvim-lspconfig",
        -- Helper to install LSP servers.
        { "williamboman/mason-lspconfig.nvim", dependencies = { "williamboman/mason.nvim" } }
    },

    -- LSP works better with a completion engine.
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        }
    },

    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        }
    },

    -- Telescope for file navigation
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Treesitter required for Neorg
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    -- Neorg for an org-mode experience
    "vhyrro/neorg",

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
        config = function()
            require("flit").setup()
        end
    },

    {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    },

    {
        "folke/trouble.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" }
    },

    -- For easily wrapping selections with characters
    {
        "kylechui/nvim-surround",
        config = function() require("nvim-surround").setup() end,
    },

    -- Make it easier to access the registers.
    {
        "tversteeg/registers.nvim",
        config = function()
            require("registers").setup()
        end
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
        config = function() require("Comment").setup() end
    },
}
