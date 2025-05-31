local M = {}

local buf = nil
local win = nil

-- Default configuration
local config = {
  height = 15,
  position = 'bottom', -- 'bottom', 'top', 'left', 'right', 'float'
}

-- Setup function for user configuration
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

-- Create terminal in current window
local function create_terminal_in_current_window(command)
  -- Use current window but create new buffer
  win = vim.api.nvim_get_current_win()
  
  -- Create a new buffer for the terminal
  buf = vim.api.nvim_create_buf(false, true)
  
  -- Set the new buffer in the current window
  vim.api.nvim_win_set_buf(win, buf)
  
  -- Start terminal in the new buffer
  vim.fn.termopen(command)
  
  -- Disable treesitter highlighting for this buffer
  vim.api.nvim_buf_set_option(buf, 'filetype', 'terminal')
  pcall(function()
    vim.treesitter.stop(buf)
  end)
  
  -- Set up buffer-local keymap for Esc to exit insert mode
  vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
  
  -- Enter insert mode
  vim.cmd('startinsert')
  
  return win
end

-- Run a command
function M.run(command)
  if not command or command == '' then
    print('Usage: :AmpcodeRun <command>')
    return
  end
  
  -- Create terminal in current window
  create_terminal_in_current_window(command)
  print('Started: ' .. command)
end

-- Close terminal if running
function M.close()
  if buf and vim.api.nvim_buf_is_valid(buf) then
    -- Exit terminal mode if in it
    if vim.bo[buf].buftype == 'terminal' then
      vim.cmd('bdelete! ' .. buf)
    end
    win = nil
    buf = nil
  else
    print('No terminal running.')
  end
end

return M
