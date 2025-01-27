local modules = require("modules")

-- Register Ruby plugins
modules.register_plugins({
	{
		"rubocop.nvim",
		ft = "ruby",
		config = function()
			require("rubocop").setup({
				auto_format = true,
				use_bundler = true,
			})
		end,
	},
})

-- Register LSP server
modules.register_lsp({
	ruby_lsp = {
		settings = {
			ruby = {
				lsp = { diagnostics = false, codeActions = false },
			},
		},
	},
})

-- Ruby-specific config
vim.api.nvim_create_autocmd("FileType", {
	pattern = "ruby",
	callback = function()
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
		vim.opt.expandtab = true
	end,
})

vim.keymap.set("n", "<leader>r", ":RubocopAutocorrect<CR>", { desc = "Auto-correct with RuboCop" })
