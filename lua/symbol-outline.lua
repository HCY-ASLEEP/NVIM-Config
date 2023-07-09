local vim = vim
local unpack = unpack or table.unpack

local M = {}

-- parsed raw symbol content
local symbol_infos = {}

-- symbol position under the cursor of the source file
-- at the moment before opening the symbol outline
local open_position = -1

-- the final content to be written to the buffer
local presentings = {}

-- the length of each string element in each line of
-- the final content to be written into the buffer
local presentings_line_lens = {}

-- jump buffer name of the source file
local jump_buf_name = nil

-- jump position of each symbol in the source file
local jump_positions = {}

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
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
}

-- indent marker fonts
local indent_marker = {
	" └ ",
	" ├ ",
	" │ ",
	"   ",
}

-- get window handle by buffer name in the current tabpage
local function get_window_handle_by_buf_name(buf_name)
	local bufnr = vim.fn.bufnr(buf_name)
	for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
	return -1
end

-- init vars
local function inits()
	symbol_infos = {}
	presentings = {}
	presentings_line_lens = {}
	jump_buf_name = vim.api.nvim_buf_get_name(0)
	vim.t.jump_buf_name = jump_buf_name
	jump_positions = {}
end

-- parse lsp response to get the symbol_infos
local function parse(response, indent_num)
	for key, value in pairs(response) do
		local kind = value["kind"]
		local name = value["name"]
		local detail = value["detail"]
		if detail ~= nil then
			-- Removing line breaks from details
			detail = detail:gsub("\n", ""):gsub("%s+", " ")
		else
			detail = ""
		end
		local symbol_start = value["range"]["start"]
		local start_row = symbol_start["line"]
		local start_column = symbol_start["character"]
		local is_end = false
		if next(response, key) == nil then
			is_end = true
		end
		table.insert(symbol_infos, {
			indent_num,
			kind,
			name,
			detail,
			start_row,
			start_column,
			is_end,
		})
		if value["children"] ~= nil then
			parse(value["children"], indent_num + 1)
		end
	end
end

