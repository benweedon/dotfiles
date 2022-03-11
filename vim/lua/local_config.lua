local M = {}

local TRUST_DIR = string.format('%s/local_config', vim.fn.stdpath('data'))
local TRUST_FILE = string.format('%s/trust.json', TRUST_DIR)

local FILE_MODE = 0b111111111 -- octal 777

local CONFIG_ENV = {}

_G.LOCAL_CONFIG = nil
_G.LOADED_CONFIGS = nil

local function file_exists(file_name)
    local s = vim.loop.fs_stat(file_name)
    return s ~= nil and s.type == 'file'
end

local function directory_exists(file_name)
    local s = vim.loop.fs_stat(file_name)
    return s ~= nil and s.type == 'directory'
end

local function ensure_trust_file()
    if not directory_exists(TRUST_DIR) then
        assert(vim.loop.fs_mkdir(TRUST_DIR, FILE_MODE))
    end

    if not file_exists(TRUST_FILE) then
        local f = assert(io.open(TRUST_FILE, 'w'))
        assert(f:write('{}'))
        f:close()
    end
end

local function read_file(file_name)
    local f = assert(io.open(file_name))
    local contents = assert(f:read('*a'))
    f:close()

    return contents
end

local function read_trust_file()
    ensure_trust_file()
    local contents = read_file(TRUST_FILE)
    return vim.json.decode(contents)
end

local function write_trust_file(o)
    ensure_trust_file()
    local f = assert(io.open(TRUST_FILE, 'w'))
    assert(f:write(vim.json.encode(o)))
    f:close()
end

local function trust(config)
    local o = read_trust_file()

    if not o[config] then
        local contents = read_file(config)
        o[config] = {is_trusted = true, checksum = vim.fn.sha256(contents)}

        write_trust_file(o)
    end
end

local function distrust(config)
    local o = read_trust_file()

    if not o[config] then
        o[config] = {is_trusted = false}
        write_trust_file(o)
    end
end

local function is_trusted(config)
    local o = read_trust_file()
    if not o[config] or not o[config].is_trusted then
        return false
    end

    local current_checksum = vim.fn.sha256(read_file(config))
    if current_checksum ~= o[config].checksum then
        -- The checksums don't match anymore. Remove the object from the file
        -- and return false.
        o[config] = nil
        write_trust_file(o)

        return false
    end

    return true
end

local function is_untrusted(config)
    local o = read_trust_file()
    return o[config] and not o[config].is_trusted
end

-- Currently only one config per directory is supported.
local function add_configs_for_dir(dir, configs)
    local file_name = string.format('%s/nvim_local.lua', dir)
    local f = io.open(file_name)
    if f then
        f:close()
        table.insert(configs, file_name)
    end
end

local function remove_untrusted_configs(configs)
    local final_configs = {}

    for _, config in ipairs(configs) do
        if is_trusted(config) then
            table.insert(final_configs, config)
        elseif not is_untrusted(config) then
            local choice = vim.fn.confirm(config, '&Ignore for now\n&Trust\n&Distrust', 1)
            if choice == 2 then
                trust(config)
                table.insert(final_configs, config)
            elseif choice == 3 then
                distrust(config)
            end
        end
    end

    return final_configs
end

local function find_local_configs()
    local configs = {}

    local prev_dir = nil
    local dir = vim.fn.getcwd()
    while prev_dir ~= dir do
        add_configs_for_dir(dir, configs)

        prev_dir = dir
        dir = vim.fn.fnamemodify(dir, ':h')
    end

    return remove_untrusted_configs(configs)
end

function M.load_configs()
    if _G.LOCAL_CONFIG ~= nil then
        return
    end

    local result = {}

    -- More deeply nested configs come first in the list. Handle those last so
    -- they have the opportunity to override anything.
    local configs = find_local_configs()
    for i = #configs,1,-1 do
        local f = assert(loadfile(configs[i]))

        -- Restrict what the local config script has access to.
        setfenv(f, CONFIG_ENV)

        result = vim.tbl_extend('force', result, f())
    end

    _G.LOADED_CONFIGS = configs
    _G.LOCAL_CONFIG = result
end

return M
