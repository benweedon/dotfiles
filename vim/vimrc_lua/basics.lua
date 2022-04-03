local M = {}

local util = require 'vimrc.util'

-- Normal and visual mode
util.map('n', '<space>', ':', {silent = false}) -- Remap space to : in normal mode for ease of use.
util.map('v', '<space>', ':', {silent = false}) -- Remap space to : in visual mode for ease of use.
util.map('n', '<bs>', '<cmd>update<cr>') -- Remap backspace to save in normal mode.
util.map('v', '<bs>', '<cmd>update<cr>') -- Remap backspace to save in visual mode.

-- Insert mode
util.map('i', 'uu', '<esc>') -- Use uu to exit insert mode.
util.map('i', 'hh', '<esc><cmd>update<cr>') -- Use hh to exit insert mode and save.
util.map('i', '<c-h>', '<cmd>update<cr>') -- Use ctrl+h to save while in insert mode.
util.map('i', '<c-t>', [[pumvisible() ? "\<c-n>" : "\<c-x>\<c-o>"]], {expr = true}) -- Easier omnifunc mapping.
util.map('i', '<c-d>', '<c-x><c-f>') -- Make file completion easier.
util.map('i', '<c-c>', '<c-x><c-n>') -- Make context-aware word completion easier.

-- Movement
util.map('', 'H', '^') -- H moves to first non-blank character of line.
util.map('', 'L', 'g_') -- L moves to last non-blank character of line.
util.map('', ':', ',') -- Move background for f and t even with , as the leader key.
util.map('', '<leader>h', 'H') -- Move the cursor to the top of the screen.
util.map('', '<leader>m', 'M') -- Move the cursor to the middle of the screen.
util.map('', '<leader>l', 'L') -- Move the cursor to the bottom of the screen.
util.map('', [[`]], [[']]) -- Swap ` and ' since one is easier to hit than the other.
util.map('', [[']], [[`]]) -- Swap ` and ' since one is easier to hit than the other.

-- Scrolling
util.map('n', '<c-h>', '<c-e>') -- Scroll down.
util.map('n', '<c-n>', '<c-y>') -- Scroll up.

-- Buffers
util.map('n', 'M', '<c-^>') -- Remap <c-^> to M, which has more editor support.
util.map('n', '<leader>r', ':edit<cr>') -- Use <leader>r to reload the buffer with :edit.

-- Windows
util.map('n', '<leader>t', '<c-w>')
util.map('n', '+', '<c-w>>')
util.map('n', '-', '<c-w><')
util.map('n', '<c-=>', '<c-w>+')
util.map('n', '<c-->', '<c-w>-')

return M
