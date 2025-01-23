-- ~/.config/nvim/lua/modules/ruby.lua

-- Example: Ruby-specific settings
vim.api.nvim_create_autocmd("FileType", {
	pattern = "ruby",
	callback = function()
		-- Ruby-specific settings
		vim.opt.tabstop = 2
		vim.opt.shiftwidth = 2
		vim.opt.expandtab = true
	end,
})

-- Example: Ruby-specific keybindings
local keymap = vim.keymap
keymap.set("n", "<leader>r", ":RubocopAutocorrect<CR>", { desc = "Auto-correct with RuboCop" })

-- Example: Ruby-specific plugins (if any)
-- You can conditionally load plugins using Lazy.nvim's `ft` or `cond` options
-- require("lazy").load({ plugins = { "ruby-plugin-name" } })
