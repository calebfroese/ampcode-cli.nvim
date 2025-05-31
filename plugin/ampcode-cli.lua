if vim.g.loaded_ampcode_cli then
  return
end
vim.g.loaded_ampcode_cli = 1

-- Create user commands
vim.api.nvim_create_user_command('Amp', function()
  require('ampcode-cli').run('amp')
end, {})

vim.api.nvim_create_user_command('AmpcodeClose', function()
  require('ampcode-cli').close()
end, {})


