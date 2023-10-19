return {
	-- Theme inspired by Atom
	'EdenEast/nightfox.nvim',
	priority = 1000,
	config = function()
		vim.cmd.colorscheme 'nightfox'
	end,
}
