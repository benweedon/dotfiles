local M = {}

local util = require 'util'

local instances = {}

local function create_instance(win, buf)
    local instance = {
        win = win,
        buf = buf,
        node = {
            name = '_G',
            tbl = _G,
            parent = nil,
            cursor = {1, 0},
        },
        lines = {},
    }

    instances[win] = instance
    return instance
end

local function create_child_node(parent, name, tbl)
    return {
        name = string.format('%s.%s', parent.name, name),
        tbl = tbl,
        parent = parent,
        cursor = {1, 0},
    }
end

local function query_instance(win)
    local win = win or vim.api.nvim_get_current_win()
    return instances[win]
end

local function clear_instance(instance)
    instances[instance.win] = nil
end

local function escape(s)
    return s:gsub('\n', '\\n')
end

local function key_to_string(key)
    return escape(tostring(key))
end

local function value_to_string(value)
    local t = type(value)

    local s
    if t == 'string' then
        s = string.format('%q', value)
    elseif t == 'number' then
        s = string.format('%g', value)
    elseif t == 'boolean' then
        s = string.format('%s', value)
    elseif t == 'function' or t == 'table' then
        s = string.format('<%s>', value)
    elseif t == 'userdata' then
        s = string.format('%s (userdata)', value)
    else
        error(string.format('Unsupported type: %s', t))
    end

    return escape(s)
end

local function create_line(o, max_key_length)
    local spaces = string.rep(' ', max_key_length - o.key_string:len())
    return string.format('%s%s = %s', o.key_string, spaces, value_to_string(o.value))
end

local function search_help(key)
    if type(key) == 'string' then
        local result, msg = pcall(function() vim.cmd(string.format('help %s', key)) end)
        if not result then
            local msg = msg:gsub('^.+:[0-9]+: Vim%(help%):', '')
            vim.api.nvim_err_writeln(msg)
        end
    else
        vim.api.nvim_err_writeln(string.format('No help for item: %s', key))
    end
end

local function render(instance)
    -- Temporarily allow us to modify the buffer.
    vim.api.nvim_buf_set_option(instance.buf, 'modifiable', true)

    local node = instance.node

    -- Get a list of fields sorted by key.
    local max_key_length = 0
    local sorted_lines = {}
    for key, value in pairs(node.tbl) do
        local key_string = key_to_string(key)
        max_key_length = math.max(max_key_length, key_string:len())
        table.insert(sorted_lines, {key = key, value = value, key_string = key_string})
    end
    table.sort(sorted_lines, function(a, b) return a.key_string < b.key_string end)

    local lines = {}
    instance.lines = {}

    -- First display the name of the current table.
    table.insert(lines, string.format('=== %s ===', node.name))
    table.insert(instance.lines, {ignore = true})

    -- Then create the line for navigating up a level.
    if node.parent ~= nil then
        table.insert(lines, string.format('🠕 [%s]', node.parent.name))
        table.insert(instance.lines, {up = true})
    end

    -- Next display the metatable if available.
    local node_metatable = getmetatable(node.tbl)
    if node_metatable and not vim.tbl_isempty(node_metatable) then
        table.insert(lines, '{{metatable}}')
        table.insert(instance.lines, {metatable = true})
    end

    -- Finally create a blank line.
    table.insert(lines, '')
    table.insert(instance.lines, {ignore = true})

    -- Generate a line for each field.
    for _, o in ipairs(sorted_lines) do
        table.insert(lines, create_line(o, max_key_length))
        table.insert(instance.lines, {key = o.key, value = o.value})
    end

    vim.api.nvim_buf_set_lines(instance.buf, 0, -1, true --[[strict_indexing]], lines)

    -- Set the cursor to its last position in the node.
    vim.api.nvim_win_set_cursor(instance.win, instance.node.cursor)

    -- Make the buffer non-modifiable again.
    vim.api.nvim_buf_set_option(instance.buf, 'modifiable', false)
end

local function set_mappings(buf)
    local mappings = {
        q = 'close()',
        ['<cr>'] = 'nav_to()',
        ['u'] = 'nav_up()',
    }

    for lhs, rhs in pairs(mappings) do
        util.bufnr_map(
            buf,
            'n',
            lhs,
            ':lua require("api_explorer").' .. rhs .. '<cr>',
            {nowait = true})
    end
end

function M.open()
    vim.cmd 'vertical split'
    local win = vim.api.nvim_get_current_win()

    local buf = vim.api.nvim_create_buf(false --[[listed]], true --[[scratch]])
    vim.api.nvim_win_set_buf(win, buf)

    vim.api.nvim_buf_set_name(buf, string.format('Api Explorer [%d]', buf))

    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'api_explorer')

    vim.api.nvim_win_set_option(win, 'spell', false)
    vim.api.nvim_win_set_option(win, 'wrap', false)

    local instance = create_instance(win, buf)

    render(instance)

    vim.cmd(string.format('buffer %d', buf))

    set_mappings(buf)
end

function M.close(win)
    local instance = query_instance(win)
    if instance == nil then
        return
    end

    clear_instance(instance)

    if instance.win and vim.api.nvim_win_is_valid(instance.win) then
        vim.api.nvim_win_close(instance.win, true --[[force]])
    end
end

local function nav_down(instance, child_name, child_tbl)
    instance.node.cursor = vim.api.nvim_win_get_cursor(instance.win)
    instance.node = create_child_node(instance.node, child_name, child_tbl)
    render(instance)
end

function M.nav_to()
    local instance = query_instance()

    local cursor = vim.api.nvim_win_get_cursor(instance.win)
    local line = instance.lines[cursor[1]]

    if line.ignore then
        return
    elseif line.up then
        M.nav_up(instance)
    elseif line.metatable then
        nav_down(instance, '{{metatable}}', getmetatable(instance.node.tbl))
    else
        local key = line.key
        local child_tbl = instance.node.tbl[key]
        if type(child_tbl) == 'table' then
            nav_down(instance, key, child_tbl)
        else
            search_help(key)
        end
    end
end

function M.nav_up(instance)
    local instance = instance or query_instance()
    if instance.node.parent == nil then
        vim.api.nvim_err_writeln('Already at top level.')
    else
        instance.node = instance.node.parent
        render(instance)
    end
end

vim.cmd 'command! -nargs=0 ApiExplorer lua require("api_explorer").open()'

vim.cmd [[
    augroup api_explorer
        autocmd!
        autocmd WinClosed * lua require("api_explorer").close(tonumber(vim.fn.expand("<amatch>")))
    augroup end
]]

return M