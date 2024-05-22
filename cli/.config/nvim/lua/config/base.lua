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

-- Keep UI from shifting by always showing the signcolumn
vim.opt.signcolumn = "yes"

-- Disable mouse since I never use it in nvim and it messes with terminal copy.
vim.o.mouse = ""

vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { silent = true })
vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { silent = true })
vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { silent = true })
vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { silent = true })

vim.keymap.set("n", "<C-h>", "<Cmd>wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", "<Cmd>wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", "<Cmd>wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", "<Cmd>wincmd l<CR>", { silent = true })

vim.opt.scrolloff = 1
vim.opt.sidescrolloff = 5

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("jj_settings", {}),
    pattern = "*.jjdescription",
    callback = function()
        vim.wo.spell = true
        vim.bo.textwidth = 80
    end
})
