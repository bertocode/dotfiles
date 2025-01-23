-- ~/.config/nvim/lua/modules/lsp.lua

-- LSP Settings
local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Servers Configuration
local servers = {
	volar = {
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		init_options = {
			vue = {
				hybridMode = false,
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
			},
		},
	},
	ruby_lsp = {
		settings = {
			ruby = {
				lsp = {
					diagnostics = false,
					codeActions = false,
				},
			},
		},
	},
	ts_ls = {
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = "/Users/berto/.nvm/versions/node/v20.18.1/lib/@vue/typescript-plugin",
					languages = { "vue" },
				},
			},
		},
		filetypes = {
			"typescript",
			"javascript",
			"vue",
		},
	},
}

-- Setup Mason
mason.setup()

-- Ensure LSP servers are installed
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
	"volar",
	-- "stylua",
})
mason_tool_installer.setup({ ensure_installed = ensure_installed })

-- Setup Mason LSP Config
mason_lspconfig.setup({
	ensure_installed = ensure_installed,
	automatic_installation = true,
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			server.capabilities = vim.tbl_deep_extend("force", capabilities, server.capabilities or {})
			lspconfig[server_name].setup(server)
		end,
	},
})

-- LSP Attach Autocommands
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local buffer = event.buf
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		-- Define keymaps specific to LSP
		local opts = { buffer = buffer, noremap = true, silent = true }
		local keymap = vim.keymap

		keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "Go to Definition" })
		keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "Find References" })
		keymap.set("n", "gI", require("telescope.builtin").lsp_implementations, { desc = "Go to Implementation" })
		keymap.set("n", "<leader>D", require("telescope.builtin").lsp_type_definitions, { desc = "Type Definitions" })
		keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, { desc = "Document Symbols" })
		keymap.set(
			"n",
			"<leader>ws",
			require("telescope.builtin").lsp_dynamic_workspace_symbols,
			{ desc = "Workspace Symbols" }
		)
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
		keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
		keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })

		-- Inlay Hints Toggle
		if client.supports_method("textDocument/inlayHint") then
			keymap.set("n", "<leader>th", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buffer })
				vim.lsp.inlay_hint(buffer, not enabled)
			end, { desc = "Toggle Inlay Hints" })
		end

		-- Highlight on Cursor Hold
		if client.supports_method("textDocument/documentHighlight") then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = buffer,
				group = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false }),
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = buffer,
				group = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false }),
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})
