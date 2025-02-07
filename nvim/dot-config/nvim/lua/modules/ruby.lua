local modules = require("modules")

-- Register LSP server
modules.register_lsp({
	ruby_lsp = {
		mason = false,
		cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
		filetypes = { "ruby", "eruby" },
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
