local M = {}

local buf = nil
local win = nil
local settings_file_path = nil

-- Default configuration
local config = {
  height = 15,
  position = 'bottom', -- 'bottom', 'top', 'left', 'right', 'float'
  mcpserver_path = nil, -- Optional: custom path to mcpserver standalone.lua
}

-- Find mcpserver plugin path
local function find_mcpserver_path()
  -- Check if custom path is configured
  if config.mcpserver_path then
    -- Expand home directory if path starts with ~
    local expanded_path = string.gsub(config.mcpserver_path, "^~", vim.fn.expand("$HOME"))
    if vim.fn.filereadable(expanded_path) == 1 then
      return expanded_path
    end
  end

  -- Check standard lazy.nvim plugins directory
  local standard_path = vim.fn.stdpath('data') .. '/lazy/mcpserver.nvim/standalone.lua'
  if vim.fn.filereadable(standard_path) == 1 then
    return standard_path
  end

  error('Could not find mcpserver.nvim plugin. Please ensure it is installed correctly or specify mcpserver_path in the config.')
end

-- Create ephemeral settings file
local function create_settings_file()
  if settings_file_path then
    return settings_file_path
  end

  -- Create a temporary file
  local temp_dir = vim.fn.stdpath('cache')
  settings_file_path = temp_dir .. '/amp_settings_' .. vim.fn.getpid() .. '.json'

  -- Get nvim listen socket
  local nvim_listen_socket = vim.v.servername

  -- Get path to mcpserver plugin
  local plugin_path = find_mcpserver_path()

  -- Write the settings content
  local settings_content = string.format([[{
  "amp.mcpServers": {
    "nvim": {
      "command": "lua",
      "args": [
        "%s",
        "%s"
      ]
    }
  }
}]], plugin_path, nvim_listen_socket)

  local file = io.open(settings_file_path, 'w')
  if file then
    file:write(settings_content)
    file:close()
  else
    error('Failed to create settings file: ' .. settings_file_path)
  end

  return settings_file_path
end

-- Clean up settings file
local function cleanup_settings_file()
  if settings_file_path and vim.fn.filereadable(settings_file_path) == 1 then
    vim.fn.delete(settings_file_path)
    settings_file_path = nil
  end
end

-- Setup function for user configuration
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})

  -- Set up autocmd to clean up settings file on VimLeave
  vim.api.nvim_create_autocmd('VimLeave', {
    callback = cleanup_settings_file,
    desc = 'Clean up amp settings file'
  })
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

-- Expose internal functions for plugin use
M._create_settings_file = create_settings_file
M._cleanup_settings_file = cleanup_settings_file

return M
