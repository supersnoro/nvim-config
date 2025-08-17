local build_cmd ---@type string?
for _, cmd in ipairs({ "zig", "make" }) do
  if vim.fn.executable(cmd) == 1 then
    build_cmd = cmd
    break
  end
end

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  cond = not vim.g.vscode,
  opts = {
    defaults = {
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
        },
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which require local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = ((build_cmd ~= "zig") and "make"
        or "mkdir build; zig cc -O3 -Wall -Werror -fpic -std=gnu99 -shared src/fzf.c -o build/libfzf.dll"),
      enabled = build_cmd ~= nil,
      config = function()
        local name = 'telescope.nvim'
        local Config = require 'lazy.core.config'
        if Config.plugins[name] and Config.plugins[name]._.loaded then
          require('telescope').load_extension 'fzf'
        else
          vim.api.nvim_create_autocmd('User', {
            pattern = 'LazyLoad',
            callback = function(event)
              if event.data == name then
                require('telescope').load_extension 'fzf'
                return true
              end
            end,
          })
        end
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'rcarriga/nvim-notify' },
    { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
  },
  keys = {
    {
      '<leader>sf',
      function()
        require('telescope.builtin').find_files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sh',
      function()
        require('telescope.builtin').help_tags()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        require('telescope.builtin').keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').builtin()
      end,
      desc = '[Search] [S]elect Telescope',
    },
    {
      '<leader>sw',
      function()
        require('telescope.builtin').grep_string()
      end,
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sg',
      function()
        require('telescope.builtin').live_grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sd',
      function()
        require('telescope.builtin').diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        require('telescope.builtin').resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        require('telescope.builtin').oldfiles()
      end,
      desc = '[S]earch Recent Files ("." for repeat"',
    },
    {
      '<leader><leader>',
      function()
        require('telescope.builtin').buffers()
      end,
      desc = '[<leader>] Find existing buffers',
    },
    {
      -- Slightly advanced example of overriding default behavior and theme
      '<leader>/',
      function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      -- Shortcut for searching your Neovim configuration files
      '<leader>sc',
      function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end,
      desc = '[S]earch Neovim [C]onfig',
    },
    {
      -- Search notificiations
      '<leader>sn',
      function()
        require('telescope').extensions.notify.notify {}
      end,
      desc = '[S]earch [N]otifications',
    },
  },
  config = function(_, opts)
    telescope = require 'telescope'

    -- Setup telescope
    telescope.setup(opts)

    -- Load telescope extensions
    telescope.load_extension 'ui-select'
    telescope.load_extension 'notify'

    -- Configure extensions here, since some of them require telescope to be loaded already
    opts.extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown {},
      },
      ['notify'] = {},
    }
  end,
}
