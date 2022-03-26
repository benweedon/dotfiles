local M = {}

local util = require 'vimrc.util'

local namespace = vim.api.nvim_create_namespace('misc')

-- Fix the closest previous spelling mistake.
function M.fix_previous_spelling_mistake(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__fix_previous_spelling_mistake_opfunc'
        return 'g@l'
    end

    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and choose the first suggestion.
    vim.cmd 'silent normal! [s1z='

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end

function M.mark_previous_spelling_mistake_good(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__mark_previous_spelling_mistake_good_opfunc'
        return 'g@l'
    end

    local extmark = util.get_extmark_from_cursor(namespace)

    -- Go back to the previous spelling mistake and mark it as good.
    vim.cmd 'silent normal! [szg'

    -- Return to our previous position.
    util.set_cursor_from_extmark(extmark, namespace)
    vim.api.nvim_buf_del_extmark(0 --[[buffer]], namespace, extmark)
end

vim.cmd [[
    function! __misc__fix_previous_spelling_mistake_opfunc(motion) abort
        return v:lua.require('vimrc.misc').fix_previous_spelling_mistake(a:motion)
    endfunction
    function! __misc__mark_previous_spelling_mistake_good_opfunc(motion) abort
        return v:lua.require('vimrc.misc').mark_previous_spelling_mistake_good(a:motion)
    endfunction
]]

util.map('n', '<leader>z=', [[v:lua.require('vimrc.misc').fix_previous_spelling_mistake()]], {expr = true})
util.map('n', '<leader>zg', [[v:lua.require('vimrc.misc').mark_previous_spelling_mistake_good()]], {expr = true})

-- Highlight word under cursor.
local cursor_highlight_match_id = nil
function M.highlight_word_under_cursor()
    if cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(cursor_highlight_match_id)
    end

    local word = vim.fn.expand('<cword>')
    local pattern = string.format([[\V\<%s\>]], word)

    cursor_highlight_match_id = vim.fn.matchadd('__CursorOver', pattern)
end

function M.clear_cursor_highlight()
    if cursor_highlight_match_id ~= nil then
        vim.fn.matchdelete(cursor_highlight_match_id)
        cursor_highlight_match_id = nil
    end
end

vim.cmd [[
    augroup highlight_word_under_cursor
        autocmd!
        autocmd CursorMoved * lua require('vimrc.misc').highlight_word_under_cursor()
        autocmd CursorMovedI * lua require('vimrc.misc').highlight_word_under_cursor()
        autocmd WinLeave * lua require('vimrc.misc').clear_cursor_highlight()
    augroup end
]]

-- Center mode.
local in_center_mode
function M.enable_center_mode()
    vim.cmd [[
        augroup center_mode
            autocmd!
            autocmd CursorMoved * normal! zz
        augroup end
    ]]
    vim.cmd [[normal! zz]]

    in_center_mode = true
end

function M.disable_center_mode()
    -- Do this check since the below autocmd will fail if the group doesn't exist.
    if in_center_mode then
        vim.cmd [[autocmd! center_mode]]
    end

    in_center_mode = false
end

-- This is the default setting.
M.disable_center_mode()

function M.toggle_center_mode(motion)
    if motion == nil then
        vim.opt.opfunc = '__misc__toggle_center_mode_opfunc'
        return 'g@l'
    end

    if in_center_mode then
        M.disable_center_mode()
    else
        M.enable_center_mode()
    end
end

vim.cmd [[
    function! __misc__toggle_center_mode_opfunc(motion) abort
        return v:lua.require('vimrc.misc').toggle_center_mode(a:motion)
    endfunction
]]

util.map('n', 'cm', [[v:lua.require('vimrc.misc').toggle_center_mode()]], {expr = true})

return M
