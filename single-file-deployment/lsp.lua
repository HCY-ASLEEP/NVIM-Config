-- +-----------------------------------------------+
-- |                                               |
-- |         LANGUAGE SERVER CONFIGURATION         |
-- |                                               |
-- +-----------------------------------------------+


local vim = vim


local servers = {
    --[[
    ccls = {
        cmd = { 'ccls' },
        filetypes = {
            'c',
            'cpp',
            'objc',
            'objcpp',
            'cuda'
        },
        root_dir = vim.fs.root(0, {
            'compile_commands.json',
            '.ccls',
            '.git'
        }),
        offset_encoding = 'utf-32',
        -- ccls does not support sending a null root directory
        single_file_support = false,
    },
    jedi = {
        cmd = { 'jedi-language-server' },
        filetypes = { 'python' },
        root_dir = vim.fs.root(0, {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            '.git',
        }),
        single_file_support = true,
    },
    --]]
    vim_ls = {
        cmd = { 'vim-language-server', '--stdio' },
        filetypes = { 'vim' },
        root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
        end,
        single_file_support = true,
        init_options = {
            isNeovim = true,
            iskeyword = '@,48-57,_,192-255,-#',
            vimruntime = '',
            runtimepath = '',
            diagnostic = { enable = true },
            indexes = {
                runtimepath = true,
                gap = 100,
                count = 3,
                projectRootPatterns = { 'runtime', 'nvim', '.git', 'autoload', 'plugin' },
            },
            suggest = { fromVimruntime = true, fromRuntimepath = true },
        },
    },
    basedpyright = {
        cmd = { 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_dir = vim.fs.root(0, {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git',
        }),
        single_file_support = true,
        settings = {
            basedpyright = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = 'openFilesOnly',
                },
            },
        },
    },   
    clangd = {
        cmd = { 'clangd' },
        filetypes = {
            'c',
            'cpp',
            'objc',
            'objcpp',
            'cuda',
            'proto'
        },
        root_dir = vim.fs.root(0, {
            '.clangd',
            '.clang-tidy',
            '.clang-format',
            'compile_commands.json',
            'compile_flags.txt',
            'configure.ac', -- AutoTools
            '.git'
        }),
        single_file_support = true,
        capabilities = {
            textDocument = {
                completion = {
                    editsNearCursor = true,
                },
            },
          offsetEncoding = { 'utf-16' },
        },
    },
    lua_ls = {
        cmd = { 'lua-language-server' },
        root_dir = vim.fs.root(0, {
            '.luarc.json',
            '.luarc.jsonc',
            '.luacheckrc',
            '.stylua.toml',
            'stylua.toml',
            'selene.toml',
            'selene.yml',
            '.git'
        }),
        filetypes = { 'lua' },
        single_file_support = true,
    },
    gopls = {
        cmd = { 'gopls' },
        root_dir = vim.fs.root(0, {
            'go.work',
            'go.mod',
            '.git'
        }),
        filetypes = {
            'go',
            'gomod',
            'gowork',
            'gotmpl'
        },
    },
}

local user_lsp_start_augroup = vim.api.nvim_create_augroup("UserLspStart", { clear = true })
for server, config in pairs(servers) do
    if vim.fn.executable(config.cmd[1]) ~= 0 then
        vim.api.nvim_create_autocmd("FileType", {
            group = user_lsp_start_augroup,
            pattern = config.filetypes,
            callback = function (ev)
                vim.b.server = server
                vim.lsp.start(config, { bufnr = ev.buf })
            end,
        })
    end
end

local function restart_cur_buf_language_servers()
    vim.cmd('wa')
    local opt = { bufnr = 0 }
    vim.lsp.stop_client(vim.lsp.get_clients(opt))
    vim.lsp.start(servers[vim.b.server], opt)
end

local lsp_buf_local_augroup = vim.api.nvim_create_augroup("LspBufLocal", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter", "LspAttach"}, {
    group = lsp_buf_local_augroup,
    callback = function() 
        if next(vim.lsp.get_clients({ bufnr = 0 }))==nil then
            return
        end
        if vim.b.lsp_mapped ~= nil then
            return
        end
        vim.b.lsp_mapped = true
        vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.vim.lsp.omnifunc")
        vim.api.nvim_buf_set_option(0, "updatetime", 300)
        
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
        
        g_prefix_dict["e"] = function () vim.diagnostic.open_float({ border = 'rounded' }) end      -- [e]rrors or warnings
        g_prefix_dict["h"] = function () vim.lsp.buf.hover({ border = 'rounded' }) end              -- [h]over
        g_prefix_dict["s"] = function () vim.lsp.buf.signature_help({ border = 'rounded' }) end     -- [s]ignature
        g_prefix_dict["a"] = vim.diagnostic.setloclist      -- [a]ll errors and warnings
        g_prefix_dict["D"] = vim.lsp.buf.declaration        -- [D]eclaration                                        
        g_prefix_dict["d"] = vim.lsp.buf.definition         -- [d]efinition
        g_prefix_dict["i"] = vim.lsp.buf.implementation     -- [i]mplementation
        g_prefix_dict["r"] = vim.lsp.buf.references         -- [r]eferences
        g_prefix_dict["t"] = vim.lsp.buf.type_definition    -- [t]ype_definition
        g_prefix_dict["R"] = vim.lsp.buf.rename             -- [R]ename

        g_prefix_dict["u"] = restart_cur_buf_language_servers   -- [u]pdate and restart language servers

        vim.keymap.set("n", "<C-up>", vim.diagnostic.goto_prev, opt)
        vim.keymap.set("n", "<C-down>", vim.diagnostic.goto_next, opt)
        
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = 0,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = 0,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })

    end
})

