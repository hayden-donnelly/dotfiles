vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.clipboard = 'unnamedplus'
vim.o.number = true
vim.o.signcolumn = 'yes'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.updatetime = 300
vim.o.termguicolors = true
vim.o.mouse = 'a'
-- Toggle relative line numbers on and off with 'r'.
vim.api.nvim_set_keymap('n', 'r', ':lua toggle_relative_number()<CR>', {noremap = true})

function toggle_relative_number()
    if vim.wo.relativenumber == true then
        vim.wo.relativenumber = false
        vim.wo.number = true
    else
        vim.wo.relativenumber = true
        vim.wo.number = false
    end
end

