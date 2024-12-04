-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(),
	require('cmp_nvim_lsp').default_capabilities())

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
	gopls = {
		settings = {
			gopls = {
				gofumpt = true,
			},
		},
	},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},
	-- html = { filetypes = { 'html', 'twig', 'hbs'} },

	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
				diagnostics = { globals = { "vim" } },
			},
		},
	},
}

return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		'folke/lazydev.nvim',
		ft = 'lua',
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = 'luvit-meta/library', words = { 'vim%.uv' } },
			},
		},
	},
	{ 'Bilal2453/luvit-meta', lazy = true },
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
						function(lsp_name)
							local server = servers[lsp_name] or {}
							-- This handles overriding only values explicitly passed
							-- by the server configuration above. Useful when disabling
							-- certain features of an LSP (for example, turning off formatting for ts_ls)
							server.capabilities = vim.tbl_deep_extend('force', {}, capabilities,
								server.capabilities or {})

							-- Setup the buffer attachment callback
							server.on_attach = function(client, bufnr)
								-- NOTE: Remember that Lua is a real programming language, and as such it is possible
								-- to define small helper and utility functions so you don't have to repeat yourself.
								--
								-- In this case, we create a function that lets us more easily define mappings specific
								-- for LSP related items. It sets the mode, buffer and description for us each time.
								local map = function(keys, func, desc, mode)
									mode = mode or 'n'
									vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
								end

								-- Jump to the definition of the word under your cursor.
								--  This is where a variable was first declared, or where a function is defined, etc.
								--  To jump back, press <C-t>.
								map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

								-- Find references for the word under your cursor.
								map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

								-- Jump to the implementation of the word under your cursor.
								--  Useful when your language has ways of declaring types without an actual implementation.
								map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

								-- Jump to the type of the word under your cursor.
								--  Useful when you're not sure what type a variable is and you want to see
								--  the definition of its *type*, not where it was *defined*.
								map('<leader>D', require('telescope.builtin').lsp_type_definitions,
									'Type [D]efinition')

								-- Fuzzy find all the symbols in your current document.
								--  Symbols are things like variables, functions, types, etc.
								map('<leader>ds', require('telescope.builtin').lsp_document_symbols,
									'[D]ocument [S]ymbols')

								-- Fuzzy find all the symbols in your current workspace.
								--  Similar to document symbols, except searches over your entire project.
								map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
									'[W]orkspace [S]ymbols')

								-- Rename the variable under your cursor.
								--  Most Language Servers support renaming across files, etc.
								map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

								-- Execute a code action, usually your cursor needs to be on top of an error
								-- or a suggestion from your LSP for this to activate.
								map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

								-- WARN: This is not Goto Definition, this is Goto Declaration.
								--  For example, in C this would take you to the header.
								map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

								-- Create a command `:Format` local to the LSP buffer
								vim.api.nvim_buf_create_user_command(bufnr,
									'Format', function(_)
										vim.lsp.buf.format()
									end,
									{ desc = 'Format current buffer with LSP' })

								if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
									local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
										{ clear = false })
									vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
										buffer = bufnr,
										group = highlight_augroup,
										callback = vim.lsp.buf.document_highlight,
									})

									vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
										buffer = bufnr,
										group = highlight_augroup,
										callback = vim.lsp.buf.clear_references,
									})

									vim.api.nvim_create_autocmd('LspDetach', {
										group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
										callback = function(event2)
											vim.lsp.buf.clear_references()
											vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
										end,
									})
								end
							end

							require('lspconfig')[lsp_name].setup(server)
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
