if vim.loader then vim.loader.enable() end

local gh = function(repo) return 'https://github.com/' .. repo end

local working, ret = pcall(function()
	assert(vim.pack, 'vim.pack is missing: Neovim 0.12 or newer is required')

	vim.pack.add({
		gh('nvim-mini/mini.nvim'),
		gh('rafamadriz/friendly-snippets'),
	})

	---@type boolean, function
	local success, config = pcall(require, 'config')

	if (success and type(config) == 'function') or not success then
		require('mini.basics').setup()
		require('mini.notify').setup()
		vim.notify = require('mini.notify').make_notify()
		require('mini.icons').setup()
		MiniIcons.mock_nvim_web_devicons()
		require('mini.statusline').setup()
		require('mini.starter').setup()

		-- load instantly to replace netrw
		require('mini.files').setup()
		require('mini.diff').setup()

		-- parsers bundled with Neovim itself, so nothing has to be compiled
		vim.api.nvim_create_autocmd('FileType', {
			pattern = { 'lua', 'help', 'vim', 'c', 'query', 'markdown' },
			callback = function() vim.treesitter.start() end,
		})

		local snippets = require('mini.snippets')
		snippets.setup({ snippets = { snippets.gen_loader.from_lang() } }) -- reads friendly-snippets
		snippets.start_lsp_server() -- offers snippets as completion items
		require('mini.completion').setup()

		-- not needed for the first screen, so set up right after startup
		vim.schedule(function()
			require('mini.ai').setup()
			require('mini.comment').setup()
			require('mini.surround').setup()
			require('mini.pairs').setup()
			-- <CR> accepts the selected completion item, otherwise falls through to mini.pairs
			require('mini.keymap').map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
			require('mini.jump').setup()
			require('mini.pick').setup()
			require('mini.extra').setup()
			require('mini.indentscope').setup({
				draw = { animation = require('mini.indentscope').gen_animation.none() },
			})
			require('mini.cursorword').setup()
			require('mini.bufremove').setup()
			vim.keymap.set('n', '<Leader>bd', function() require('mini.bufremove').delete(0) end)
			require('mini.bracketed').setup()
		end)

		if type(config) == 'function' then config() end
	end
end)

if not working then
	local failsafe_message = [[
(pure.nvim) launched in failsafe mode. Only basic editing features are available.

Possible reasons:
* Neovim older than 0.12 (no vim.pack)
* Internet unreachable during bootstrap
* Broken `git` installation
* Wrong permissions on site path

Traceback:
]]
	vim.notify(failsafe_message .. ret, vim.log.levels.ERROR)

	require('_vendor.mini.basics').setup()
	require('_vendor.mini.ai').setup()
	require('_vendor.mini.comment').setup()
	require('_vendor.mini.surround').setup()
	require('_vendor.mini.pairs').setup()
	require('_vendor.mini.bufremove').setup()
	require('_vendor.mini.completion').setup()
	vim.keymap.set('n', '<Leader>bd', function() require('_vendor.mini.bufremove').delete(0) end)
	require('_vendor.mini.jump').setup()
end