vim.lsp.inlay_hint.enable()

vim.diagnostic.config({
    virtual_text = false,
    underline = true,
})

vim.cmd("hi! link NormalFloat Normal")
vim.cmd("hi! link FloatBorder Comment")
vim.cmd("hi! link LspReferenceText WildMenu")

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
    [1]  = "File",
    [2]  = "Module",
    [3]  = "Namespace",
    [4]  = "Package",
    [5]  = "Class",
    [6]  = "Method",
    [7]  = "Property",
    [8]  = "Field",
    [9]  = "Constructor",
    [10] = "Enum",
    [11] = "Interface",
    [12] = "Function",
    [13] = "Variable",
    [14] = "Constant",
    [15] = "String",
    [16] = "Number",
    [17] = "Boolean",
    [18] = "Array",
    [19] = "Object",
    [20] = "Key",
    [21] = "Null",
    [22] = "EnumMember",
    [23] = "Struct",
    [24] = "Event",
    [25] = "Operator",
    [26] = "TypeParameter",
    [27] = "Component",
    [28] = "Fragment",

    -- ccls
    [252] = "TypeAlias",
    [253] = "Parameter",
    [254] = "StaticMethod",
    [255] = "Macro"
}

-- icon highlight groups corresponding to the name of the symbol kind
local icon_colors = {
    [1]  = "SymbolIcon_File",
    [2]  = "SymbolIcon_Module",
    [3]  = "SymbolIcon_Namespace",
    [4]  = "SymbolIcon_Package",
    [5]  = "SymbolIcon_Class",
    [6]  = "SymbolIcon_Method",
    [7]  = "SymbolIcon_Property",
    [8]  = "SymbolIcon_Field",
    [9]  = "SymbolIcon_Constructor",
    [10] = "SymbolIcon_Enum",
    [11] = "SymbolIcon_Interface",
    [12] = "SymbolIcon_Function",
    [13] = "SymbolIcon_Variable",
    [14] = "SymbolIcon_Constant",
    [15] = "SymbolIcon_String",
    [16] = "SymbolIcon_Number",
    [17] = "SymbolIcon_Boolean",
    [18] = "SymbolIcon_Array",
    [19] = "SymbolIcon_Object",
    [20] = "SymbolIcon_Key",
    [21] = "SymbolIcon_Null",
    [22] = "SymbolIcon_EnumMember",
    [23] = "SymbolIcon_Struct",
    [24] = "SymbolIcon_Event",
    [25] = "SymbolIcon_Operator",
    [26] = "SymbolIcon_TypeParameter",
    [27] = "SymbolIcon_Component",
    [28] = "SymbolIcon_Fragment",

    -- ccls
    [252] ="SymbolIcon_TypeAlias",
    [253] ="SymbolIcon_Parameter",
    [254] ="SymbolIcon_StaticMethod",
    [255] ="SymbolIcon_Macro"
}

