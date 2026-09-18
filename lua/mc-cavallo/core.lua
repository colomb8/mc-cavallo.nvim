------------------------------------------------------------------------------
--[[

mc-cavallo.nvim

Author: Dario Colombotto
  email: dario.colombotto@outlook.com
  Telegram: https://t.me/colomb8

License: MIT (see LICENSE)

--]]
------------------------------------------------------------------------------

local U = require("0_utils")

------------------------------------------------------------------------------
-- mc-cavallo.nvim Variables
------------------------------------------------------------------------------

local mc_search_pattern

local M = {}

------------------------------------------------------------------------------
-- mc-cavallo.nvim Load Configuration
------------------------------------------------------------------------------

function M.setup(cfg)

  -- Cfg validation ------------------------------------------------------------

  for k, _ in pairs(cfg) do
    assert(vim.list_contains({
      'keymaps',
    }, k), 'unknown configuration key: ' .. k)
  end

  for k, _ in pairs(cfg.keymaps) do
    assert(vim.list_contains({
      'start',
      'skip',
      'up',
      'down',
      'togglefm',
      'exit',
    }, k), 'unknown keymap configuration key: ' .. k)
  end

  -- assert(
  --   vim.list_contains({'<C-n>', '...'}, cfg.keymap_mcc_start),
  --   '`c_right_mode` supports only "eow" or "bow"; received: '
  --   .. tostring(cfg.c_right_mode))

  ------------------------------------------------------------------------------
  -- mc-cavallo.nvim Functions
  ------------------------------------------------------------------------------

  local function enableFM()
    vim.cmd('normal! 1q=')
  end

  local function disableFM()
    vim.cmd('normal! 2q=')
  end

  local function mccVStart()
    --
    local mode = vim.fn.mode()
    local valid_modes = {
      ['v'] = true, -- visual
      -- ['V'] = true, -- visual line
      -- ['\22'] = true, -- visual block (^V)
      -- ['s'] = true, -- select
      -- ['S'] = true, -- select line
      -- ['\19'] = true, -- select block (^S)
    }
    assert(valid_modes[mode], 'Invalid mode: -' .. mode .. '-')
    --
    local r1, c1, r2, c2, dir = U.getSelectionBoundsAndDirection()
    U.sendKeys('<Esc>', 'nx')
    --
    local sel_text_table
    if vim.o.selection == 'inclusive' then
      sel_text_table = U.getTextFromBounds(r1, c1, r2, c2 + 1)
    elseif vim.o.selection == 'exclusive' then
      sel_text_table = U.getTextFromBounds(r1, c1, r2, c2)
    else
      error(vim.o.selection)
    end
    --
    local sel_text = table.concat(sel_text_table, '\n')
    mc_search_pattern = U.literal_search_pattern(sel_text)
    local match_pos = vim.fn.searchpos(mc_search_pattern, 'nW')
    local is_match_pos = match_pos[1] > 0
    if is_match_pos then
      if dir == 1 then
        U.setCursor(r1, c1)
      end
      return
    end
    if dir == 1 then
      U.setMCursor(r1, c1)
    elseif dir == -1 then
      U.setMCursor(r2, c2)
    else
      error(tostring(dir))
    end
    --
    disableFM()
    U.setCursor(unpack(match_pos))
    enableFM()
    --
  end

  local function mccNStart ()
    local is_fresh_start = not mc_search_pattern or U.count_mc() == 0
    local cur_match_pos
    if is_fresh_start then
      --
      local line = vim.fn.getline(".")
      local char = vim.fn.strcharpart(
        line,
        vim.fn.charcol(".") - 1,
        1
      )
      -- print("|" .. char .. "|")
      local is_word = vim.fn.match(char, [[\k]]) >= 0
      --
      if is_word then
        --
        disableFM()
        cur_match_pos = vim.fn.searchpos([[\<]], "bcnW")
        U.setCursor(unpack(cur_match_pos))
        enableFM()
        --
        mc_search_pattern = "\\V\\<" .. vim.fn.expand("<cword>") .. "\\>"
      else
        cur_match_pos = {vim.fn.line('.'), vim.fn.col('.')}
        if char == '' then
          if line:len() == 0 then
            mc_search_pattern = [[^$]]
          else
            mc_search_pattern = U.literal_search_pattern('\n')
          end
        else
          mc_search_pattern = U.literal_search_pattern(char)
        end
        -- print("|" .. mc_search_pattern .. "|")
      end
    end
    --
    local next_match_pos = vim.fn.searchpos(mc_search_pattern, 'nW')
    local is_next_match_pos = next_match_pos[1] > 0
    --
    if is_fresh_start and is_next_match_pos then
      U.setMCursor(unpack(cur_match_pos))
    end
    if not is_next_match_pos then
      return
    end
    U.setMCursor(vim.fn.line('.'), vim.fn.col('.'))
    --
    disableFM()
    U.setCursor(unpack(next_match_pos))
    enableFM()
    --
  end

  local function mccSkip()
    local is_fresh_start = not mc_search_pattern or U.count_mc() == 0
    if is_fresh_start then
      return
    end
    --
    local next_match_pos = vim.fn.searchpos(mc_search_pattern, 'nW')
    local is_next_match_pos = next_match_pos[1] > 0
    --
    if not is_next_match_pos then
      return
    end
    --
    disableFM()
    U.setCursor(unpack(next_match_pos))
    enableFM()
    --
  end

  local function mccUp()
    U.sendKeys('Qk', 'nx')
    enableFM()
  end

  local function mccDown()
    U.sendKeys('Qj', 'nx')
    enableFM()
  end

  ------------------------------------------------------------------------------
  -- mc-cavallo.nvim Keybindings
  ------------------------------------------------------------------------------

  -- Clear all active multicursors and reset search pattern
  if cfg.keymaps.exit then
    vim.keymap.set({'n', 'x', 'i'}, cfg.keymaps.exit, function ()
      U.clear_mc()
      mc_search_pattern = nil
      U.sendKeys('<Esc>', 'nx')
    end)
  end

  -- Toggle follow-mode
  if cfg.keymaps.togglefm then
    vim.keymap.set('n', cfg.keymaps.togglefm, 'q=')
  end

  if cfg.keymaps.up then
    -- Add a cursor and go up
    vim.keymap.set('n', cfg.keymaps.up, mccUp)
  end

  if cfg.keymaps.down then
    -- Add a cursor and go down
    vim.keymap.set('n', cfg.keymaps.down, mccDown)
  end

  if cfg.keymaps.start then
    -- Add a cursor in the current word and
    -- jump to the next occurrence
    vim.keymap.set('n', cfg.keymaps.start, mccNStart)
    -- Add a cursor in the current Visual selection,
    -- exit visual and jump to the next occurrence
    vim.keymap.set('x', cfg.keymaps.start, mccVStart)
  end

  if cfg.keymaps.skip then
    -- Skip occurrence and jump to the next
    vim.keymap.set('n', cfg.keymaps.skip, mccSkip)
  end

  ------------------------------------------------------------------------------
  -- Scratch / Notes
  ------------------------------------------------------------------------------

end

  ------------------------------------------------------------------------------
  -- End
  ------------------------------------------------------------------------------

return M
