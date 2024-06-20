local vim = vim

vim.cmd([[
    hi! link FocusedSymbol CursorLine 
    hi! link SymbolIndent Comment
    hi! link SymbolName Normal
    hi! link SymbolDetial Directory
    hi! link SymbolKindName Comment
    hi! link SymbolIcon_File Typedef
    hi! link SymbolIcon_Package Identifier
    hi! link SymbolIcon_Class Constant
    hi! link SymbolIcon_Method Function
    hi! link SymbolIcon_Field Type
    hi! link SymbolIcon_Array Boolean
    "" Comment
    hi! link SymbolIcon_Module SymbolIcon_File
    hi! link SymbolIcon_Namespace SymbolIcon_File
    hi! link SymbolIcon_Property SymbolIcon_File
    hi! link SymbolIcon_Constructor SymbolIcon_Method
    hi! link SymbolIcon_Enum SymbolIcon_Class
    hi! link SymbolIcon_Interface SymbolIcon_Field
    hi! link SymbolIcon_Function SymbolIcon_Method
    hi! link SymbolIcon_Variable SymbolIcon_Field
    hi! link SymbolIcon_Constant SymbolIcon_File
    hi! link SymbolIcon_String SymbolIcon_Method
    hi! link SymbolIcon_Number SymbolIcon_Class
    hi! link SymbolIcon_Boolean SymbolIcon_File
    hi! link SymbolIcon_Object SymbolIcon_File
    hi! link SymbolIcon_Key SymbolIcon_File
    hi! link SymbolIcon_Null SymbolIcon_File
    hi! link SymbolIcon_EnumMember SymbolIcon_Class
    hi! link SymbolIcon_Struct SymbolIcon_File
    hi! link SymbolIcon_Event SymbolIcon_Class
    hi! link SymbolIcon_Operator SymbolIcon_File
    hi! link SymbolIcon_TypeParameter SymbolIcon_File
    hi! link SymbolIcon_Component SymbolIcon_File
    hi! link SymbolIcon_Fragment SymbolIcon_File
]])

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

local symbol_outline_augroup = vim.api.nvim_create_augroup("symbol_outline_augroup", { clear = true })
vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = { "*" },
	callback = function()
		if vim.bo.filetype == "SymbolOutline" then
			local _, jump_buf = get_win_buf_by(vim.t.jump_buf_name)
			if jump_buf ~= -1 then
				vim.api.nvim_buf_clear_namespace(jump_buf, vim.t.focused_symbol_ns, 0, -1)
			end
		end
	end,
	group = symbol_outline_augroup,
})
