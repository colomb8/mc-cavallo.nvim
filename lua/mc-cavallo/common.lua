------------------------------------------------------------------------------
--[[

mc-cavallo.nvim

Author: Dario Colombotto
  email: dario.colombotto@outlook.com
  Telegram: https://t.me/colomb8

License: MIT (see LICENSE)

--]]
------------------------------------------------------------------------------

local M = {}

function M.literal_search_pattern(text)
  return [[\V]] .. text
    :gsub("\\", [[\\]])
    :gsub("\n", [[\n]])
end

function M.is_onemore_or_empty()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return col >= #line
end

function M.count_mc()
  local ns = vim.api.nvim_create_namespace("nvim.multicursor")
  local cursors = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
  return #cursors
end

function M.clear_mc()
  local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")
  vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
end

function M.setMCursor(row, col)
  vim.api.nvim_mcursor(0, {
    row, -- 1-based
    col - 1, -- 0-based
  })
end

function M.setCursor(row, col)
  vim.api.nvim_win_set_cursor(
    0, -- buffer, 0 for current
    {
      row, -- 1-based
      col - 1, -- 0-based
    })
end

function M.sendKeys(keys, mode)
  -- Use 'x' for visual!
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    mode,
    true)
end

local function getSelectionRawBounds()
  -- raw! no logic here!
  local mode = vim.fn.mode()
  local valid_modes = {
    ['v'] = true, -- visual
    ['V'] = true, -- visual line
    ['\22'] = true, -- visual block (^V)
    ['s'] = true, -- select
    ['S'] = true, -- select line
    ['\19'] = true, -- select block (^S)
    }
  assert(valid_modes[mode], 'Invalid mode: -' .. mode .. '-')
  --
  local _, r1, c1, _ = unpack(vim.fn.getpos("v"))
  local _, r2, c2, _ = unpack(vim.fn.getpos("."))
  --
  return r1, c1, r2, c2
end

local function normalizeBoundsGetDirection(r1, c1, r2, c2)
  local dir, _r1, _c1, _r2, _c2
  -- sort bounds
  if r1 < r2 or (r1 == r2 and c1 <= c2) then
    dir = 1
    _r1, _c1, _r2, _c2 = r1, c1, r2, c2
  else
    dir = -1
    _r1, _c1, _r2, _c2 = r2, c2, r1, c1
  end
  _c2 = _c2 - 1
  return _r1, _c1, _r2, _c2, dir
end

function M.getSelectionBoundsAndDirection()
  -- this is only a quicker way to get normalized bounds.
  -- no logic here!
  local r1, c1, r2, c2 = getSelectionRawBounds()
  local _r1, _c1, _r2, _c2, dir = normalizeBoundsGetDirection(r1, c1, r2, c2)
  return _r1, _c1, _r2, _c2, dir
end

function M.getTextFromBounds(r1, c1, r2, c2)
  local tmp = vim.api.nvim_buf_get_text(
    0, -- buffer, 0 for current
    r1 - 1, -- start_row, 0-based, inclusive
    c1 - 1, -- start_col, 0-based, inclusive
    r2 - 1, -- end_row, 0-based, inclusive
    c2, -- end_col, 0-based, exclusive
    {} -- opts
    )
  return tmp
end

function M.getSelectionText()
  local mode = vim.fn.mode()
  local valid_modes = {
    ['v'] = true, -- visual
    ['V'] = true, -- visual line
    -- ['\22'] = true, -- visual block (^V)
    ['s'] = true, -- select
    ['S'] = true, -- select line
    -- ['\19'] = true, -- select block (^S)
    }
  assert(valid_modes[mode], 'Invalid mode: -' .. mode .. '-')
  --
  local r1, c1, r2, c2, _ = M.getSelectionBoundsAndDirection()
  --
  if mode == 'V' or mode == 'S' then
    c1 = 1
    c2 = vim.fn.getline(r2):len() + 1
  end
  --
  if vim.o.selection == 'inclusive' then
    return M.getTextFromBounds(r1, c1, r2, c2 + 1)
  elseif vim.o.selection == 'exclusive' then
    return M.getTextFromBounds(r1, c1, r2, c2)
  else
    error(vim.o.selection)
  end
end

return M
