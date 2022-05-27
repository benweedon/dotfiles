local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('vimrc.misc')

-- Fix the closest previous spelling mistake.
util.map('n', {expr = true}, '<leader>z=', util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd 'silent normal! [s1z='

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end))

-- Mark the closest previous spelling mistake good.
util.map('n', {expr = true}, '<leader>zg', util.new_operator_with_inherent_motion('l', function()
    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and mark it as good.
    vim.cmd 'silent normal! [szg'

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end))

util.map('n', '<leader>zt', function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
end)

local function clear_cursor_highlight()
    if vim.w.vimrc__cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(vim.w.vimrc__cursor_highlight_match_id)
        vim.w.vimrc__cursor_highlight_match_id = nil
    end
end

-- Highlight word under cursor.
local function highlight_word_under_cursor()
    clear_cursor_highlight()

    local word = vim.fn.escape(vim.fn.expand('<cword>'), [[\/]])
    local pattern = string.format([[\V\<%s\>]], word)

    vim.w.vimrc__cursor_highlight_match_id = vim.fn.matchadd('vimrc__CursorOver', pattern)
end

util.augroup('vimrc__highlight_word_under_cursor', {
    {{'CursorMoved', 'CursorMovedI'}, {callback = highlight_word_under_cursor}},
    {'WinLeave', {callback = clear_cursor_highlight}},
})

-- Center mode.
local in_center_mode
local function enable_center_mode()
    util.augroup('vimrc__center_mode', {
        {'CursorMoved', {command = 'normal! zz'}},
    })

    vim.cmd [[normal! zz]]

    in_center_mode = true
end

local function disable_center_mode()
    -- Do this check since the below API will fail if the group doesn't exist.
    if in_center_mode then
        vim.api.nvim_del_augroup_by_name('vimrc__center_mode')
    end

    in_center_mode = false
end

-- This is the default setting.
disable_center_mode()

-- Toggle center mode.
util.map('n', {expr = true}, 'cm', util.new_operator_with_inherent_motion('l', function()
    if in_center_mode then
        disable_center_mode()
    else
        enable_center_mode()
    end
end))

-- Easy switching between cpp and header files.
util.map('n', '<leader>ch', function()
    if vim.fn.expand('%:e') == 'h' then
        vim.cmd [[edit %<.cpp]]
    elseif vim.fn.expand('%:e') == 'cpp' then
        vim.cmd [[edit %<.h]]
    end
end)

-- Search help for the word under the cursor.
util.map('n', '<leader>?', [[<cmd>execute 'help ' . expand("<cword>")<cr>]])

-- Open GitHub short URLs for plugins.
util.map('n', '<leader>gh', function()
    vim.fn['netrw#BrowseX']('https://github.com/' .. vim.fn.expand('<cfile>'), 0)
end)

-- errorformat
vim.opt.errorformat = {}
-- build.exe errors
vim.opt.errorformat:append [[%[0-9]%\+>%f(%l) : %m]]
vim.opt.errorformat:append [[%f(%l) : %m]]

-- Ignore anything that doesn't match the previous errors.
vim.opt.errorformat:append [[%-G%.%#]]

-- Fixes the problem detailed at
-- http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text. Without
-- this, folds open and close at will as you type code.
util.augroup('vimrc__fixfolds', {
    {'InsertEnter', {command = [[if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif]]}},
    {{'InsertLeave', 'WinLeave'}, {command = [[if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif]]}},
})

-- Briefly highlight text on yank.
util.augroup('vimrc__highlight_on_yank', {
    {'TextYankPost', {callback =
        function()
            vim.highlight.on_yank {higroup = 'Search'}
        end,
    }},
})

-- Easily open files specified by a glob.
util.user_command(
    'Open',
    function(args)
        local files = vim.fn.glob(args.args, false --[[nosuf]], true --[[list]])

        for _, file in ipairs(files) do
            vim.cmd(string.format('edit %s', file))
        end
    end,
    {nargs = '+'}
)

-- Open all folds the first time a buffer is opened.
util.augroup('vimrc__open_folds', {
    {'BufWinEnter', {callback =
        function()
            if vim.b.vimrc__folds_opened == nil then
                -- Use `vim.schedule` to make it run after other instances of
                -- BufWinEnter.
                vim.schedule(function()
                    if not vim.wo.diff and vim.b.term_title == nil then
                        vim.cmd [[normal! zR]]
                    end
                end)

                vim.b.vimrc__folds_opened = true
            end
        end,
    }},
})

-- Customize <c-l> refresh.
util.map('n', '<c-l>', '<cmd>IndentBlanklineRefresh<cr><c-l>')

-- Yank the results of a command.
util.user_command(
    'YankCommand',
    function(args)
        local old_more = vim.o.more
        vim.o.more = false

        vim.cmd [[redir @"]]
        vim.cmd(args.args)
        vim.cmd [[redir END]]

        vim.o.more = old_more
    end,
    {nargs = 1, complete = 'command'}
)

-- Unmap keys I don't want to use anymore/might map to something else in the future.
local function dont_use_this_key(key)
    util.log_error(string.format([[Don't use %s!]], key))
end
util.map('x', 's', function() dont_use_this_key('s') end)
util.map('n', 'S', function() dont_use_this_key('S') end)
util.map({'n', 'x'}, 'x', function() dont_use_this_key('x') end)
util.map({'n', 'x'}, 'X', function() dont_use_this_key('X') end)

-- Configure tab size.
util.user_command(
    'SetTabSize',
    function(args)
        local tab_size = tonumber(args.args)

        vim.opt_local.tabstop = tab_size
        vim.opt_local.softtabstop = tab_size
        vim.opt_local.shiftwidth = tab_size
    end,
    {nargs = 1}
)
