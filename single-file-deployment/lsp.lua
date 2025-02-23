-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
        'neoclide/coc.nvim',
        branch = 'release'
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.cmd([[
    highlight! link CocInlayHint LineNr
]])


-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"

local keyset = vim.keymap.set
-- Autocomplete
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

local function caa(action)
    return function () vim.fn.CocActionAsync(action) end
end

local g_prefix_dict = {}
local function g_prefix()
    vim.api.nvim_echo({{"Waiting for next key after g ... "}}, false, {})
    local key = vim.fn.nr2char(vim.fn.getchar())
    vim.cmd("redraw")
    vim.api.nvim_echo({{"Pressed 'g" .. key .. "'"}}, false, {})
    local func = g_prefix_dict[key]
    if func ~= nil then
        func()
    else
        vim.api.nvim_feedkeys("g" .. key, "n", false)
    end
end
local opt = { buffer = 0, noremap = true, silent = true }
vim.keymap.set("n", "g", g_prefix, opt)
vim.keymap.set("x", "g", g_prefix, opt)

g_prefix_dict["E"] = function () vim.cmd.CocList('extensions') end
g_prefix_dict["A"] = function () vim.fn.CocActionAsync('codeAction', 'cursor') end
g_prefix_dict["a"] = vim.cmd.CocDiagnostics     -- [a]ll errors and warnings
g_prefix_dict["h"] = caa('doHover')             -- [h]over
g_prefix_dict["D"] = caa('jumpDeclaration')     -- [D]eclaration
g_prefix_dict["d"] = caa('jumpDefinition')      -- [d]efinition
g_prefix_dict["i"] = caa('jumpImplementation')  -- [i]mplementation
g_prefix_dict["r"] = caa('jumpReferences')      -- [r]eferences
g_prefix_dict["t"] = caa('jumpTypeDefinition')  -- [t]ype_definition
g_prefix_dict["R"] = caa('rename')              -- [R]ename

g_prefix_dict["f"] = function () vim.fn.CocActionAsync('formatSelected', vim.fn.visualmode()) end

-- Add `:Format` command to format current buffer
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})
