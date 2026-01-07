-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",
	theme_toggle = { "catppuccin", "one_light" },

	hl_override = {
		-- Diff highlighting with dark text for readability
		DiffAdd = { fg = "#1e1e2e", bg = "#a6e3a1" }, -- dark text on green
		DiffDelete = { fg = "#1e1e2e", bg = "#f38ba8" }, -- dark text on red
		DiffChange = { fg = "#1e1e2e", bg = "#89b4fa" }, -- dark text on blue
		DiffText = { fg = "#1e1e2e", bg = "#f9e2af", bold = true }, -- dark text on yellow
	},
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
