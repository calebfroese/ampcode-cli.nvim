if vim.g.loaded_ampcode_cli then
  return
end
vim.g.loaded_ampcode_cli = 1

-- Create user commands
vim.api.nvim_create_user_command('Amp', function()
  local ampcode = require('ampcode-cli')
  local settings_file = ampcode._create_settings_file()
  ampcode.run('amp --settings-file ' .. settings_file)
end, {})

