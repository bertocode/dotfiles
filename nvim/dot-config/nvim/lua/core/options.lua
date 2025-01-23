-- [[ Basic Options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 10
vim.opt.timeoutlen = 200
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true

-- Language settings
vim.cmd("language en_US")

-- Update PATH for rbenv (Ruby)
local rbenv_bin = os.getenv("HOME") .. "/.rbenv/bin"
local rbenv_shims = os.getenv("HOME") .. "/.rbenv/shims"
vim.env.PATH = rbenv_bin .. ":" .. rbenv_shims .. ":" .. vim.env.PATH
