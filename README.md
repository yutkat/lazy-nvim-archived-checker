# Lazy.nvim Archived Plugin Checker

A GitHub Action to check if your Neovim plugins managed by lazy.nvim are archived or deleted.

## Features

- Automatically extracts plugin list from your Neovim config
- Detects archived repositories
- Detects deleted repositories
- Outputs GitHub Actions warnings for archived plugins
- Outputs GitHub Actions errors for deleted plugins
- Uses problem matchers for better visibility in Actions UI
- Runs on a schedule (weekly by default)

## Usage

### Basic Setup

1. Create a workflow file in your repository (e.g., `.github/workflows/check-plugins.yml`):

```yaml
name: Check Neovim Plugins

on:
  schedule:
    - cron: "0 9 * * 1" # Every Monday at 9:00 AM UTC
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  check-plugins:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Neovim config
        uses: actions/checkout@v6
        with:
          repository: yourusername/dotfiles
          path: dotfiles

      - name: Check plugins
        uses: yutkat/lazy-nvim-archived-checker@v1
        with:
          nvim-config-path: ${{ github.workspace }}/dotfiles/.config/nvim/
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input              | Description                     | Required | Default               |
| ------------------ | ------------------------------- | -------- | --------------------- |
| `nvim-config-path` | Path to Neovim config directory | No       | `~/.config/nvim`      |
| `github-token`     | GitHub token for API requests   | No       | `${{ github.token }}` |

### Outputs

| Output             | Description                    |
| ------------------ | ------------------------------ |
| `archived-plugins` | JSON array of archived plugins |
| `deleted-plugins`  | JSON array of deleted plugins  |
| `has-issues`       | Whether any issues were found  |

## How It Works

1. Sets up a problem matcher for better visibility in GitHub Actions UI
2. Extracts plugin URLs from your lazy.nvim configuration using Neovim's headless mode
3. Parses GitHub repository information from the URLs
4. Checks each repository via GitHub API for:
   - Repository existence (deleted check)
   - Archive status
5. Outputs warnings/errors using GitHub Actions annotations:
   - **Archived plugins**: Warning annotation
   - **Deleted plugins**: Error annotation
6. Uses `::add-matcher::` for enhanced problem reporting in the Actions interface
