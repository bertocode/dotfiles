local modules = require("modules")

-- Register JS/Vue plugins
modules.register_plugins({
	-- {
	-- 	"volar",
	-- 	ft = { "javascript", "typescript", "vue" },
	-- 	config = function()
	-- 		require("lspconfig").volar.setup({
	-- 			filetypes = { "typescript", "javascript", "vue" },
	-- 			init_options = { vue = { hybridMode = false } },
	-- 		})
	-- 	end,
	-- },
	{
		"MunifTanjim/prettier.nvim",
		ft = { "javascript", "typescript", "vue" },
		config = function()
			require("prettier").setup({ bin = "prettierd" })
		end,
	},
})

-- Register LSP servers
modules.register_lsp({
	tsserver = {
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = "/path/to/vue/typescript-plugin",
					languages = { "vue" },
				},
			},
		},
	},
})

-- JS/Vue-specific config
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "typescript", "vue" },
	callback = function()
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
		vim.opt.expandtab = true
	end,
})

vim.keymap.set("n", "<leader>j", ":Prettier<CR>", { desc = "Format with Prettier" })
