-- lua/modules/lsp.lua
local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

-- Base capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Define LSP servers
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false },
			},
		},
	},
	clangd = {}, -- C/C++ LSP
	-- Add other LSP servers here
}

-- Mason setup
mason.setup()

-- Ensure LSP servers are installed
mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_installation = true,
})

-- Configure LSP servers
mason_lspconfig.setup_handlers({
	function(server_name)
		local server = servers[server_name] or {}
		server.capabilities = vim.tbl_deep_extend("force", capabilities, server.capabilities or {})
		lspconfig[server_name].setup(server)
	end,
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
