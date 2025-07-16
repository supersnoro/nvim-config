return {
	'folke/trouble.nvim',
	opts = {},
	cmd = 'Trouble',
	keys = {},
	cond = not vim.g.vscode,
	dependencies = {
		{ 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
	},
}
