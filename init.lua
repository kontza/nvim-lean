if vim.loader then vim.loader.enable() end

local gh = function(repo) return 'https://github.com/' .. repo end

local working, ret = pcall(function()
	assert(vim.pack, 'vim.pack is missing: Neovim 0.12 or newer is required')

	-- Build hooks have to be registered before vim.pack.add() so they also fire on first install.
	vim.api.nvim_create_autocmd('PackChanged', {
		group = vim.api.nvim_create_augroup('pure.pack', { clear = true }),
		callback = function(ev)
			local name, kind = ev.data.spec.name, ev.data.kind
			if name == 'nvim-treesitter' and kind == 'update' then
				if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
				vim.cmd('TSUpdate')
			end
		end,
	})

	vim.pack.add({
		gh('nvim-mini/mini.nvim'),
		{ src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
		-- a release tag lets blink.cmp download its prebuilt fuzzy matcher
		{ src = gh('saghen/blink.cmp'), version = vim.version.range('1') },
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

		local supported_languages = { 'lua', 'vimdoc' }
		require('nvim-treesitter').install(supported_languages)
		vim.api.nvim_create_autocmd('FileType', {
			pattern = supported_languages,
			callback = function() vim.treesitter.start() end,
		})

		require('blink.cmp').setup({
			keymap = { preset = 'enter' }, -- <CR> accepts the selected completion item
			completion = {
				accept = { auto_brackets = { enabled = true } },
			},
			cmdline = { enabled = false },
			signature = { enabled = true },
			fuzzy = { implementation = 'prefer_rust_with_warning' },
		})

		-- not needed for the first screen, so set up right after startup
		vim.schedule(function()
			require('mini.ai').setup()
			require('mini.comment').setup()
			require('mini.surround').setup()
			require('mini.pairs').setup()
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