-- icon fonts corresponding to the name of the symbol kind
local icons = {
    [1]  = " F ",
    [2]  = " M ",
    [3]  = " N ",
    [4]  = " P ",
    [5]  = " C ",
    [6]  = " M ",
    [7]  = " P ",
    [8]  = " F ",
    [9]  = " C ",
    [10] = " E ",
    [11] = " I ",
    [12] = " F ",
    [13] = " V ",
    [14] = " C ",
    [15] = " S ",
    [16] = " N ",
    [17] = " B ",
    [18] = " A ",
    [19] = " O ",
    [20] = " K ",
    [21] = " N ",
    [22] = " E ",
    [23] = " S ",
    [24] = " E ",
    [25] = " O ",
    [26] = " T ",
    [27] = " C ",
    [28] = " F ",

    -- ccls
    [252] =" T ",
    [253] =" P ",
    [254] =" S ",
    [255] =" M ",
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
    hi def link SymbolIcon_File Identifier
    hi def link SymbolIcon_Module Include
    hi def link SymbolIcon_Namespace Include
    hi def link SymbolIcon_Package Include
    hi def link SymbolIcon_Class Type
    hi def link SymbolIcon_Method Function
    hi def link SymbolIcon_Property Identifier
    hi def link SymbolIcon_Field Identifier
    hi def link SymbolIcon_Constructor Spetial
    hi def link SymbolIcon_Enum Type
    hi def link SymbolIcon_Interface Type
    hi def link SymbolIcon_Function Function
    hi def link SymbolIcon_Variable Constant
    hi def link SymbolIcon_Constant Constant
    hi def link SymbolIcon_String String
    hi def link SymbolIcon_Number Number
    hi def link SymbolIcon_Boolean Boolean
    hi def link SymbolIcon_Array Constant
    hi def link SymbolIcon_Object Type
    hi def link SymbolIcon_Key Type
    hi def link SymbolIcon_Null Type
    hi def link SymbolIcon_EnumMember Identifier
    hi def link SymbolIcon_Struct Structure
    hi def link SymbolIcon_Event Type
    hi def link SymbolIcon_Operator Identifier
    hi def link SymbolIcon_TypeParameter Identifier
    hi def link SymbolIcon_Component Function
    hi def link SymbolIcon_Fragment Constant
    hi def link SymbolIcon_TypeAlias Type
    hi def link SymbolIcon_Parameter Identifier
    hi def link SymbolIcon_StaticMethod Function
    hi def link SymbolIcon_Macro Function
]])

-- interfaces that need to override
local init_symbol_infos = function() end
local add_symbol_info = function(kind, t) end
local join = function() end
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
local function init_sorted_symbol_infos()
    for i in pairs(kind_names) do
        symbol_infos[i] = {}
    end
end

-- @override init_symbol_infos
local function init_nested_symbol_infos()
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
local function add_sorted_symbol_info(i)
    kind = i[2]
    symbol_infos[kind][#symbol_infos[kind] + 1] = i
end

-- @override add_symbol_info
local function add_nested_symbol_info(i)
    symbol_infos[#symbol_infos + 1] = i
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
        add_symbol_info({ indent_num, kind, name, detail, start_row, start_column, is_end })
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
-- @override join
local function join_sorted()
    local cur_sequence = 1
    for i in pairs(kind_names) do
        cur_sequence = merge_same_kind(i, cur_sequence)
    end
    vim.t.jump_positions = jump_positions
end

-- @override join
local function join_nested()
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
        local indent_join = table.concat(indent_markers)
        local cur_kind = cur[kind]
        presentings[i] = table.concat({
            indent_join,
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
            string.len(indent_join),
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
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.filetype = "SymbolOutline"
    return outline_win, outline_buf
end

-- write buffer
local function write(outline_buf)
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, presentings)
end

-- highlight the symbol outline
-- @override get_icon_color_index
local function get_sorted_icon_color_index(line, kind)
    return presentings_line_kinds[line]
end

-- @override get_icon_color_index
local function get_nested_icon_color_index(line, kind)
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
            join()
            local outline_win, outline_buf = open_outline_win()
            write(outline_buf)
            highlight(outline_buf)
            locate_open_position_in(outline_win)
            vim.keymap.set("n", "<CR>", jump, { noremap = true, silent = true, buffer = true })
            vim.keymap.set("n", "r", refresh, { noremap = true, silent = true, buffer = true })
            local group = vim.api.nvim_create_augroup("FocusedSymbolAugroup", { clear = true })
            vim.api.nvim_create_autocmd("BufWinLeave",{
                group = group,
                buffer = 0,
                callback = function ()
                    local _, jump_buf = get_win_buf_by(vim.t.jump_buf_name)
                    vim.api.nvim_buf_clear_namespace(jump_buf, vim.t.focused_symbol_ns, 0, -1)
                end,
            })
        end
    )
end

local function activate_sorted_view(source_win)
    outline_type = "sorted"
    init_symbol_infos = init_sorted_symbol_infos
    add_symbol_info = add_sorted_symbol_info
    join = join_sorted
    get_icon_color_index = get_sorted_icon_color_index
    SYMBOL_OUTLINE.open_outline(source_win)
end

local function activate_nested_view(source_win)
    outline_type = "nested"
    init_symbol_infos = init_nested_symbol_infos
    add_symbol_info = add_nested_symbol_info
    join = join_nested
    get_icon_color_index = get_nested_icon_color_index
    SYMBOL_OUTLINE.open_outline(source_win)
end

vim.api.nvim_create_user_command("OpenSymbolOutlineNested", function()
    activate_nested_view(0)
end, {})
vim.api.nvim_create_user_command("OpenSymbolOutlineSorted", function()
    activate_sorted_view(0)
end, {})
