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
-- Popup memnu height.
vim.opt.pumheight = 10

function toggle_relative_number()
    if vim.wo.relativenumber == true then
        vim.wo.relativenumber = false
        vim.wo.number = true
    else
        vim.wo.relativenumber = true
        vim.wo.number = false
    end
end

function clipboard_yank()
    vim.fn.system('xclip -i -selection clipboard', vim.fn.getreg('"'))
end

function clipboard_paste()
    vim.fn.setreg('"', vim.fn.system('xclip -o -selection clipboard'))
end

vim.api.nvim_set_keymap('v', 'y', 'y:lua clipboard_yank()<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', 'd', 'd:lua clipboard_yank()<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'p', ':lua clipboard_paste()<cr>p', {noremap = true, silent = true})
