local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local get_match_index = function(node)
	local nodeText = vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
	local matchIndexStart, matchIndexEnd = string.find(nodeText, "</")
	return matchIndexStart, matchIndexEnd
end 

local get_main_node = function()
	local node = ts_utils.get_node_at_cursor()

	if node == nil then
		error("No Treesitter found.")
	end

	local root = ts_utils.get_root_for_node(node)
	local start_row = node:start()
	local parent = node:parent()

	matchIndexStart, matchIndexEnd = get_match_index(node)

	if matchIndexStart == 1 and matchIndexEnd == 2 then
		node = parent
		parent = node:parent()
	end

	while parent ~= nil and parent ~= root and parent:start() == start_row do
		node = parent
		parent = node:parent()
		matchIndexStart, matchIndexEnd = get_match_index(node)
		if matchIndexStart == 1 and matchIndexEnd == 2 then
			node = parent
			parent = node:parent()
		end
	end

	return node
end 

M.select = function()
	local node = get_main_node()
	local bufnr = vim.api.nvim_get_current_buf()
	ts_utils.update_selection(bufnr, node)
end
M.getCode = function()
    local node = get_main_node()
    local bufnr = vim.api.nvim_get_current_buf()
    local start_row, start_col, end_row, end_col = node:range()
    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
    local text = vim.treesitter.get_node_text(node, bufnr)
    return text

end
return M

