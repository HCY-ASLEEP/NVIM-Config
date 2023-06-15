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
		}, { upward = true })[1])
		local client = vim.lsp.start({
			name = "clangd",
			cmd = { "clangd" },
			root_dir = root_dir,
			capabilities = {
				textDocument = {
					completion = {
						editsNearCursor = true,
					},
				},
				offsetEncoding = { "utf-8", "utf-16" },
			},
		})
		vim.lsp.buf_attach_client(0, client)
	end,
	group = clangd_lsp,
})

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
		}, { upward = true })[1])
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
		vim.lsp.buf_attach_client(0, client)
	end,
	group = pyright_lsp,
})

local vimls_lsp = vim.api.nvim_create_augroup("vimls_lsp", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "vim" },
	callback = function()
		local root_dir = vim.fs.dirname(vim.fs.find({
			".git",
		}, { upward = true })[1])
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
		vim.lsp.buf_attach_client(0, client)
	end,
	group = vimls_lsp,
})

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
		}, { upward = true })[1])
		local client = vim.lsp.start({
			name = "luals",
			cmd = { "lua-language-server" },
			root_dir = root_dir,
			settings = { Lua = { telemetry = { enable = false } } },
		})
		vim.lsp.buf_attach_client(0, client)
	end,
	group = luals_lsp,
})

vim.api.nvim_command("highlight NormalFloat ctermbg=darkgray")

vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.vim.lsp.omnifunc")

vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { noremap = true, silent = true })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { noremap = true, silent = true })
vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, { noremap = true, silent = true })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { noremap = true, silent = true })
vim.keymap.set("n", "<space>r", vim.lsp.buf.rename, { noremap = true, silent = true })
vim.keymap.set("n", "<space>a", vim.diagnostic.setloclist, { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { noremap = true, silent = true })
vim.keymap.set("n", "<C-up>", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "<C-down>", vim.diagnostic.goto_next, { noremap = true, silent = true })