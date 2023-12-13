return {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	cond = !vim.g.vscode,
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
			build = 'make',
			enabled = vim.fn.executable("make") == 1,
			config = function()
				local name = "telescope.nvim"
				local Config = require("lazy.core.config")
				if Config.plugins[name] and Config.plugins[name]._.loaded then
					require("telescope").load_extension("fzf")
				else
					vim.api.nvim_create_autocmd("User", {
						pattern = "LazyLoad",
						callback = function(event)
							if event.data == name then
								require("telescope").load_extension("fzf")
								return true
							end
						end,
					})
				end
			end,
		},
	},
	keys = {
		-- See `:help telescope.builtin
		{
			'<leader>?',
			function() require('telescope.builtin').oldfiles() end,
			desc =
			'[?] Find recently opened files'
		},
		{
			'<leader><space>',
			function() require('telescope.builtin').buffers() end,
			desc =
			'[ ] Find existing buffers'
		},
		{
			'<leader>/',
			function()
				-- You can pass additional configuration to telescope to change theme, layout, etc.
				require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes')
					.get_dropdown {
						winblend = 10,
						previewer = false,
					})
			end,
			desc = '[/] Fuzzily search in current buffer'
		},
		{ '<leader>gf', function() require('telescope.builtin').git_files() end,   desc = 'Search [G]it [F]iles' },
		{ '<leader>sf', function() require('telescope.builtin').find_files() end,  desc = '[S]earch [F]iles' },
		{ '<leader>sh', function() require('telescope.builtin').help_tags() end,   desc = '[S]earch [H]elp' },
		{ '<leader>sw', function() require('telescope.builtin').grep_string() end,
			                                                                           desc =
			'[S]earch current [W]ord' },
		{ '<leader>sg', function() require('telescope.builtin').live_grep() end,   desc = '[S]earch by [G]rep' },
		{ '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc =
		'[S]earch [D]iagnostics' },
		{ '<leader>sr', function() require('telescope.builtin').resume() end,      desc = '[S]earch [R]esume' },
	},
}
