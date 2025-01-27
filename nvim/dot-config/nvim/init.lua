-- ~/.config/nvim/init.lua

-- 1. Bootstrap Lazy.nvim
require("core.bootstrap").setup()

-- 2. Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 3. Load core settings
require("core.options")
require("core.keymaps")

-- 4. Load enabled modules
require("modules").load()

-- 5. Initialize plugins
require("plugins")

-- 6. Final settings
require("core.settings")

-- 7. LSP conniguration
require("modules.lsp")
