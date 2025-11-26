#!/usr/bin/env bash

set -Eeuo pipefail

# Default config path
DEFAULT_CONFIG_PATH="~/.config/nvim"

# Use first argument as config path, or default
NVIM_CONFIG_PATH="${1:-$DEFAULT_CONFIG_PATH}"

# Expand config path
CONFIG_PATH="${NVIM_CONFIG_PATH/#\~/$HOME}"

echo "Using Neovim config at: $CONFIG_PATH"

# Extract plugin URLs
nvim --headless -u "$CONFIG_PATH/init.lua" --cmd "set runtimepath+=$CONFIG_PATH" -c 'lua vim.defer_fn(function()
  for _, plugin in ipairs(require("lazy").plugins()) do
    io.write(plugin.url .. "\n")
  end
  vim.cmd("qall")
end, 100)' >plugins.txt || true

# Filter GitHub URLs and convert to owner/repo format
grep -E "^https://github.com/" plugins.txt |
  sed 's|https://github.com/||' |
  sed 's|\.git$||' >github_repos.txt

rm plugins.txt

echo "Found $(wc -l <github_repos.txt) GitHub plugins"
cat github_repos.txt
echo ""
echo "Outputting to: github_repos.txt"
