# ampcode-cli.nvim

A Neovim plugin for running interactive terminal commands in the background and displaying output in a dedicated pane.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "path/to/ampcode-cli.nvim",
  config = function()
    require("ampcode-cli").setup({
      height = 15,
      position = "bottom", -- "bottom", "top", "left", "right", "float"
      auto_scroll = true,
    })
  end,
}
```

## Commands

- `:AmpcodeRun <command>` - Run a command and display output
- `:AmpcodeToggle` - Toggle the output window visibility

## Configuration

```lua
require("ampcode-cli").setup({
  height = 15,              -- Window height for split modes
  position = "bottom",      -- Window position: "bottom", "top", "left", "right", "float"
  auto_scroll = true,       -- Auto-scroll to bottom as output arrives
})
```

## Usage

```vim
:AmpcodeRun npm run dev
:AmpcodeRun python manage.py runserver
:AmpcodeToggle
```
