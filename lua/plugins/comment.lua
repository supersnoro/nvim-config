return {
	-- "gc" to comment visual regions/lines
	{ 'numToStr/Comment.nvim', opts = {} },
	{
		'folke/todo-comments.nvim',
		event = 'VimEnter',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		opts = {
			signs = false
		},
	},
}
