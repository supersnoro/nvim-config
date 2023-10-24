local cmp_keymaps = {
	insert = function()
		local cmp = require('cmp')
		local luasnip = require('luasnip')
		return cmp.mapping.preset.insert({
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete {},
			['<CR>'] = cmp.mapping.confirm {
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			},
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { 'i', 's' }),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
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
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
				},
			})
		end,
	},
}
