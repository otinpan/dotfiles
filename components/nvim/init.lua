vim.g.mapleader = " "
vim.g.maplocalleader = " "

--init.lua
-- ensure the `lua` directory is included to package.path
package.path = "./lua/?.lua;" .. package.path
local util = require("utils")

-- Filter a noisy nvim-lspconfig deprecation notice (Nvim 0.10 and older).
do
    local orig_notify = vim.notify
    vim.notify = function(msg, ...)
        if type(msg) == "string"
            and msg:match("nvim%-lspconfig support for Nvim 0%.10 or older is deprecated") then
            return
        end
        return orig_notify(msg, ...)
    end
end
-- ------------------------------------------------------------
--  key BIND
-- ------------------------------------------------------------
-- Normal Mode
--^M is <S-CR> or <C-CR>. but it depends on your system.
--please check with ctrl+v in insert mode.
util.map("n", "<C-n>", ":nohl<Cr>")
util.map("n", "<C-h>", ":bprev<Cr>")
util.map("n", "<C-l>", ":bnext<Cr>")
util.map("n", "<C-q>", ":bdelete!<Cr>")
util.map("n", "j", "gj")
util.map("n", "k", "gk")
-- Insert Mode
util.map("i", "jj", "<Esc>")
-- Insert Mode movekey bind
util.map("i", "<C-d>", "<BS>")
util.map("i", "<C-h>", "<Left>")
util.map("i", "<C-l>", "<Right>")
util.map("i", "<C-k>", "<Up>")
--util.map("i", "<C-j>", "<Down>")

util.map("n", "J", "<C-d>")
util.map("n", "K", "<C-u>")
-- ------------------------------------------------------------
-- editor setting
-- ------------------------------------------------------------

-- Nvim Options
local options = {
    -- Editor
    encoding = "utf-8",
    fileencoding = "utf-8",
    title = true,
    backup = false, --or you can set backupdir where backup files are saved
    swapfile = false,
    shell = "zsh",
    backupskip = { "/tmp/*" },
    clipboard = "unnamedplus", -- copy yank on clipboard
    number = true, -- don't show line numbers
    relativenumber = false, -- but show relative line numbers
    autoindent = true, -- auto indent when newline
    smartindent = true,
    splitright = false, -- split screen to the right
    splitbelow = false, -- split screen to the below
    scrolloff = 999,
    showmatch = true, -- closing parenthesis, show correspond one for a moment
    smartcase = true,
    -- tab
    shiftwidth = 2, -- num of spaces when auto indent
    expandtab = true, -- tab input is spaces
    -- undo
    undodir = vim.fn.stdpath("cache") .. "/undo",
    undofile = true,
    -- folding settings
    foldmethod = "syntax",
    foldlevel = 8,
    -- invalid characters settings
    list = true,
    listchars = "tab:>,-,trail:.",
    -- Visual
    pumheight = 10,
    termguicolors = true,
    cursorline = true,
    timeout = true,
    timeoutlen = 500,
}
vim.opt.shortmess:append("c")
for k, v in pairs(options) do
    vim.opt[k] = v
end
--vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]]) -- include '-' as a part of a word. e.g word-with-hyphen

-- ------------------------------------------------------------
-- functionalities
-- ------------------------------------------------------------
--function s:ShowMaps()
--  let old_reg = getreg(--a")          " save the current content of register a
--  let old_reg_type = getregtype(--a") " save the type of the register as well
--try
--  redir @a                           -- redirect output to register a
--  -- Get the list of all key mappings silently, satisfy "Press ENTER to continue"
--  silent map | call feedkeys(--\<CR>")
--  redir END                          -- end output redirection
--  vnew                               -- new buffer in vertical window
--  put a                              -- put content of register
--  -- Sort on 4th character column which is the key(s)
--  %!sort -k1.4,1.4
--finally                              -- Execute even if exception is raised
--  call setreg(--a", old_reg, old_reg_type) " restore register a
--endtry
--endfunction
--com! ShowMaps call s:ShowMaps()      -- Enable :ShowMaps to call the function

-- Additional clipboard settings for WSL: Use system clipboard / WSL fix
if vim.fn.has('wsl') == 1 then
    vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
        },
        paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
    }
end
-- ------------------------------------------------------------
-- visual
-- ------------------------------------------------------------

vim.cmd([[
try
  colorscheme vscode
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]])

if not pcall(require, "plugins") then
    print("Loading plugins.lua failed")
else
    require("git")
    require("finder")
    require("lsp")
    require("formatter")
    require("completion")
    require("filetype")
    require("increment")
    require("tex")
end
