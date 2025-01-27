-- lua/modules/c.lua
local modules = require("modules")
local env = require("env")
-- Register C plugins
modules.register_plugins({
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		config = function()
			require("clangd_extensions").setup({
				server = {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
				},
			})
		end,
	},
})

-- Register 42-school plugins if enabled
modules.register_plugins({
	{
		"Diogo-ss/42-header.nvim",
		cmd = { "Stdheader" },
		keys = { "<F1>" },
		opts = {
			default_map = true,
			auto_update = true,
			user = env.user.name,
			mail = env.user.email,
		},
		config = function(_, opts)
			require("42header").setup(opts)
		end,
	},
	{
		"hardyrafael17/norminette42.nvim",
		config = function()
			require("norminette").setup({
				runOnSave = true,
				maxErrorsToShow = 5,
				active = true,
			})
		end,
	},
})

-- C-specific config
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.opt.tabstop = 4
		vim.opt.shiftwidth = 4
		vim.opt.expandtab = false
	end,
})

vim.keymap.set("n", "<leader>c", ":ClangFormat<CR>", { desc = "Format with ClangFormat" })
