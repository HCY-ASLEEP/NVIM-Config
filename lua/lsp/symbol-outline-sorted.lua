local vim = vim

local M = {}

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

local presentings_line_kinds = {}

local jump_positions = {}

local outline_type = "sorted"

--local vim.t.jump_positions = {}

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
local function inits(source_buf)
	for i = 1, #kind_names do
		symbol_infos[i] = {}
	end
	presentings = {}
	presentings_item_lens = {}
	jump_positions = {}
	vim.t.jump_buf_name = vim.api.nvim_buf_get_name(source_buf)
	local tabpage = vim.api.nvim_get_current_tabpage()
	vim.t.focused_symbol_ns = vim.api.nvim_create_namespace("FocusedSymbol" .. tabpage)
end

-- parse lsp response to get the symbol_infos
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
		symbol_infos[kind][#symbol_infos[kind] + 1] =
			{ indent_num, kind, name, detail, start_row, start_column, is_end }
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

-- splicing of each line of symbol outline content
local function splice()
	local cur_sequence = 1
	for i = 1, #kind_names do
		cur_sequence = merge_same_kind(i, cur_sequence)
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
			vim.cmd("topleft 45vs")
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
		vim.api.nvim_buf_add_highlight(
			outline_buf,
			-1,
			icon_colors[presentings_line_kinds[line]],
			line - 1,
			hl_start_col,
			hl_end_col
		)
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
		vim.cmd("rightbelow vsplit")
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
		M.open(jump_win)
	end)
end

local function return_immediately()
    if #vim.lsp.buf_get_clients() <= 0 then
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
function M.open(source_win)
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
			if next(response) == nil then
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

return M
