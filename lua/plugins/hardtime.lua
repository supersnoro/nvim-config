return {
  {
    'm4xshen/hardtime.nvim',
    cond = not vim.g.vscode,
    lazy = false,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {},
  },
  {
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require 'notify'
    end,
  },
}
