-- Do not wrap in a function if you'd like to override the supplied config
return function()
	-- Your config here
	vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig', 'https://github.com/mason-org/mason.nvim' })
end
