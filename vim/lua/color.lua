local M = {}

local util = require 'util'

local HIGHLIGHTS = {
    NeoSolarized = {
        __StatuslinePrimaryNormal = {fg = '!StatusLine.bg', bg = '!Function.fg', gui = 'bold'},
        __StatuslineSecondaryNormal = {fg = '!Function.fg', bg = '!StatusLine.bg', gui = 'bold'},
        __StatuslinePrimaryInsert = {fg = '!StatusLine.bg', bg = '!Constant.fg', gui = 'bold'},
        __StatuslineSecondaryInsert = {fg = '!Constant.fg', bg = '!StatusLine.bg', gui = 'bold'},
        __StatuslinePrimaryVisual = {fg = '!StatusLine.bg', bg = '!Search.fg', gui = 'bold'},
        __StatuslineSecondaryVisual = {fg = '!Search.fg', bg = '!StatusLine.bg', gui = 'bold'},
        __StatuslinePrimaryReplace = {fg = '!StatusLine.bg', bg = '!IncSearch.fg', gui = 'bold'},
        __StatuslineSecondaryReplace = {fg = '!IncSearch.fg', bg = '!StatusLine.bg', gui = 'bold'},
    },
    gruvbox = {
        __StatuslinePrimaryNormal = {fg = '!StatusLine.fg', bg = '!GruvboxBlue.fg', gui = 'bold'},
        __StatuslineSecondaryNormal = {fg = '!GruvboxBlue.fg', bg = '!StatusLine.fg', gui = 'bold'},
        __StatuslinePrimaryInsert = {fg = '!StatusLine.fg', bg = '!GruvboxAqua.fg', gui = 'bold'},
        __StatuslineSecondaryInsert = {fg = '!GruvboxAqua.fg', bg = '!StatusLine.fg', gui = 'bold'},
        __StatuslinePrimaryVisual = {fg = '!StatusLine.fg', bg = '!GruvboxYellow.fg', gui = 'bold'},
        __StatuslineSecondaryVisual = {fg = '!GruvboxYellow.fg', bg = '!StatusLine.fg', gui = 'bold'},
        __StatuslinePrimaryReplace = {fg = '!StatusLine.fg', bg = '!GruvboxOrange.fg', gui = 'bold'},
        __StatuslineSecondaryReplace = {fg = '!GruvboxOrange.fg', bg = '!StatusLine.fg', gui = 'bold'},
    },
}

-- Define highlight groups based off of the current color scheme.
function M.set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(HIGHLIGHTS) do
        if name == colorscheme then
            for group, options in pairs(highlights) do
                M.create_highlight_group(group, options)
            end

            break
        end
    end
end

function M.color_from_group(group)
    local synId = vim.fn.synIDtrans(vim.fn.hlID(group))

    return {
        fg = vim.fn.synIDattr(synId, 'fg'),
        bg = vim.fn.synIDattr(synId, 'bg'),
    }
end

function M.color_from_group_specifier(color_string)
    local tokens = util.split(color_string, '.')
    local group = tokens[1]
    local specifier = tokens[2]

    return M.color_from_group(group)[specifier]
end

local function parse_color(color_string)
    if color_string:sub(1, 1) == '!' then
        return M.color_from_group_specifier(color_string:sub(2))
    else
        return color_string
    end
end

function M.create_highlight_group(name, options)
    local fg = options.fg and parse_color(options.fg) or ''
    local bg = options.bg and parse_color(options.bg) or ''
    local gui = options.gui and parse_color(options.gui) or ''

    local fg = fg == '' and fg or string.format('guifg=%s', fg)
    local bg = bg == '' and bg or string.format('guibg=%s', bg)
    local gui = gui == '' and gui or string.format('gui=%s', gui)

    vim.cmd(string.format('highlight %s %s %s %s', name, fg, bg, gui))
end

vim.cmd [[
    augroup statusline_highlight_groups
        autocmd!
        autocmd ColorScheme * lua require('color').set_highlight_groups()
    augroup end
]]

return M
