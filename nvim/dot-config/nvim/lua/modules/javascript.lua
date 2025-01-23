-- ~/.config/nvim/lua/modules/javascript.lua

-- JavaScript/Vue-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    callback = function()
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
    end,
})

-- JavaScript/Vue-specific keybindings
local keymap = vim.keymap
keymap.set("n", "<leader>j", ":Prettier<CR>", { desc = "Format with Prettier" })

-- JavaScript/Vue-specific plugins (if any)

