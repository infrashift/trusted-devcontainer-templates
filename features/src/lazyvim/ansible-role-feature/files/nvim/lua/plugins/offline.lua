-- Managed by the infrashift 'lazyvim' devcontainer feature. Edits are
-- overwritten on rebuild.
--
-- Keeps the editor from installing anything at runtime that the image did not
-- pin. LazyVim would otherwise download language servers and formatters through
-- Mason, and a native fuzzy matcher for blink.cmp, the first time they are
-- needed -- none of it versioned by this image, checksummed, or in its SBOM.
--
-- The tools themselves are on PATH instead: gopls, gofumpt, goimports, dlv and
-- golangci-lint from the 'go-tools' feature; stylua, shfmt and tree-sitter from
-- this one.
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      for name, server in pairs(opts.servers) do
        if name ~= "*" and type(server) == "table" then
          server.mason = false
        end
      end
      -- LazyVim enables lua_ls by default. No lua-language-server is installed
      -- here, so enabling it would only produce a spawn error per Lua buffer.
      opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, { enabled = false })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      fuzzy = { implementation = "lua" },
    },
  },
}