-- splicing of each line of symbol outline content
local function splice()
	local indent_markers = {}
	local prev = nil
	-- symbol_infos indexes
	local indent_num = 1
	local kind = 2
	local name = 3
	local detail = 4
	local start_row = 5
	local start_column = 6
	local is_end = 7
	-- indent_markers indexes
	local bottem = 1
	local middle = 2
	local vert = 3
	local spaces = 4
	for _, cur in pairs(symbol_infos) do
		local indent_splicing = " "
		if cur[indent_num] ~= 0 then --如果不是第一列 indent
			if prev[indent_num] == cur[indent_num] then --如果与上一个是处于同一个 indent
				if cur[is_end] then --如果是这一个 indent 里面的最后一个
					indent_markers[#indent_markers] = bottem
				end
			else --如果不是与上一个处于同一个 indent
				if cur[indent_num] > prev[indent_num] then --如果是上一个的孩子
					if #indent_markers ~= 0 then
						if prev[is_end] then --如果上一个是它那一层的最后一个
							indent_markers[#indent_markers] = spaces
						else --如果上一个不是它那一层的最后一个
							indent_markers[#indent_markers] = vert
						end
					end
					if cur[is_end] then --如果是这一个 indent 里面的最后一个
						table.insert(indent_markers, bottem)
					else --如果不是这一个 indent 里面的最后一个
						table.insert(indent_markers, middle)
					end
				else --如果不是上一个的孩子，而是上一个的长辈但是辈分不清楚
					indent_markers = { unpack(indent_markers, 1, cur[indent_num]) }
					if cur[is_end] then --如果是这一个 indent 里面的最后一个
						indent_markers[#indent_markers] = bottem
					else --如果不是这一个 indent 里面的最后一个
						indent_markers[#indent_markers] = middle
					end
				end
			end
			for _, marker_kind in pairs(indent_markers) do
				indent_splicing = indent_splicing .. indent_marker[marker_kind]
			end
		else --如果是第一列 indent
			indent_markers = {}
		end
		table.insert(
			presentings,
			indent_splicing
				.. icons[cur[kind]]
				.. " "
				.. cur[name]
				.. " "
				.. cur[detail]
				.. " "
				.. " ["
				.. kind_names[cur[kind]]
				.. "] "
		)
		table.insert(presentings_line_lens, {
			string.len(indent_splicing),
			string.len(icons[cur[kind]]),
			string.len(cur[name]),
			string.len(cur[detail]),
			string.len(" [" .. kind_names[cur[kind]] .. "] "),
		})
		table.insert(jump_positions, { cur[start_row], cur[start_column] })
		prev = cur
	end
	vim.t.jump_positions = jump_positions
end

-- write buffer
local function write()
	vim.api.nvim_buf_set_lines(0, 0, -1, false, presentings)
end

-- open symbol outline win
local function open_symbol_outline_win()
	open_position = vim.api.nvim_win_get_cursor(0)[1]
	local symbol_outline_tabpage_handle = vim.api.nvim_get_current_tabpage()
	local symbol_outline_win_handle = get_window_handle_by_buf_name("SymbolOutline" .. symbol_outline_tabpage_handle)
	if symbol_outline_win_handle ~= -1 then
		vim.api.nvim_set_current_win(symbol_outline_win_handle)
	else
		vim.cmd.vsplit()
	end
	vim.cmd.edit("SymbolOutline" .. symbol_outline_tabpage_handle)
	vim.opt_local.buftype = "nofile"
	vim.opt_local.bufhidden = "wipe"
	vim.opt_local.buflisted = false
	vim.opt_local.swapfile = false
	vim.opt_local.wrap = false
	vim.opt_local.list = false
	vim.opt_local.filetype = "SymbolOutline"
end

-- highlight the symbol outline
local function highlight_outline()
	-- presentings_line_lens indexes
	local indent_num = 1
	local kind = 2
	local name = 3
	local detail = 4
	local kind_name = 5
	for line, len in pairs(presentings_line_lens) do
		--indent
		vim.api.nvim_buf_add_highlight(0, -1, "SymbolIndent", line - 1, 0, len[indent_num] - 1)
		-- kind
		local hl_start_col = len[indent_num]
		local hl_end_col = len[kind] + hl_start_col
		vim.api.nvim_buf_add_highlight(0, -1, icon_colors[symbol_infos[line][kind]], line - 1, hl_start_col, hl_end_col)
		-- name
		hl_start_col = hl_end_col + 1
		hl_end_col = len[name] + hl_start_col
		vim.api.nvim_buf_add_highlight(0, -1, "SymbolName", line - 1, hl_start_col, hl_end_col)
		-- detail
		hl_start_col = hl_end_col + 1
		hl_end_col = len[detail] + hl_start_col
		vim.api.nvim_buf_add_highlight(0, -1, "SymbolDetial", line - 1, hl_start_col, hl_end_col)
		-- kind_name
		hl_start_col = hl_end_col + 1
		hl_end_col = len[kind_name] + hl_start_col
		vim.api.nvim_buf_add_highlight(0, -1, "SymbolKindName", line - 1, hl_start_col, hl_end_col)
	end
end

-- depend on open_position
local function locate_open_symbol_position_in_symbol_outline()
	jump_positions = vim.t.jump_positions
	local open_symbol_position_in_symbol_outline = -1
	for key, value in pairs(jump_positions) do
		if value[1] == open_position - 1 then
			open_symbol_position_in_symbol_outline = key
			break
		end
	end
	if open_symbol_position_in_symbol_outline ~= -1 then
		vim.api.nvim_win_set_cursor(0, { open_symbol_position_in_symbol_outline, 0 })
		vim.cmd.normal("zz")
	end
end

-- jump to the symbol in the source file
local function jump()
	jump_buf_name = vim.t.jump_buf_name
	jump_positions = vim.t.jump_positions
	local cur_symbol_line = vim.api.nvim_win_get_cursor(0)[1]
	local jump_position = jump_positions[cur_symbol_line]
	local jump_row = tonumber(jump_position[1])
	local jump_col = tonumber(jump_position[2])
	local jump_win_handle = get_window_handle_by_buf_name(jump_buf_name)
	vim.api.nvim_set_current_win(jump_win_handle)
	vim.api.nvim_win_set_cursor(jump_win_handle, { jump_row + 1, jump_col })
end

-- refresh symbol outline
local function refresh()
	jump_buf_name = vim.t.jump_buf_name
	local jump_win_handle = get_window_handle_by_buf_name(jump_buf_name)
	vim.api.nvim_set_current_win(jump_win_handle)
	M.open()
end

-- open symbol outline
function M.open()
	vim.lsp.buf_request(
		0,
		"textDocument/documentSymbol",
		{ textDocument = vim.lsp.util.make_text_document_params() },
		function(_, response)
			if next(response) == nil then
				print(">> No Symbols But LSP Is Working!")
				return
			end
			inits()
			parse(response, 0)
			splice()
			open_symbol_outline_win()
			write()
			highlight_outline()
			locate_open_symbol_position_in_symbol_outline()
			vim.keymap.set("n", "<CR>", jump, { noremap = true, silent = true, buffer = true })
			vim.keymap.set("n", "r", refresh, { noremap = true, silent = true, buffer = true })
		end
	)
end

vim.cmd.highlight({ "SymbolIndent", "ctermfg=gray", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolKind", "ctermfg=lightcyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolName", "ctermfg=lightgray", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolDetial", "ctermfg=darkmagenta", "ctermbg=NONE", "cterm=italic" })
vim.cmd.highlight({ "SymbolKindName", "ctermfg=darkgray", "ctermbg=NONE", "cterm=NONE" })
vim.cmd.highlight({ "SymbolPosition", "ctermfg=black", "ctermbg=NONE", "cterm=NONE" })
vim.cmd.highlight({ "SymbolIcon_File", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Module", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Namespace", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Package", "ctermfg=red", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Class", "ctermfg=yellow", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Method", "ctermfg=lightmagenta", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Property", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Field", "ctermfg=lightblue", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Constructor", "ctermfg=lightmagenta", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Enum", "ctermfg=yellow", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Interface", "ctermfg=lightblue", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Function", "ctermfg=lightmagenta", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Variable", "ctermfg=lightblue", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Constant", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_String", "ctermfg=lightmagenta", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Number", "ctermfg=yellow", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Boolean", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Array", "ctermfg=lightgreen", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Object", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Key", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Null", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_EnumMember", "ctermfg=yellow", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Struct", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Event", "ctermfg=yellow", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Operator", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_TypeParameter", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Component", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })
vim.cmd.highlight({ "SymbolIcon_Fragment", "ctermfg=cyan", "ctermbg=NONE", "cterm=bold" })

return M
