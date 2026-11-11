return function()
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.expandtab = true
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 4
	vim.opt.softtabstop = -1

	-- bundled with Neovim
	vim.cmd.colorscheme('zaibatsu')

	vim.pack.add({ 'https://github.com/stevearc/oil.nvim' })
    vim.pack.add({ 'https://github.com/HiPhish/rainbow-delimiters.nvim' })

	-- init.lua set mini.files up as the directory handler; hand that job to oil
	require('mini.files').setup({ options = { use_as_default_explorer = false } })

	require('oil').setup({ default_file_explorer = true })
	vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory' })
end
