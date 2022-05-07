local M = {}

local util = require 'vimrc.util'

local HIGHLIGHTS = {
    NeoSolarized = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!Constant.foreground',
        visual_accent = '!Search.foreground',
        replace_accent = '!IncSearch.foreground',
    },
    gruvbox = {
        base = '!StatusLine.foreground',
        normal_accent = '!GruvboxBlue.foreground',
        insert_accent = '!GruvboxAqua.foreground',
        visual_accent = '!GruvboxYellow.foreground',
        replace_accent = '!GruvboxOrange.foreground',
    },
    molokai = {
        base = '!StatusLine.foreground',
        normal_accent = '!Type.foreground',
        insert_accent = '!Function.foreground',
        visual_accent = '!String.foreground',
        replace_accent = '!Operator.foreground',
    },
    onedark = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!Type.foreground',
        replace_accent = '!Identifier.foreground',
    },
    PaperColor = {
        base = '!StatusLine.background',
        normal_accent = '!Operator.foreground',
        insert_accent = '!Include.foreground',
        visual_accent = '!String.foreground',
        replace_accent = '!Constant.foreground',
    },
    nord = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!SpecialChar.foreground',
        replace_accent = '!Number.foreground',
    },
    iceberg = {
        base = '!TabLine.foreground',
        normal_accent = '!Function.foreground',
        insert_accent = '!Special.foreground',
        visual_accent = '!Title.foreground',
        replace_accent = '!Constant.foreground',
    },
    one = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!Number.foreground',
        replace_accent = '!Identifier.foreground',
    },
    OceanicNext = {
        base = '!StatusLine.foreground',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!Label.foreground',
        replace_accent = '!Statement.foreground',
    },
    palenight = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!Type.foreground',
        replace_accent = '!Identifier.foreground',
    },
    onehalfdark = {
        base = '!StatusLine.background',
        normal_accent = '!Function.foreground',
        insert_accent = '!String.foreground',
        visual_accent = '!Type.foreground',
        replace_accent = '!Identifier.foreground',
    },
}

local function color_from_group(group)
    return vim.api.nvim_get_hl_by_name(group, true --[[rgb]])
end

local function color_from_group_specifier(color_string)
    local tokens = vim.split(color_string, '.', {plain = true})
    local group = tokens[1]
    local specifier = tokens[2]

    return color_from_group(group)[specifier]
end

local function parse_color(color_string)
    if color_string:sub(1, 1) == '!' then
        return color_from_group_specifier(color_string:sub(2))
    else
        return color_string
    end
end

local function expand_color_options(options)
    options.foreground = options.foreground and parse_color(options.foreground)
    options.background = options.background and parse_color(options.background)
    options.special = options.special and parse_color(options.special)
end

local function create_highlight_group(name, options)
    local options = vim.deepcopy(options)
    expand_color_options(options)

    -- If we have no settings to apply, don't create the highlight group.
    if vim.tbl_isempty(vim.tbl_keys(options)) then
        return
    end

    vim.api.nvim_set_hl(0 --[[namespace]], name, options)
end

local function create_statusline_highlight(mode, base, accent)
    local primary_group = string.format('vimrc__StatuslinePrimary%s', mode)
    create_highlight_group(primary_group, {foreground = base, background = accent, bold = true})

    local secondary_group = string.format('vimrc__StatuslineSecondary%s', mode)
    create_highlight_group(secondary_group, {foreground = accent, background = base})
end

local function create_statusline_highlights(highlights)
    create_statusline_highlight('Normal', highlights.base, highlights.normal_accent)
    create_statusline_highlight('Insert', highlights.base, highlights.insert_accent)
    create_statusline_highlight('Visual', highlights.base, highlights.visual_accent)
    create_statusline_highlight('Replace', highlights.base, highlights.replace_accent)
end

local function create_cursor_over_highlight(highlights)
    local color
    if highlights.cursor_over then
        if type(highlights.cursor_over) == 'string' then
            color = color_from_group(highlights.cursor_over)
        else
            color = highlights.cursor_over
        end
    else
        color = {background = '!TabLine.background', bold = true}
    end

    create_highlight_group('vimrc__CursorOver', color)
end

-- Define highlight groups based off of the current color scheme.
local function set_highlight_groups()
    local colorscheme = vim.g.colors_name
    for name, highlights in pairs(HIGHLIGHTS) do
        if name == colorscheme then
            create_statusline_highlights(highlights)
            create_cursor_over_highlight(highlights)
            break
        end
    end
end

function M.on_colorscheme_loaded()
    vim.opt.termguicolors = true
    vim.opt.background = 'dark'

    vim.cmd [[colorscheme PaperColor]]
end

util.augroup('vimrc__statusline_highlight_groups', {
    {'ColorScheme', {callback = set_highlight_groups}},
})

util.user_command('HiTest', 'source $VIMRUNTIME/syntax/hitest.vim', {nargs = 0})
util.user_command(
    'SynStack',
    function()
        local stack = vim.fn.synstack(vim.fn.line '.', vim.fn.col '.')
        local mapped = vim.tbl_map(
            function(item)
                local from_name = vim.fn.synIDattr(item, 'name')
                local to_name = vim.fn.synIDattr(vim.fn.synIDtrans(item), 'name')
                return string.format('%s -> %s', from_name, to_name), true --[[add_to_history]]
            end,
            stack
        )
        util.echo(vim.inspect(mapped), true --[[add_to_history]])
    end,
    {nargs = 0}
)

return M
