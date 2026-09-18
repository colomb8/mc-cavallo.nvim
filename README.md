# mc-cavallo.nvim

Native Neovim multicursors for humans (and horses)

---

<p align="center">
  <img
    src="media/mcc.jpg"
    alt="insert mode with no mercy"
    width="250"
  />
</p>

>Image used under fair use, for illustrative and non-commercial purposes. All rights to the character and image belong to their respective owners.
---

## Vision

Neovim has native multicursor support. mc-cavallo makes it more practical.

The goal is to provide a small, intuitive layer on top of Neovim's native multicursors: familiar keybindings, sensible cursor movement, occurrence selection, and an easy way to get in and out.

## Features

- *Select next occurrence* - start from the word under the cursor or from a Visual selection, and progressively add matching occurrences.
- *Skip occurrences* - jump over a match without adding a cursor and continue to the next one.
- *Add cursors vertically* - quickly add a cursor above or below the current one.
- *Clean exit* - clear all multicursors and reset the active occurrence search in one action.
- *Configurable keymaps* - every provided mapping can be customized or disabled.

## Installation and Configuration

Using vim.pack

```lua
vim.pack.add("https://github.com/colomb8/mc-cavallo.nvim",)

require("mc-cavallo").setup({
  -- omit keys for default values
  keymaps = {
    -- set to false for disable keymap
    start = '<C-n>', -- Normal and Visual mode
    skip = '<C-s>', -- Normal mode
    up = '<M-S-k>', -- Normal mode
    down = '<M-S-j>', -- Normal mode
    togglefm = '<C-q>', -- Normal mode
    exit = '<C-q><C-q>', -- Normal, Visual and Insert mode
  },
})
```

>setup() is required - call it without arguments to use the default behavior.

- `start`:
  - If in Visual mode, add a cursor in the current Visual selection, exit visual and jump to the next occurrence
  - If in Normal mode, add a cursor in the current word and jump to the next occurrence
  - modes: Normal and Visual mode
  - default: '<C-n>'
- `skip`:
  - Skip occurence and jump to the next
  - modes: Normal mode
  - default: '<C-s>'
- `up`:
  - Add a cursor and go up
  - modes: Normal mode
  - default: '<M-S-k>'
- `down`:
  - Add a cursor and go down
  - modes: Normal mode
  - default: <M-S-j>'
- `togglefm`:
  - Toggle Neovim's native follow-mode for multicursors
  - modes: Normal mode
  - default: '<C-q>'
- `exit`:
  - Clear all active multicursors and reset search pattern
  - modes: Normal, Visual and Insert mode
  - default: '<C-q><C-q>'

## Roadmap

- `:help` Vim documentation - provide Vim help file (`:help mc-cavallo.txt`) for discoverability.

## License

[MIT](LICENSE)
