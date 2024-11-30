local cmp_keymaps = {
	insert = function()
		local cmp = require('cmp')
		local luasnip = require('luasnip')
		return cmp.mapping.preset.insert({
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-p>'] = cmp.mapping.select_prev_item(),

			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),

			['<C-y>'] = cmp.mapping.complete { select = true },

			-- Manually trigger a completion from nvim-cmp.
			--  Generally you don't need this, because nvim-cmp will display
			--  completions whenever it has completion options available.
			['<C-Space>'] = cmp.mapping.complete {},

			-- Think of <c-l> as moving to the right of your snippet expansion.
			--  So if you have a snippet that's like:
			--  function $name($args)
			--    $body
			--  end
			--
			-- <c-l> will move you to the right of each of the expansion locations.
			-- <c-h> is similar, except moving you backwards.
			['<C-l>'] = cmp.mapping(function()
				if luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { 'i', 's' }),
			['<C-h>'] = cmp.mapping(function()
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { 'i', 's' }),

		})
	end,
}
return {
	{
		-- Autocompletion
		-- [[ Configure nvim-cmp ]]
		-- See `:help cmp`
		'hrsh7th/nvim-cmp',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				'L3MON4D3/LuaSnip',
				config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
				dependencies = {
					'saadparwaiz1/cmp_luasnip',

					-- Adds a number of user-friendly snippets
					'rafamadriz/friendly-snippets',
				},
			},

			-- Adds LSP completion capabilities
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			require('cmp').setup({
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				mapping = cmp_keymaps.insert(),
				sources = {
					{
						name = 'lazydev',
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'path' },
				},
			})
		end,
	},
}
