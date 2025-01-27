local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Load core modules first
local modules = require("modules")

-- Base plugins that are always loaded
local base_plugins = {
	-- Core functionality
	"tpope/vim-sleuth",

	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "?" },
				changedelete = { text = "~" },
			},
		},
	},

	-- Keybinding help
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		config = function()
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>c", { name = "[C]ode" } },
				{ "<leader>d", { name = "[D]ocument" } },
				{ "<leader>r", { name = "[R]ename" } },
				{ "<leader>s", { name = "[S]earch" } },
				{ "<leader>w", { name = "[W]orkspace" } },
				{ "<leader>t", { name = "[T]oggle" } },
				{ "<leader>h", { name = "Git [H]unk", mode = { "n", "v" } } },
			})
		end,
	},

	-- File searching
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable telescope extensions
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- Telescope keymaps
			local builtin = require("telescope.builtin")
			local keymap = vim.keymap

			keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config"), hidden = true })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP infrastructure
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = { library = { { path = "luvit-meta/library", words = { "vim%.uv" } } } },
			},
			{ "Bilal2453/luvit-meta", lazy = true },
		},
		config = function()
			require("modules.lsp")
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- Formatters for other languages added in their modules
			},
		},
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			require("modules.autocompletion")
		end,
	},

	-- UI
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd.hi("Comment gui=none")
		end,
	},

	-- Navigation
	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
			-- Harpoon keymaps
			vim.keymap.set("n", "<leader>a", function()
				require("harpoon"):list():add()
			end, { desc = "Harpoon [A]dd file" })
			vim.keymap.set("n", "<leader>e", function()
				require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
			end, { desc = "Harpoon [E]xplore" })
			vim.keymap.set("n", "<leader>1", function()
				require("harpoon"):list():select(1)
			end, { desc = "Harpoon [1]" })
			vim.keymap.set("n", "<leader>2", function()
				require("harpoon"):list():select(2)
			end, { desc = "Harpoon [2]" })
			vim.keymap.set("n", "<leader>3", function()
				require("harpoon"):list():select(3)
			end, { desc = "Harpoon [3]" })
			vim.keymap.set("n", "<leader>4", function()
				require("harpoon"):list():select(4)
			end, { desc = "Harpoon [4]" })
		end,
	},

	-- Code analysis
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
			{ "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Toggle Workspace Diagnostics" },
			{ "<leader>cs", "<cmd>TroubleToggle symbols<cr>", desc = "Toggle Symbols" },
			{ "<leader>cl", "<cmd>TroubleToggle lsp_definitions<cr>", desc = "Toggle LSP Definitions" },
			{ "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Toggle Location List" },
			{ "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Toggle Quickfix List" },
		},
	},

	-- Utilities
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Mini.ai (text objects)
			require("mini.ai").setup({ n_lines = 500 })

			-- Mini.surround (surround text)
			require("mini.surround").setup()

			-- Mini.statusline (statusline)
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	{
		"FabijanZulj/blame.nvim",
		lazy = false,
		config = function()
			require("blame").setup({})
		end,
	},
	{
		"AdiY00/copy-tree.nvim",
		cmd = { "CopyTree", "SaveTree" },
		config = function()
			require("copy-tree").setup()
		end,
		-- Example keymap
		vim.keymap.set(
			"n",
			"<leader>ct",
			"<cmd>CopyTree<cr>",
			{ desc = "Copy project structure from current directory" }
		),
	},
	-- Syntax parsing
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"git_config",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)
			require("nvim-treesitter.install").prefer_git = true
			require("nvim-treesitter.configs").setup(opts)

			-- Set filetype for gitcommit to git_config
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "gitcommit",
				callback = function()
					vim.bo.filetype = "git_config"
				end,
			})
		end,
	},
}

-- Merge base plugins with module-registered plugins
local all_plugins = vim.list_extend(base_plugins, modules.enabled_plugins or {})

-- Initialize Lazy.nvim
require("lazy").setup(all_plugins, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "?",
			config = "??",
			event = "??",
			ft = "??",
			init = "?",
			keys = "??",
			plugin = "??",
			runtime = "??",
			require = "??",
			source = "??",
			start = "??",
			task = "??",
			lazy = "?? ",
		},
	},
})
