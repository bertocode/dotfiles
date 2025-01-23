-- ~/.config/nvim/lua/modules/c.lua

-- C/C++-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = false
    end,
})

-- C/C++-specific keybindings
local keymap = vim.keymap
keymap.set("n", "<leader>c", ":ClangFormat<CR>", { desc = "Format with ClangFormat" })

-- C/C++-specific plugins (if any)

