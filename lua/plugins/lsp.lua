-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
	-- clangd = {},
	gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	-- html = { filetypes = { 'html', 'twig', 'hbs'} },

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

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
	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		cond = not vim.g.vscode,
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{
				'williamboman/mason-lspconfig.nvim',
				dependencies = {
					'williamboman/mason.nvim',
				},
				opts = {
					ensure_installed = vim.tbl_keys(servers),
					handlers = {
						function(ls)
							require('lspconfig')[ls].setup {
								capabilities = require('cmp_nvim_lsp')
								    .default_capabilities(vim.lsp.protocol
									    .make_client_capabilities()),
								on_attach = function(_, bufnr)
									-- NOTE: Remember that lua is a real programming language, and as such it is possible
									-- to define small helper and utility functions so you don't have to repeat yourself
									-- many times.
									--
									-- In this case, we create a function that lets us more easily define mappings specific
									-- for LSP related items. It sets the mode, buffer and description for us each time.
									local nmap = function(keys, func, desc)
										if desc then
											desc = 'LSP: ' .. desc
										end

										vim.keymap.set('n', keys, func,
											{ buffer = bufnr, desc = desc })
									end

									nmap('<leader>rn', vim.lsp.buf.rename,
										'[R]e[n]ame')
									nmap('<leader>ca', vim.lsp.buf.code_action,
										'[C]ode [A]ction')

									nmap('gd',
										require('telescope.builtin')
										.lsp_definitions, '[G]oto [D]efinition')
									nmap('gr',
										require('telescope.builtin')
										.lsp_references, '[G]oto [R]eferences')
									nmap('gI',
										require('telescope.builtin')
										.lsp_implementations,
										'[G]oto [I]mplementation')
									nmap('<leader>D',
										require('telescope.builtin')
										.lsp_type_definitions,
										'Type [D]efinition')
									nmap('<leader>ds',
										require('telescope.builtin')
										.lsp_document_symbols,
										'[D]ocument [S]ymbols')
									nmap('<leader>ws',
										require('telescope.builtin')
										.lsp_dynamic_workspace_symbols,
										'[W]orkspace [S]ymbols')

									-- See `:help K` for why this keymap
									nmap('K', vim.lsp.buf.hover,
										'Hover Documentation')
									nmap('<C-k>', vim.lsp.buf.signature_help,
										'Signature Documentation')

									-- Lesser used LSP functionality
									nmap('gD', vim.lsp.buf.declaration,
										'[G]oto [D]eclaration')
									nmap('<leader>wa',
										vim.lsp.buf.add_workspace_folder,
										'[W]orkspace [A]dd Folder')
									nmap('<leader>wr',
										vim.lsp.buf.remove_workspace_folder,
										'[W]orkspace [R]emove Folder')
									nmap('<leader>wl', function()
										print(vim.inspect(vim.lsp.buf
											.list_workspace_folders()))
									end, '[W]orkspace [L]ist Folders')

									-- Create a command `:Format` local to the LSP buffer
									vim.api.nvim_buf_create_user_command(bufnr,
										'Format', function(_)
											vim.lsp.buf.format()
										end,
										{ desc = 'Format current buffer with LSP' })
								end,
								settings = servers[ls],
								filetypes = (servers[ls] or {}).filetypes,
							}
						end,
					}

				}
			},

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			'folke/neodev.nvim',
		},
	},
	{
		'williamboman/mason.nvim',
		cond = not vim.g.vscode,
		opts = { ui = { border = 'single' } }
	},
}
