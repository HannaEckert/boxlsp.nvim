
local C = {}

-- Some basic dependency checking
if not package.loaded["lspconfig"] then
	print("This plugin needs 'neovim/nvim-lspconfig' to work.")
	return {}
end

if not package.loaded["cmp_nvim_lsp"] then
	print("This plugin needs 'hrsh7th/cmp-nvim-lsp' to work.")
	return {}
end


local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")
local capabilities = require("cmp_nvim_lsp").default_capabilities()


-- Helper functions

local get_plugin_path = function()
	local current_file = debug.getinfo(1).source:sub(2)
	return current_file:match("(.*/)") .. "../../"
end


-- The main setup function
function C.setup()
	-- Add boxlang filetypes
	vim.filetype.add({
		extension = {
			bxm = "boxlang",
			bx = "boxlang",
			bxs = "boxlang",
		},
	})

	local lsp_dir = get_plugin_path() .. "lsp"

	if not configs.boxlsp then
		configs.boxlsp = {
			default_config = {
				cmd = { lsp_dir .. "/lsp" },
				root_dir = lspconfig.util.root_pattern(".git", ".config"),
				filetypes = { "boxlang" },
			},
		}
	end

	lspconfig.boxlsp.setup({ capabilities = capabilities })
end

return C
