local util = require 'vimrc.util'

-- Normal and visual mode
util.map({'n', 'x'}, '<space>', ':', {silent = false}) -- Remap space to : in normal and visual mode for ease of use.
util.map({'n', 'x'}, '<bs>', '<cmd>update<cr>') -- Remap backspace to save in normal and visual mode.
util.map('n', '<m-q>', '@@') -- Have an easily repeatable combo for @@.

-- Insert mode
util.map('i', 'uu', '<esc>') -- Use uu to exit insert mode.
util.map('i', 'hh', '<esc><cmd>update<cr>') -- Use hh to exit insert mode and save.
util.map('i', '<c-h>', '<cmd>update<cr>') -- Use ctrl+h to save while in insert mode.
util.map('i', '<c-d>', '<c-x><c-f><c-n>') -- Make file completion easier.
util.map('i', '<c-c>', '<c-x><c-n><c-n>') -- Make context-aware word completion easier.
util.map('i', '<c-l>', '<c-x><c-l><c-n>') -- Make line completion easier.

-- Command mode
-- Easily type and expand '%:h/' in command mode.
util.map('c', '<c-h>', function()
    util.feedkeys(t'%:h<tab>', 'nt')
end)

-- Movement
util.map({'n', 'x', 'o'}, 'H', '^') -- H moves to first non-blank character of line.
util.map({'n', 'x', 'o'}, 'L', '$') -- L moves to last  character of line.
util.map({'n', 'x', 'o'}, ':', '<plug>Lightspeed_,_ft') -- Move background for f and t even with , as the leader key.
util.map({'n', 'x', 'o'}, '<leader>h', 'H') -- Move the cursor to the top of the screen.
util.map({'n', 'x', 'o'}, '<leader>m', 'M') -- Move the cursor to the middle of the screen.
util.map({'n', 'x', 'o'}, '<leader>l', 'L') -- Move the cursor to the bottom of the screen.
util.map({'n', 'x', 'o'}, [[`]], [[']]) -- Swap ` and ' since one is easier to hit than the other.
util.map({'n', 'x', 'o'}, [[']], [[`]]) -- Swap ` and ' since one is easier to hit than the other.

-- Scrolling
util.map('n', '<c-h>', '<c-e>') -- Scroll down.
util.map('n', '<c-n>', '<c-y>') -- Scroll up.

-- Buffers
util.map('n', 'M', '<c-^>') -- Remap <c-^> to M, which has more editor support.
util.map('n', '<leader>r', '<cmd>edit<cr>') -- Use <leader>r to reload the buffer with :edit.

-- Windows
util.map('n', '<leader>t', '<c-w>')
util.map('n', '+', '<c-w>>')
util.map('n', '-', '<c-w><')
util.map('n', '<m-=>', '<c-w>+')
util.map('n', '<m-->', '<c-w>-')

-- Options
-- Tabs
vim.opt.expandtab = true -- Tabs are expanded to spaces.
vim.opt.shiftround = true -- Should round indents to multiple of shiftwidth.
util.set_tab_size(4, true --[[global_opt]])
-- Show whitespace
vim.opt.list = true -- Display whitespace characters.
vim.opt.listchars = {tab = '>.', trail = '.', extends = '#', nbsp = '.'} -- Specify which whitespace characters to display.
-- UI
vim.opt.number = true -- Show line numbers.
vim.opt.relativenumber = true -- Show relative line numbers.
vim.opt.title = true -- Title of window set to titlename/currently edited file.
vim.opt.visualbell = true -- Use visual bell instead of beeping.
vim.opt.colorcolumn = {80, 120} -- Highlight the 80th and 120th columns for better line-length management.
vim.opt.cursorline = true -- Highlight the current line.
vim.opt.cursorcolumn = true -- Highlight the current column.
vim.opt.wildmode = {'longest', 'full'} -- In command line, first <tab> press complete to longest common string, next show full match.
vim.opt.lazyredraw = true -- Don't redraw the screen while executing mappings and commands.
vim.opt.wildignore:append('.git') -- Ignore the .git directory when expanding wildcards.
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 3
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = {a = true} -- Enable interaction using the mouse.
vim.opt.updatetime = 1000
vim.opt.diffopt:append('vertical') -- Always open diffs in vertical splits.
vim.opt.diffopt:append('algorithm:histogram') -- Use the histogram algorithm for more readable diffs.
vim.opt.diffopt:append('indent-heuristic') -- Try to make more aesthetically pleasing diffs.
vim.opt.termguicolors = true
vim.opt.background = 'dark'
-- Editing
vim.opt.wrap = false -- Don't wrap lines.
vim.opt.showmatch = true -- Show matching bracket when one is inserted.
vim.opt.foldmethod = 'syntax' -- Fold based on the language syntax (e.g. #region tags).
vim.opt.fileformats = {'unix', 'dos'} -- Set Unix line endings as the default.
vim.opt.timeout = false -- Don't time out waiting for mappings.
vim.opt.spelloptions = {'camel'}
