# mc-cavallo.nvim

Native Neovim multicursors for humans (and horses)

---

<p align="center">
  <img
    src="media/mcc.jpg"
    alt="Mc Cavallo"
    width="250"
  />
</p>

>Image used under fair use, for illustrative and non-commercial purposes. All rights to the character and image belong to their respective owners.
---

## Vision

Neovim has native multicursor support. `mc-cavallo` 🐎 makes it practical.

The goal is to provide a small, intuitive layer on top of Neovim's native multicursors: familiar keybindings, sensible cursor movement, occurrence selection, and an easy way to get in and out.

## Features

- **Add a cursor and select the next occurrence**: start from the word under the cursor or from a Visual selection, and progressively add matching occurrences.
- **Follow mode by default**: keeps multicursor movement synchronized while working with multiple cursors.
- **Skip occurrences**: jump over a match without adding a cursor and continue to the next one.
- **Add cursors vertically**: quickly add a cursor above or below the current one.
- **Clean exit**: clear all multicursors and reset the active occurrence search in one action.
- **Configurable keymaps**: every provided mapping can be customized or disabled.

## Requirements

- Neovim >= 0.13

## Installation and Configuration

Using `vim.pack`:

```lua
vim.pack.add("https://github.com/colomb8/mc-cavallo.nvim")

require("mc-cavallo").setup({
  -- omit entries to use their default values
  keymaps = {
    -- set to false to disable a keymap
    start = '<C-n>', -- Normal and Visual mode
    skip = '<C-s>', -- Normal mode
    up = '<M-S-k>', -- Normal mode
    down = '<M-S-j>', -- Normal mode
    togglefm = '<C-q>', -- Normal mode
    exit = '<C-q><C-q>', -- Normal, Visual and Insert mode
  },
})
```

> `setup()` is required. Call it without arguments to use the default configuration.

- `start`:
  - Visual mode: adds a cursor in the current Visual selection, exits visual mode and jumps to the next occurrence
  - Normal mode: adds a cursor in the current word and jumps to the next occurrence
  - modes: Normal and Visual mode
  - default: `<C-n>`
- `skip`:
  - Skips occurrence and jumps to the next
  - modes: Normal mode
  - default: `<C-s>`
- `up`:
  - Adds a cursor and goes up
  - modes: Normal mode
  - default: `<M-S-k>`
- `down`:
  - Adds a cursor and goes down
  - modes: Normal mode
  - default: `<M-S-j>`
- `togglefm`:
  - Toggles Neovim's native follow-mode for multicursors
  - modes: Normal mode
  - default: `<C-q>`
- `exit`:
  - Clears all active multicursors and resets the search pattern
  - modes: Normal, Visual and Insert mode
  - default: `<C-q><C-q>`

## Roadmap

- **Vim documentation**: add a help file for `:help mc-cavallo`.
- **Main cursor rotation**: cycle the main cursor through the active multicursors.
- **Previous occurrences**: support selecting and skipping occurrences backwards.

## License

[MIT](LICENSE)
