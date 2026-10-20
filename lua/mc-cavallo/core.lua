------------------------------------------------------------------------------
--[[

mc-cavallo.nvim

Author: Dario Colombotto
  email: dario.colombotto@outlook.com
  Telegram: https://t.me/colomb8

License: MIT (see LICENSE)

--]]
------------------------------------------------------------------------------

local common = require("mc-cavallo.common")

------------------------------------------------------------------------------
-- Define Variables
------------------------------------------------------------------------------

local M = {}

local config = {}

local mc_search_pattern

------------------------------------------------------------------------------
-- Define Functions
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
  local r1, c1, r2, c2, dir = common.getSelectionBoundsAndDirection()
  common.sendKeys('<Esc>', 'nx')
  --
  local sel_text_table
  if vim.o.selection == 'inclusive' then
    sel_text_table = common.getTextFromBounds(r1, c1, r2, c2 + 1)
  elseif vim.o.selection == 'exclusive' then
    sel_text_table = common.getTextFromBounds(r1, c1, r2, c2)
  else
    error(vim.o.selection)
  end
  --
  local sel_text = table.concat(sel_text_table, '\n')
  mc_search_pattern = common.literal_search_pattern(sel_text)
  -- print("|" .. tostring(mc_search_pattern) .. "|")
  local match_pos = vim.fn.searchpos(mc_search_pattern, 'nW')
  local is_match_pos = match_pos[1] > 0
  if not is_match_pos then
    if dir == 1 then
      common.setCursor(r1, c1)
    end
    return
  end
  if dir == 1 then
    common.setMCursor(r1, c1)
  elseif dir == -1 then
    common.setMCursor(r2, c2)
  else
    error(tostring(dir))
  end
  --
  disableFM()
  common.setCursor(unpack(match_pos))
  enableFM()
  --
end

local function mccNStart ()
  -- print("|" .. tostring(mc_search_pattern) .. "|")
  local is_fresh_start = not mc_search_pattern or common.count_mc() == 0
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
      common.setCursor(unpack(cur_match_pos))
      enableFM()
      --
      mc_search_pattern = "\\V\\<" .. vim.fn.expand("<cword>") .. "\\>"
      -- print("|" .. tostring(mc_search_pattern) .. "|")
    else
      cur_match_pos = {vim.fn.line('.'), vim.fn.col('.')}
      if char == '' then
        if line:len() == 0 then
          mc_search_pattern = [[^$]]
        else
          mc_search_pattern = common.literal_search_pattern('\n')
        end
      else
        mc_search_pattern = common.literal_search_pattern(char)
      end
      -- print("|" .. mc_search_pattern .. "|")
    end
  end
  --
  -- print("|" .. tostring(mc_search_pattern) .. "|")
  local next_match_pos = vim.fn.searchpos(mc_search_pattern, 'nW')
  local is_next_match_pos = next_match_pos[1] > 0
  --
  if is_fresh_start and is_next_match_pos then
    common.setMCursor(unpack(cur_match_pos))
  end
  if not is_next_match_pos then
    return
  end
  common.setMCursor(vim.fn.line('.'), vim.fn.col('.'))
  --
  disableFM()
  common.setCursor(unpack(next_match_pos))
  enableFM()
  --
end

local function mccSkip()
  local is_fresh_start = not mc_search_pattern or common.count_mc() == 0
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
  common.setCursor(unpack(next_match_pos))
  enableFM()
  --
end

local function mccUp()
  common.sendKeys('Qk', 'nx')
  enableFM()
end

local function mccDown()
  common.sendKeys('Qj', 'nx')
  enableFM()
end

local function setKeybindings()

  -- Clear all active multicursors and reset search pattern
  if config.keymaps.exit then
    vim.keymap.set({'n', 'x', 'i'}, config.keymaps.exit, function ()
      common.sendKeys('<Esc>', 'n')
      mc_search_pattern = nil
      vim.schedule(common.clear_mc)
    end)
  end

  -- Toggle follow-mode
  if config.keymaps.togglefm then
    vim.keymap.set('n', config.keymaps.togglefm, 'q=')
  end

  if config.keymaps.up then
    -- Add a cursor and go up
    vim.keymap.set('n', config.keymaps.up, mccUp)
  end

  if config.keymaps.down then
    -- Add a cursor and go down
    vim.keymap.set('n', config.keymaps.down, mccDown)
  end

  if config.keymaps.start then
    -- Add a cursor in the current word and
    -- jump to the next occurrence
    vim.keymap.set('n', config.keymaps.start, mccNStart)
    -- Add a cursor in the current Visual selection,
    -- exit visual and jump to the next occurrence
    vim.keymap.set('x', config.keymaps.start, mccVStart)
  end

  if config.keymaps.skip then
    -- Skip occurrence and jump to the next
    vim.keymap.set('n', config.keymaps.skip, mccSkip)
  end

end
------------------------------------------------------------------------------
-- Load Configuration
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

  config = cfg

  setKeybindings()

end

------------------------------------------------------------------------------
-- Scratch / Notes
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- End
------------------------------------------------------------------------------

return M
