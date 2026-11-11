-- relative line numbers, with the absolute number on the cursor line
vim.opt.number = true
vim.opt.relativenumber = true

-- spaces instead of tabs
vim.opt.expandtab = true   -- <Tab> inserts spaces
vim.opt.shiftwidth = 4     -- indent width for >>, <<, and autoindent
vim.opt.tabstop = 4        -- how wide a real tab character is displayed
vim.opt.softtabstop = -1   -- <Tab>/<BS> follow shiftwidth

if vim.loader and vim.fn.has('nvim-0.9.1') == 1 then vim.loader.enable() end

local path_package = vim.fn.stdpath('data') .. '/site'

---@type table
local _deps

if not vim.uv.fs_stat(path_package .. '/pack/deps/start/mini.nvim') then
	_deps = require('_vendor.mini.deps')
	require('_vendor.mini.basics').setup()
else
	_deps = require('mini.deps')
end

local working, ret = pcall(function()
	_deps.setup({ path = { package = path_package } })

	local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

	add('nvim-mini/mini.nvim')
	if
		vim.uv.fs_stat(path_package .. '/pack/deps/opt/mini.nvim')
		and not vim.uv.fs_stat(path_package .. '/pack/deps/start/mini.nvim')
	then
		vim.fn.mkdir(path_package .. '/pack/deps/start', 'p')
		vim.uv.fs_rename(path_package .. '/pack/deps/opt/mini.nvim', path_package .. '/pack/deps/start/mini.nvim')
	end

	---@type boolean, function
	local success, config = pcall(require, 'config')

	if (success and type(config) == 'function') or not success then
		now(function() require('mini.basics').setup() end)
		now(function()
			require('mini.notify').setup()
			vim.notify = require('mini.notify').make_notify()
		end)
		now(function()
			require('mini.icons').setup()
			MiniIcons.mock_nvim_web_devicons()
		end)
		now(function() require('mini.statusline').setup() end)
		now(function() require('mini.starter').setup() end)

		-- load instantly to replace netrw
		now(function() require('mini.files').setup() end)

		later(function() require('mini.ai').setup() end)
		later(function() require('mini.comment').setup() end)
		later(function() require('mini.surround').setup() end)
		later(function() require('mini.pairs').setup() end)
		later(function() require('mini.jump').setup() end)
		later(function()
			require('mini.pick').setup()
			require('mini.extra').setup()
		end)
		now(function() require('mini.diff').setup() end)
		later(
			function()
				require('mini.indentscope').setup({
					draw = { animation = require('mini.indentscope').gen_animation.none() },
				})
			end
		)
		later(function() require('mini.cursorword').setup() end)
		later(function()
			require('mini.bufremove').setup()
			vim.keymap.set('n', '<Leader>bd', function() require('mini.bufremove').delete(0) end)
		end)
		later(function() require('mini.bracketed').setup() end)

		now(function()
			add({
				source = 'nvim-treesitter/nvim-treesitter',
				checkout = 'main',
				hooks = {
					post_checkout = function() vim.cmd('TSUpdate') end,
				},
			})
			local supported_languages = { 'lua', 'vimdoc' }
			require('nvim-treesitter').install(supported_languages)
			vim.api.nvim_create_autocmd('FileType', {
				pattern = supported_languages,
				callback = function() vim.treesitter.start() end,
			})
		end)

        now(function()
            add({
                source = 'saghen/blink.cmp',
                checkout = 'v1.10.2', -- a release tag => prebuilt binary is downloaded
                depends = { 'rafamadriz/friendly-snippets' },
            })

            require('blink.cmp').setup({
                completion = {
                    accept = { auto_brackets = { enabled = true } },
                },
                cmdline = { enabled = false },
                signature = { enabled = true },
                fuzzy = { implementation = 'prefer_rust_with_warning' },
            })
        end)

		config()
	end
end)

if not working then
	local failsafe_message = [[
(pure.nvim) launched in failsafe mode. Only basic editing features are available.

Possible reasons:
* Internet unreachable during bootstrap
* Broken `git` installation
* Wrong permissions on site path

Traceback:
]]
	vim.notify(failsafe_message .. ret, vim.log.levels.ERROR)

	require('_vendor.mini.ai').setup()
	require('_vendor.mini.comment').setup()
	require('_vendor.mini.surround').setup()
	require('_vendor.mini.pairs').setup()
	require('_vendor.mini.bufremove').setup()
	require('_vendor.mini.completion').setup()
	vim.keymap.set('n', '<Leader>bd', function() require('_vendor.mini.bufremove').delete(0) end)
	require('_vendor.mini.jump').setup()
end
