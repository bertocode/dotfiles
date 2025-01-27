-- lua/modules/init.lua
local M = {
  enabled_plugins = {},
  enabled_lsp = {}, -- Add this line to store LSP configurations
  list = {}
}

-- Load environment config
local env = require("env")

-- Convert enabled modules to list
for module, enabled in pairs(env.enable) do
  if enabled then
    table.insert(M.list, module)
  end
end

-- Check if module is enabled
function M.has(module)
  return vim.tbl_contains(M.list, module)
end

-- Register plugins
function M.register_plugins(plugins)
  M.enabled_plugins = M.enabled_plugins or {}
  vim.list_extend(M.enabled_plugins, plugins)
end

-- Register LSP configurations
function M.register_lsp(lsp_configs)
  M.enabled_lsp = M.enabled_lsp or {}
  for server, config in pairs(lsp_configs) do
    M.enabled_lsp[server] = config
  end
end

-- Load enabled modules
function M.load()
  if M.has("c") then require("modules.c") end
  if M.has("ruby") then require("modules.ruby") end
  if M.has("javascript") then require("modules.javascript") end
end

return M
