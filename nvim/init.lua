local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end
  
local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use 'Mofiqul/vscode.nvim' -- theme

	use 'neovim/nvim-lspconfig'
	use 'simrat39/rust-tools.nvim'
	use 'j-hui/fidget.nvim' -- show lsp status

	use {
		'nvim-telescope/telescope.nvim',
		requires = { {'nvim-lua/plenary.nvim'} },
	}

	use {
		'nvim-telescope/telescope-fzf-native.nvim',
		run = 'make',
	}

	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'

	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/nvim-cmp'

	use 'nvim-treesitter/nvim-treesitter'
	use 'nvim-treesitter/nvim-treesitter-textobjects'

	use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

	use 'github/copilot.vim'
	use 'christoomey/vim-tmux-navigator'

	if packer_bootstrap then
		require('packer').sync()
	end
end)

if packer_bootstrap then
	vim.notify("installing plugins...")
	return
end

-- Global config
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.number = true
vim.wo.relativenumber = true

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)

vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references)
vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols)
vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols)

vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help)

vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]] -- Format on save

-- Theme
local c = require('vscode.colors').get_colors()
require('vscode').setup({
    italic_comments = true,
    disable_nvimtree_bg = true,
})

-- Telescope 
require('telescope').setup{
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		}
	}
}
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Treesitter
local tsi = require("nvim-treesitter.install")
tsi.prefer_git = true
tsi.compilers = {"clang", "zig", "cc", "gcc", "cl"} -- I always had less surprises with Zig

require('nvim-treesitter.configs').setup {
    ensure_installed = {'c', 'cpp', 'proto', 'go', 'typescript', 'rust'},
    highlight = {
        enable = true,
        use_languagetree = true,
    },
    indent = {
        enable = true
    },
	textobjects = {
		swap = {
			enable = true,
			swap_next = {
				['<leader>a'] = '@parameter.inner'
			},
			swap_previous = {
				['<leader>A'] = '@parameter.inner'
			}
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
			  	["]m"] = "@function.outer",
			  	["]]"] = { query = "@class.outer", desc = "Next class start" },

			  	["]o"] = "@loop.*",

			  	["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
			  	["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
			},
			goto_next_end = {
			  	["]M"] = "@function.outer",
			  	["]["] = "@class.outer",
			},
			goto_previous_start = {
			  	["[m"] = "@function.outer",
			  	["[["] = "@class.outer",
			},
			goto_previous_end = {
			  	["[M"] = "@function.outer",
			  	["[]"] = "@class.outer",
			},
			goto_next = {
			  	["]d"] = "@conditional.outer",
			},
			goto_previous = {
				["[d"] = "@conditional.outer",
			}
		},
	}
}

-- Mason
require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = {'clangd', 'wgsl_analyzer', 'tsserver', 'omnisharp'}
}

-- Autocompletion/cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
	confirmation = { completeopt = 'menu,menuone,noinsert' },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false
        },
    },
    sources = {
		{ name = 'nvim_lsp' }, 
		{ name = 'path' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
		{ name = 'cmdline' }
	}
}

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'path' },
		{ name = 'cmdline' }
	}
})

-- LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()
for _, lsp in ipairs({'clangd', 'wgsl_analyzer', 'tsserver', 'omnisharp'}) do
	require('lspconfig')[lsp].setup {
		--on_attach = on_attach,
		use_mono = true,
		capabilities = capabilities,
		autostart = true
	}
end

local rustytools = require('rust-tools')
rustytools.setup({
    server = {
        on_attach = function(_, bufnr)
			vim.keymap.set("n", "<C-space>", rustytools.hover_actions.hover_actions, { buffer = bufnr })
			--vim.keymap.set("n", "<leader>ag", rustytools.code_action_group.code_action_group, { buffer = bufnr })
		end,
    },
})

require('fidget').setup {
	text = {
		spinner = 'dots_scrolling'
	}
}
