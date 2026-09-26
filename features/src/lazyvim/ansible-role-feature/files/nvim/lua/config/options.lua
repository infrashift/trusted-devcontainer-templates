-- Loaded by LazyVim before lazy.nvim starts.
-- Managed by the infrashift 'lazyvim' devcontainer feature.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- The python extra (extras=lang.python) reads these when its spec loads, which
-- is after this file. basedpyright is what the 'python-tools' feature installs;
-- ruff comes from the trusted 'uv-ruff' feature. Harmless for other languages.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
