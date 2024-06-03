local vim = vim

if vim.fn.executable("clangd") == 1 then
    local clangd_lsp = vim.api.nvim_create_augroup("clangd_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        callback = function()
            local root_dir = vim.fs.dirname(vim.fs.find({
                ".clangd",
                ".clang-tidy",
                ".clang-format",
                "compile_commands.json",
                "compile_flags.txt",
                "configure.ac",
                ".git",
            }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1])
            local client = vim.lsp.start({
                name = "clangd",
                cmd = { "clangd" },
                root_dir = root_dir,
                single_file_support = true,
                capabilities = {
                    textDocument = {
                        completion = {
                            editsNearCursor = true,
                        },
                    },
                    offsetEncoding = { "utf-8", "utf-16" },
                },
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = clangd_lsp,
    })
end

if vim.fn.executable("pyright-langserver") == 1 then
    local pyright_lsp = vim.api.nvim_create_augroup("pyright_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
            local root_dir = vim.fs.dirname(vim.fs.find({
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                "pyrightconfig.json",
                ".git",
            }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1])
            local client = vim.lsp.start({
                name = "pyright",
                cmd = { "pyright-langserver", "--stdio" },
                root_dir = root_dir,
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        },
                    },
                },
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = pyright_lsp,
    })
end

if vim.fn.executable("vim-language-server") == 1 then
    local vimls_lsp = vim.api.nvim_create_augroup("vimls_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "vim" },
        callback = function()
            local root_dir = vim.fs.dirname(vim.fs.find({
                ".git",
            }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1])
            local client = vim.lsp.start({
                name = "vimls",
                cmd = { "vim-language-server", "--stdio" },
                root_dir = root_dir,
                init_options = {
                    isNeovim = true,
                    iskeyword = "@,48-57,_,192-255,-#",
                    vimruntime = "",
                    runtimepath = "",
                    diagnostic = { enable = true },
                    indexes = {
                        runtimepath = true,
                        gap = 100,
                        count = 3,
                        projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
                    },
                    suggest = { fromVimruntime = true, fromRuntimepath = true },
                },
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = vimls_lsp,
    })
end

if vim.fn.executable("lua-language-server") == 1 then
    local luals_lsp = vim.api.nvim_create_augroup("luals_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua" },
        callback = function()
            local root_dir = vim.fs.dirname(vim.fs.find({
                ".luarc.json",
                ".luarc.jsonc",
                ".luacheckrc",
                ".stylua.toml",
                "stylua.toml",
                "selene.toml",
                "selene.yml",
                ".git",
            }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1])
            local client = vim.lsp.start({
                name = "luals",
                cmd = { "lua-language-server" },
                root_dir = root_dir,
                settings = { Lua = { telemetry = { enable = false } } },
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = luals_lsp,
    })
end

if vim.fn.executable("gopls") == 1 then
    local golang_lsp = vim.api.nvim_create_augroup("golang_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "gomod", "gowork", "gotmpl" },
        callback = function()
            local root_dir = vim.fs.dirname(vim.fs.find({
                "go.work",
                "go.mod",
                ".git",
            }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1])
            local client = vim.lsp.start({
                name = "gopls",
                cmd = { "gopls" },
                root_dir = root_dir,
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = golang_lsp,
    })
end

vim.api.nvim_command("highlight NormalFloat ctermbg=darkgray")

vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.vim.lsp.omnifunc")

vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { noremap = true, silent = true })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { noremap = true, silent = true })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { noremap = true, silent = true })
vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { noremap = true, silent = true })
vim.keymap.set("n", "<space>r", vim.lsp.buf.rename, { noremap = true, silent = true })
vim.keymap.set("n", "<space>d", vim.diagnostic.open_float, { noremap =true, silent =true })
vim.keymap.set("n", "<space>a", vim.diagnostic.setloclist, { noremap = true, silent = true })
vim.keymap.set("n", "<C-up>", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "<C-down>", vim.diagnostic.goto_next, { noremap = true, silent = true })

-- symbol_outline
require("lsp.symbol-outline-preload")
local symbol_outline_nested = require("lsp.symbol-outline-nested")
local symbol_outline_sorted = require("lsp.symbol-outline-sorted")
vim.keymap.set("n", "gs", function()
    symbol_outline_nested.open(0)
end, { noremap = true, silent = true })
vim.api.nvim_create_user_command("OpenSymbolOutlineNested", function()
    symbol_outline_nested.open(0)
end, {})
vim.api.nvim_create_user_command("OpenSymbolOutlineSorted", function()
    symbol_outline_sorted.open(0)
end, {})

--log_file = io.open("/home/devenv/.config/nvim/log.log", "a")
--
--function log(message)
--	local timestamp = os.date("%Y-%m-%d %H:%M:%S") -- 获取当前时间戳
--	local log_message = string.format("[%s] %s", timestamp, message) -- 格式化日志消息
--	log_file:write(log_message .. "\n") -- 写入日志文件
--	log_file:flush() -- 刷新文件缓冲区
--end

vim.lsp.inlay_hint.enable()
-- Decorate floating windows
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = 'rounded' }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = 'rounded' }
)

vim.diagnostic.config({     
    float = { border = "rounded" },
    virtual_text = false,
    underline = true
})
