-- +-----------------------------------------------+
-- |                                               |
-- |         LANGUAGE SERVER CONFIGURATION         |
-- |                                               |
-- +-----------------------------------------------+


local vim = vim

if vim.fn.executable("/root/ccls/Release/ccls") == 1 then
    local clangd_lsp = vim.api.nvim_create_augroup("ccls", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        callback = function()
            local root_dir = vim.fs.root(0, {'compile_commands.json', '.ccls', '.git'})
            local client = vim.lsp.start({
                name = "ccls",
                cmd = { "/root/ccls/Release/ccls" },
                root_dir = root_dir,
                single_file_support = false,
                offset_encoding = 'utf-32'
            })
            -- vim.lsp.buf_attach_client(0, client)
        end,
        group = ccls,
    })
end

-- if vim.fn.executable("clangd") == 1 then
--     local clangd_lsp = vim.api.nvim_create_augroup("clangd_lsp", { clear = true })
--     vim.api.nvim_create_autocmd("FileType", {
--         pattern = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
--         callback = function()
--             local root_dir = vim.fs.root(0, {
--                 ".clangd",
--                 ".clang-tidy",
--                 ".clang-format",
--                 "compile_commands.json",
--                 "compile_flags.txt",
--                 "configure.ac",
--                 ".git"
--             })
--             local client = vim.lsp.start({
--                 name = "clangd",
--                 cmd = { "clangd" },
--                 root_dir = root_dir,
--                 single_file_support = true,
--                 capabilities = {
--                     textDocument = {
--                         completion = {
--                             editsNearCursor = true,
--                         },
--                     },
--                     offsetEncoding = { "utf-8", "utf-16" },
--                 },
--             })
--             -- vim.lsp.buf_attach_client(0, client)
--         end,
--         group = clangd_lsp,
--     })
-- end

