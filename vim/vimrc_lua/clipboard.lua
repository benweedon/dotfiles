-- Inspired by https://github.com/christoomey/vim-system-copy.
--
-- Modified to be in Lua and to use the * register rather than command line
-- tools. This should (hopefully) make it more cross-platform and not require
-- me to install some paste.exe from the internet on all my Windows machines.

local M = {}

local util = require 'vimrc.util'

M.copy = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*y')
end)

M.paste = util.new_operator(function(motion)
    util.opfunc_normal_command(motion, '"*p')
end)

function M.paste_before()
    vim.cmd(string.format([[normal! "*%dP]], vim.v.count1))
end

function M.paste_after()
    vim.cmd(string.format([[normal! "*%dp]], vim.v.count1))
end

function M.paste_line()
    for _ = 1,vim.v.count1 do
        vim.cmd [[put *]]
    end
end

util.map({'n', 'x'}, 'cy', [[v:lua.require('vimrc.clipboard').copy()]], {expr = true})
util.map('n', 'cY', [[v:lua.require('vimrc.clipboard').copy() . '_']], {expr = true})
util.map({'n', 'x'}, 'cp', [[v:lua.require('vimrc.clipboard').paste()]], {expr = true})
util.map('n', 'cpP', [[<cmd>lua require('vimrc.clipboard').paste_before()<cr>]])
util.map('n', 'cpp', [[<cmd>lua require('vimrc.clipboard').paste_after()<cr>]])
util.map('n', 'cP', [[<cmd>lua require('vimrc.clipboard').paste_line()<cr>]])

return M
