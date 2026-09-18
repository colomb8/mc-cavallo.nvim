------------------------------------------------------------------------------
--[[

mc-cavallo.nvim

Author: Dario Colombotto
  email: dario.colombotto@outlook.com
  Telegram: https://t.me/colomb8

License: MIT (see LICENSE)

--]]
------------------------------------------------------------------------------

-- Check requirements

local v = vim.version()
if v.major == 0 and v.minor < 13 then
  error("mc-cavallo.nvim requires Neovim >= 0.13")
end

------------------------------------------------------------------------------

local M = {}

function M.setup(user_opts)

  local config = vim.tbl_deep_extend("force", {
    -- omit entries to use their default values
    keymaps = {
      -- set to false for disable a keymap
      start = '<C-n>', -- Normal and Visual mode
      skip = '<C-s>', -- Normal mode
      up = '<M-S-k>', -- Normal mode
      down = '<M-S-j>', -- Normal mode
      togglefm = '<C-q>', -- Normal mode
      exit = '<C-q><C-q>', -- Normal, Visual and Insert mode
    },
  }, user_opts or {})

  local core = require("mc-cavallo.core")

  core.setup(config)

end

return M