if vim.fn.executable("pyright-langserver") == 1 then
    local pyright_lsp = vim.api.nvim_create_augroup("pyright_lsp", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python" },
        callback = function()
            local root_dir = vim.fs.root(0, {
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                "pyrightconfig.json",
                ".git",
            })
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
            local root_dir = vim.fs.root(0, {
                ".git",
            })
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
            local root_dir = vim.fs.root(0, {
                ".luarc.json",
                ".luarc.jsonc",
                ".luacheckrc",
                ".stylua.toml",
                "stylua.toml",
                "selene.toml",
                "selene.yml",
                ".git",
            })
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
            local root_dir = vim.fs.root(0, {
                "go.work",
                "go.mod",
                ".git",
            })
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
vim.keymap.set("n", "ge", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set("n", "<space>r", vim.lsp.buf.rename, { noremap = true, silent = true })
vim.keymap.set("n", "<space>a", vim.diagnostic.setloclist, { noremap = true, silent = true })
vim.keymap.set("n", "<C-up>", vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set("n", "<C-down>", vim.diagnostic.goto_next, { noremap = true, silent = true })

vim.lsp.inlay_hint.enable()
-- Decorate floating windows
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

vim.diagnostic.config({
    float = { border = "rounded" },
    virtual_text = false,
    underline = true,
})


vim.cmd("hi! link NormalFloat Normal")
vim.cmd("hi! link FloatBorder MoreMsg")

local function CursorHoldLSPHoverWithDelay()
    -- 创建一个新的 augroup
    vim.api.nvim_create_augroup("CursorHoldLSPHover", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function()
            -- 创建 autocmd，当光标停留时触发，仅在当前缓冲区内
            vim.api.nvim_create_autocmd("CursorHold", {
    	        group = "CursorHoldLSPHover",  -- 关联到刚创建的 augroup
                buffer = 0,  -- 只在当前缓冲区中生效
                callback = function()
                    -- 延迟 1000 毫秒（1 秒）执行操作
                    vim.defer_fn(function() vim.lsp.buf.hover() end, 1000)
                    -- 延迟时间为 1000 毫秒
                end,
            })
        end
    })
end


-- +-----------------------------------------------+
-- |                                               |
-- |     SYMBOL OUTLINE NESTED AND SORTED VIEW     |
-- |                                               |
-- +-----------------------------------------------+


local SYMBOL_OUTLINE = {}

-- parsed raw symbol content
local symbol_infos = {}

-- symbol position under the cursor of the source file
-- at the moment before opening the symbol outline
local source_open_row = -1

-- the final content to be written to the buffer
local presentings = {}

-- the length of each string element in each line of
-- the final content to be written into the buffer
local presentings_item_lens = {}

local outline_type = ""

local presentings_line_kinds = {}

local jump_positions = {}

-- refresh signal
local is_refresh = false

-- store the symbol outline win handle needed to be refreshed
local refresh_outline_win = -1

-- store the symbol outline buf handle needed to be refreshed
local refresh_outline_buf = -1

-- symbol kind names
local kind_names = {
    "File",
    "Module",
    "Namespace",
    "Package",
    "Class",
    "Method",
    "Property",
    "Field",
    "Constructor",
    "Enum",
    "Interface",
    "Function",
    "Variable",
    "Constant",
    "String",
    "Number",
    "Boolean",
    "Array",
    "Object",
    "Key",
    "Null",
    "EnumMember",
    "Struct",
    "Event",
    "Operator",
    "TypeParameter",
    "Component",
    "Fragment",
}

-- icon highlight groups corresponding to the name of the symbol kind
local icon_colors = {
    "SymbolIcon_File",
    "SymbolIcon_Module",
    "SymbolIcon_Namespace",
    "SymbolIcon_Package",
    "SymbolIcon_Class",
    "SymbolIcon_Method",
    "SymbolIcon_Property",
    "SymbolIcon_Field",
    "SymbolIcon_Constructor",
    "SymbolIcon_Enum",
    "SymbolIcon_Interface",
    "SymbolIcon_Function",
    "SymbolIcon_Variable",
    "SymbolIcon_Constant",
    "SymbolIcon_String",
    "SymbolIcon_Number",
    "SymbolIcon_Boolean",
    "SymbolIcon_Array",
    "SymbolIcon_Object",
    "SymbolIcon_Key",
    "SymbolIcon_Null",
    "SymbolIcon_EnumMember",
    "SymbolIcon_Struct",
    "SymbolIcon_Event",
    "SymbolIcon_Operator",
    "SymbolIcon_TypeParameter",
    "SymbolIcon_Component",
    "SymbolIcon_Fragment",
}

-- icon fonts corresponding to the name of the symbol kind
local icons = {
    " F ",
    " M ",
    " N ",
    " P ",
    " C ",
    " M ",
    " P ",
    " F ",
    " C ",
    " E ",
    " I ",
    " F ",
    " V ",
    " C ",
    " S ",
    " N ",
    " B ",
    " A ",
    " O ",
    " K ",
    " N ",
    " E ",
    " S ",
    " E ",
    " O ",
    " T ",
    " C ",
    " F ",
}

-- indent marker fonts
local markers = {
    " └─",
    " ├─",
    " │ ",
    "   ",
}

-- highlight groups
vim.cmd([[
    hi def link FocusedSymbol CursorLine 
    hi def link SymbolIndent Comment
    hi def link SymbolName Normal
    hi def link SymbolDetial Directory
    hi def link SymbolKindName Comment
    hi def link SymbolIcon_File Typedef
    hi def link SymbolIcon_Package Identifier
    hi def link SymbolIcon_Class Constant
    hi def link SymbolIcon_Method Function
    hi def link SymbolIcon_Field Type
    hi def link SymbolIcon_Array Boolean
    " Self link
    hi def link SymbolIcon_Module SymbolIcon_File
    hi def link SymbolIcon_Namespace SymbolIcon_File
    hi def link SymbolIcon_Property SymbolIcon_File
    hi def link SymbolIcon_Constructor SymbolIcon_Method
    hi def link SymbolIcon_Enum SymbolIcon_Class
    hi def link SymbolIcon_Interface SymbolIcon_Field
    hi def link SymbolIcon_Function SymbolIcon_Method
    hi def link SymbolIcon_Variable SymbolIcon_Field
    hi def link SymbolIcon_Constant SymbolIcon_File
    hi def link SymbolIcon_String SymbolIcon_Method
    hi def link SymbolIcon_Number SymbolIcon_Class
    hi def link SymbolIcon_Boolean SymbolIcon_File
    hi def link SymbolIcon_Object SymbolIcon_File
    hi def link SymbolIcon_Key SymbolIcon_File
    hi def link SymbolIcon_Null SymbolIcon_File
    hi def link SymbolIcon_EnumMember SymbolIcon_Class
    hi def link SymbolIcon_Struct SymbolIcon_File
    hi def link SymbolIcon_Event SymbolIcon_Class
    hi def link SymbolIcon_Operator SymbolIcon_File
    hi def link SymbolIcon_TypeParameter SymbolIcon_File
    hi def link SymbolIcon_Component SymbolIcon_File
    hi def link SymbolIcon_Fragment SymbolIcon_File
]])

-- interfaces that need to override
local init_symbol_infos = function() end
local add_symbol_info = function(kind, t) end
local splice = function() end
local get_icon_color_index = function(line, kind) end

-- get window handle by buffer name in the current tabpage
local function get_win_buf_by(buf_name)
    local buf = vim.fn.bufnr(buf_name)
    if buf == -1 then
        return -1, -1
    end
    local tabpage_list_wins = vim.api.nvim_tabpage_list_wins(0)
    for i = 1, #tabpage_list_wins do
        local win = tabpage_list_wins[i]
        if vim.api.nvim_win_get_buf(win) == buf then
            return win, buf
        end
    end
    return -1, -1
end

-- init vars
-- @override init_symbol_infos 
local function sorted_init_symbol_infos()
    for i = 1, #kind_names do
        symbol_infos[i] = {}
    end
end

-- @override init_symbol_infos 
local function nested_init_symbol_infos()
    symbol_infos = {}
end

local function inits(source_buf)
    init_symbol_infos()
    presentings = {}
    presentings_item_lens = {}
    jump_positions = {}
    vim.t.jump_buf_name = vim.api.nvim_buf_get_name(source_buf)
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.t.focused_symbol_ns = vim.api.nvim_create_namespace("FocusedSymbol" .. tabpage)
end

-- parse lsp response to get the symbol_infos
-- @override add_symbol_info 
local function sorted_add_symbol_info(kind, t)
    symbol_infos[kind][#symbol_infos[kind] + 1] = t
end

-- @override add_symbol_info 
local function nested_add_symbol_info(kind, t)
    symbol_infos[#symbol_infos + 1] = t
end

local function parse(response, indent_num)
    for i = 1, #response do
        local symbol = response[i]
        local kind = symbol["kind"]
        local name = symbol["name"]
        local detail = symbol["detail"]
        if detail ~= nil then
            -- Removing line breaks from details
            detail = detail:gsub("\n", ""):gsub("%s+", " ")
        else
            detail = ""
        end
        local symbol_range = symbol["range"]
        if symbol_range == nil then
            symbol_range = symbol["location"]["range"]
        end
        local symbol_start = symbol_range["start"]
        local start_row = symbol_start["line"]
        local start_column = symbol_start["character"]
        local is_end = false
        if next(response, i) == nil then
            is_end = true
        end
        add_symbol_info(kind, { indent_num, kind, name, detail, start_row, start_column, is_end })
        if symbol["children"] ~= nil then
            parse(symbol["children"], indent_num + 1)
        end
    end
end

local function merge_same_kind(kind_index, cur_sequence)
    local bottem = markers[1]
    local middle = markers[2]
    -- symbol_infos indexes
    local kind = 2
    local name = 3
    local detail = 4
    local start_row = 5
    local start_column = 6
    if symbol_infos[kind_index][1] == nil then
        return cur_sequence
    end
    local kind_title = " " .. kind_names[kind_index] .. " ::"
    presentings[cur_sequence] = kind_title
    presentings_item_lens[cur_sequence] = { 0, string.len(kind_title), 0, 0, 0 }
    presentings_line_kinds[cur_sequence] = kind_index
    jump_positions[cur_sequence] = {}
    cur_sequence = cur_sequence + 1
    for i = 1, #symbol_infos[kind_index] do
        local cur = symbol_infos[kind_index][i]
        local cur_kind = cur[kind]
        local indent = middle
        if symbol_infos[kind_index][i + 1] == nil then
            indent = bottem
        end
        presentings[cur_sequence] = table.concat({
            indent,
            icons[cur_kind],
            " ",
            cur[name],
            "  ",
            cur[detail],
            "  [",
            kind_names[cur_kind],
            "] ",
        })
        presentings_item_lens[cur_sequence] = {
            string.len(indent),
            string.len(icons[cur_kind]),
            string.len(cur[name]) + 1,
            string.len(cur[detail]),
            string.len(kind_names[cur_kind]) + 4,
        }
        presentings_line_kinds[cur_sequence] = kind_index
        jump_positions[cur_sequence] = { cur[start_row], cur[start_column] }
        cur_sequence = cur_sequence + 1
    end
    presentings[cur_sequence] = ""
    presentings_item_lens[cur_sequence] = { 0, 0, 0, 0, 0 }
    presentings_line_kinds[cur_sequence] = kind_index
    jump_positions[cur_sequence] = {}
    cur_sequence = cur_sequence + 1
    return cur_sequence
end

local function get_indent_markers(cur, prev, indent_markers)
    -- symbol_infos indexes
    local indent_num = 1
    local is_end = 7
    -- indent_markers
    local bottem = markers[1]
    local middle = markers[2]
    local vert = markers[3]
    local spaces = markers[4]
    --local indent_splicing = ""
    local prev_indent = prev[indent_num]
    local cur_indent = cur[indent_num]
    local prev_is_end = prev[is_end]
    local cur_is_end = cur[is_end]
    if cur_indent == 0 then -- 如果是第一列 indent
        return {}
    end
    if cur_is_end then -- 如果是这一个 indent 里面的最后一个
        indent_markers[cur_indent] = bottem
    else -- 如果不是这一个 indent 里面的最后一个
        indent_markers[cur_indent] = middle
    end
    -- 如果与上一个是处于同一个 indent
    if prev_indent == cur_indent then
        return indent_markers
    end
    if cur_indent < prev_indent then -- 如果不是上一个的孩子，而是上一个的长辈，但是辈分不清楚
        for i = cur_indent + 1, #indent_markers do
            indent_markers[i] = nil
        end
        return indent_markers
    end
    -- 如果不是与上一个处于同一个 indent
    if prev_is_end then -- 如果上一个是它那一层的最后一个
        indent_markers[prev_indent] = spaces
    else -- 如果上一个不是它那一层的最后一个
        indent_markers[prev_indent] = vert
    end
    return indent_markers
end

-- splicing of each line of symbol outline content
-- @override splice 
local function sorted_splice()
    local cur_sequence = 1
    for i = 1, #kind_names do
        cur_sequence = merge_same_kind(i, cur_sequence)
    end
    vim.t.jump_positions = jump_positions
end

-- @override splice 
local function nested_splice()
    local indent_markers = {}
    local prev = {}
    -- symbol_infos indexes
    local kind = 2
    local name = 3
    local detail = 4
    local start_row = 5
    local start_column = 6
    for i = 1, #symbol_infos do
        local cur = symbol_infos[i]
        indent_markers = get_indent_markers(cur, prev, indent_markers)
        local indent_splicing = table.concat(indent_markers)
        local cur_kind = cur[kind]
        presentings[i] = table.concat({
            indent_splicing,
            icons[cur_kind],
            " ",
            cur[name],
            "  ",
            cur[detail],
            "  [",
            kind_names[cur_kind],
            "] ",
        })
        presentings_item_lens[i] = {
            string.len(indent_splicing),
            string.len(icons[cur_kind]),
            string.len(cur[name]) + 1,
            string.len(cur[detail]),
            string.len(kind_names[cur_kind]) + 4,
        }
        jump_positions[i] = { cur[start_row], cur[start_column] }
        prev = cur
    end
    vim.t.jump_positions = jump_positions
end

-- open symbol outline win
local function open_outline_win()
    local outline_tabpage = -1
    local outline_name = ""
    local outline_win, outline_buf = -1, -1
    if is_refresh then
        is_refresh = false
        vim.api.nvim_set_current_win(refresh_outline_win)
        outline_win = refresh_outline_win
        outline_buf = refresh_outline_buf
    else
        outline_tabpage = vim.api.nvim_get_current_tabpage()
        outline_name = "SymbolOutline" .. outline_tabpage
        outline_win, outline_buf = get_win_buf_by(outline_name)
        if outline_win == -1 then
            vim.cmd("bot 45vs")
            vim.cmd.edit(outline_name)
            outline_win = vim.api.nvim_get_current_win()
            outline_buf = vim.api.nvim_get_current_buf()
        else
            vim.api.nvim_set_current_win(outline_win)
        end
    end
    vim.opt_local.buftype = "nofile"
    vim.opt_local.bufhidden = "wipe"
    vim.opt_local.buflisted = false
    vim.opt_local.swapfile = false
    vim.opt_local.wrap = false
    vim.opt_local.list = false
    vim.opt_local.filetype = "SymbolOutline"
    return outline_win, outline_buf
end

-- write buffer
local function write(outline_buf)
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, presentings)
end

-- highlight the symbol outline
-- @override get_icon_color_index 
local function sorted_get_icon_color_index(line, kind)
    return presentings_line_kinds[line]
end

-- @override get_icon_color_index 
local function nested_get_icon_color_index(line, kind)
    return symbol_infos[line][kind]
end

local function highlight(outline_buf)
    -- presentings_line_lens indexes
    local indent_num = 1
    local kind = 2
    local name = 3
    local detail = 4
    local kind_name = 5
    for line = 1, #presentings_item_lens do
        local len = presentings_item_lens[line]
        -- indent
        local indent_num_len = len[indent_num]
        vim.api.nvim_buf_add_highlight(outline_buf, -1, "SymbolIndent", line - 1, 0, indent_num_len)
        -- kind
        local hl_start_col = len[indent_num]
        local hl_end_col = len[kind] + hl_start_col
        local icon_color = icon_colors[get_icon_color_index(line, kind)]
        vim.api.nvim_buf_add_highlight(outline_buf, -1, icon_color, line - 1, hl_start_col, hl_end_col)
        -- name
        hl_start_col = hl_end_col + 1
        hl_end_col = len[name] + hl_start_col
        vim.api.nvim_buf_add_highlight(outline_buf, -1, "SymbolName", line - 1, hl_start_col, hl_end_col)
        -- detail
        hl_start_col = hl_end_col + 1
        hl_end_col = len[detail] + hl_start_col
        vim.api.nvim_buf_add_highlight(outline_buf, -1, "SymbolDetial", line - 1, hl_start_col, hl_end_col)
        -- kind_name
        hl_start_col = hl_end_col + 1
        hl_end_col = len[kind_name] + hl_start_col
        vim.api.nvim_buf_add_highlight(outline_buf, -1, "SymbolKindName", line - 1, hl_start_col, hl_end_col)
    end
end

-- depend on open_position
local function locate_open_position_in(outline_win)
    --jump_positions = vim.t.jump_positions
    local open_position_in_outline = -1
    for i = 1, #vim.t.jump_positions do
        local jump_row = vim.t.jump_positions[i][1]
        if jump_row == source_open_row - 1 then
            open_position_in_outline = i
            break
        end
    end
    if open_position_in_outline ~= -1 then
        vim.api.nvim_win_set_cursor(outline_win, { open_position_in_outline, 0 })
        vim.cmd.normal("zz")
    end
end

-- jump to the symbol in the source file
local function jump()
    local jump_buf_name = vim.t.jump_buf_name
    local cur_symbol_row = vim.api.nvim_win_get_cursor(0)[1]
    local jump_position = vim.t.jump_positions[cur_symbol_row]
    if jump_position[1] == nil then
        return
    end
    local jump_row = tonumber(jump_position[1])
    local jump_col = tonumber(jump_position[2])
    local jump_win, jump_buf = get_win_buf_by(jump_buf_name)
    if jump_win == -1 then
        local outline_win = vim.api.nvim_get_current_win()
        vim.cmd("to vsplit")
        vim.cmd.edit(jump_buf_name)
        jump_win = vim.api.nvim_get_current_win()
        jump_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_set_current_win(outline_win)
    end
    vim.api.nvim_win_call(jump_win, function()
        vim.api.nvim_win_set_cursor(jump_win, { jump_row + 1, jump_col })
        vim.cmd.normal("zz")
    end)
    local focused_symbol_ns = vim.t.focused_symbol_ns
    vim.api.nvim_buf_clear_namespace(jump_buf, focused_symbol_ns, 0, -1)
    vim.api.nvim_buf_add_highlight(jump_buf, focused_symbol_ns, "FocusedSymbol", jump_row, jump_col, -1)
end

-- refresh symbol outline
local function refresh()
    local jump_win, _ = get_win_buf_by(vim.t.jump_buf_name)
    if jump_win == -1 then
        print(">> Corresponding Source File Win Not Exists!")
        return
    end
    refresh_outline_win = vim.api.nvim_get_current_win()
    refresh_outline_buf = vim.api.nvim_get_current_buf()
    is_refresh = true
    vim.api.nvim_win_call(jump_win, function()
        SYMBOL_OUTLINE.open_outline(jump_win)
    end)
end

local function return_immediately()
    if next(vim.lsp.get_clients({bufnr = 0})) == nil then
        return true
    end
    if vim.t.jump_buf_name == nil then
        return false
    end
    if vim.fn.bufnr(vim.t.jump_buf_name) ~= vim.api.nvim_get_current_buf() then
        return false
    end
    if is_refresh then
        return false
    end
    local outline_tabpage = vim.api.nvim_get_current_tabpage()
    local outline_win, _ = get_win_buf_by("SymbolOutline" .. outline_tabpage)
    if outline_win == -1 then
        return false
    end
    if vim.t.outline_type ~= outline_type then
        return false
    end
    vim.api.nvim_set_current_win(outline_win)
    locate_open_position_in(outline_win)
    return true
end

-- open symbol outline
function SYMBOL_OUTLINE.open_outline(source_win)
    local source_buf = vim.api.nvim_win_get_buf(source_win)
    source_open_row = vim.api.nvim_win_get_cursor(source_win)[1]
    if return_immediately() then
        return
    end
    vim.t.outline_type = outline_type
    vim.lsp.buf_request(
        source_buf,
        "textDocument/documentSymbol",
        { textDocument = vim.lsp.util.make_text_document_params() },
        function(_, response)
            if response[1] == nil then
                print(">> No Symbols But LSP Is Working!")
                return
            end
            inits(source_buf)
            parse(response, 0)
            splice()
            local outline_win, outline_buf = open_outline_win()
            write(outline_buf)
            highlight(outline_buf)
            locate_open_position_in(outline_win)
            vim.keymap.set("n", "<CR>", jump, { noremap = true, silent = true, buffer = true })
            vim.keymap.set("n", "r", refresh, { noremap = true, silent = true, buffer = true })
        end
    )
end

local function activate_sorted_view(source_win)
    outline_type = "sorted"
    init_symbol_infos = sorted_init_symbol_infos
    add_symbol_info = sorted_add_symbol_info
    splice = sorted_splice
    get_icon_color_index = sorted_get_icon_color_index
    SYMBOL_OUTLINE.open_outline(source_win)
end

local function activate_nested_view(source_win)
    outline_type = "nested"
    init_symbol_infos = nested_init_symbol_infos
    add_symbol_info = nested_add_symbol_info
    splice = nested_splice
    get_icon_color_index = nested_get_icon_color_index
    SYMBOL_OUTLINE.open_outline(source_win)
end

vim.api.nvim_create_user_command("OpenSymbolOutlineNested", function()
    activate_nested_view(0)
end, {})
vim.api.nvim_create_user_command("OpenSymbolOutlineSorted", function()
    activate_sorted_view(0)
end, {})

-- -- 1. 准备lazy.nvim模块（存在性检测）
-- -- stdpath("data")
-- -- macOS/Linux: ~/.local/share/nvim
-- -- Windows: ~/AppData/Local/nvim-data
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system({
-- 		"git",
-- 		"clone",
-- 		"--filter=blob:none",
-- 		"https://gitee.com/hcy-asleep/lazy.nvim.git",
-- 		"--branch=stable", -- latest stable release
-- 		lazypath,
-- 	})
-- end
-- -- 
-- -- 2. 将 lazypath 设置为运行时路径
-- -- rtp（runtime path）
-- -- nvim进行路径搜索的时候，除已有的路径，还会从prepend的路径中查找
-- -- 否则，下面 require("lazy") 是找不到的
-- vim.opt.rtp:prepend(lazypath)
-- 
-- -- 3. 加载lazy.nvim模块
-- require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})


vim.opt.runtimepath:append("/root/nvim-treesitter/")


