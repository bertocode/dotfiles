-- Set leader keys early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core settings and keymaps
require('core.options')
require('core.settings')
require('core.keymaps')

-- Setup plugin manager and plugins
require('plugins')

-- Load environment-specific modules
-- You can control which modules to load based on environment variables or other conditions
-- For example:
-- if vim.fn.getenv("PROJECT") == "ruby" then
--     require('modules.ruby')
-- elseif vim.fn.getenv("PROJECT") == "c" then
--     require('modules.c')
-- end

-- Alternatively, load all and let each module handle its own conditions
require('modules.c')
require('modules.ruby')
require('modules.javascript')

