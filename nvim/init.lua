-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

-- stylua: ignore start
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'                                                         -- Package manager
  use 'tpope/vim-fugitive'                                                             -- Git commands in nvim
  use 'tpope/vim-rhubarb'                                                              -- Fugitive-companion to interact with github
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }            -- Add git related info in the signs columns and popups
  use 'numToStr/Comment.nvim'                                                          -- "gc" to comment visual regions/lines
  use 'nvim-treesitter/nvim-treesitter'                                                -- Highlight, edit, and navigate code
  use { 'nvim-treesitter/nvim-treesitter-textobjects', after = { 'nvim-treesitter' } } -- Additional textobjects for treesitter
  use 'neovim/nvim-lspconfig'                                                          -- Collection of configurations for built-in LSP client
  use 'williamboman/mason.nvim'                                                        -- Manage external editor tooling i.e LSP servers
  use 'williamboman/mason-lspconfig.nvim'                                              -- Automatically install language servers to stdpath
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp' } }                    -- Autocompletion
  use { 'L3MON4D3/LuaSnip', requires = { 'saadparwaiz1/cmp_luasnip' } }                -- Snippet Engine and Snippet Expansion
  use 'nvim-lualine/lualine.nvim'                                                      -- Fancier statusline
  use 'lukas-reineke/indent-blankline.nvim'                                            -- Add indentation guides even on blank lines
  use 'tpope/vim-sleuth'                                                               -- Detect tabstop and shiftwidth automatically
  use 'nvim-tree/nvim-tree.lua'
  use 'j-hui/fidget.nvim'

  use 'akinsho/toggleterm.nvim'
  use 'simrat39/rust-tools.nvim'
  use {
    "jesseleite/nvim-noirbuddy",
    requires = { "tjdevries/colorbuddy.nvim", branch = "dev" }
  }

  -- Debugging
  use 'nvim-lua/plenary.nvim'
  use 'mfussenegger/nvim-dap'

  use "windwp/nvim-autopairs"
  use "rcarriga/nvim-notify"

  use { 'phaazon/hop.nvim', branch = 'v2' }
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

  -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-dap.nvim' }

  use 'zbirenbaum/copilot.lua'
  use 'zbirenbaum/copilot-cmp'

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- stylua: ignore end

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

vim.notify = require("notify")


-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  sort_by = "extension",
  git = {
    enable = true,
    ignore = false,
  },
  filesystem_watchers = {
    ignore_dirs = {
      "target"
    }
  },
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = false,
        modified = false,
      },
      glyphs = {
        folder = {
          arrow_closed = ">",
          arrow_open = "|",
        }
      }
    },
  }
})

require("hop").setup()
require("fidget").setup()

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- [[ Basic Keymaps ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "s", require('hop').hint_words, { desc = "HopWord" })
vim.keymap.set("n", "S", require('hop').hint_lines, { desc = "HopLine" })

vim.keymap.set("n", "§", require('nvim-tree.api').tree.toggle, { desc = "Toggle NVimTree" })
vim.keymap.set("n", "~", require('nvim-tree.api').tree.toggle, { desc = "Toggle NVimTree" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = '16color',
    component_separators = '|',
    section_separators = '',
  },
}

require("nvim-autopairs").setup()

-- Enable Comment.nvim
require('Comment').setup()

require('indent_blankline').setup {
  show_end_of_line = true,
}

-- Gitsigns
-- See `:help gitsigns.txt`

require('gitsigns').setup {
  signs = {
    add          = { text = '+' },
    change       = { text = 'M' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
require('telescope').load_extension('dap')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.install').prefer_git = false
require('nvim-treesitter.install').compilers = { "zig", "cc", "gcc", "clang", "cl", }
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'proto', 'go', 'lua', 'rust' },
  highlight = {
    enable = true,
    use_languagetree = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      -- TODO: I'm not sure for this one.
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)



-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gr', require('telescope.builtin').lsp_references)
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Enable the following language servers
local servers = { 'clangd', 'wgsl_analyzer', 'tsserver', 'omnisharp' }

-- Ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = servers,
}

local rt = require("rust-tools")
local mason_registry = require("mason-registry")
local codelldb = mason_registry.get_package("codelldb")
local extension_path = codelldb:get_install_path()
local codelldb_path = extension_path .. '/extension/adapter/codelldb' -- .exe
local liblldb_path = extension_path .. '/extension/lldb/lib/liblldb' -- .lib

rt.setup({
  server = {
    on_attach = on_attach,
  },
  dap = {
    adapter = {
      type = 'server',
      port = "${port}",
      executable = {
        command = codelldb_path,
        args = {"--port", "${port}"},
        detached = false,
      }
    }
  }
})

local dap = require('dap')

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = {"--port", "${port}"},
    detached = false,
  }
}

for _, lsp in ipairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    use_mono = true,
    capabilities = capabilities,
    autostart = true,
  }
end

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
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
      select = false,
    },
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, {"i", "s"}),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {"i", "s"}),
  },
  sources = {
    { name = "copilot", group_index = 2 },
    { name = "nvim_lsp", group_index = 2 },
    { name = "path", group_index = 2 },
    { name = "luasnip", group_index = 2 },
  },
}

require("toggleterm").setup{
  open_mapping = [[<C-\>]],
}

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dapui.setup()

vim.keymap.set("n", "<leader>dC", require("dap").continue, { desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "DAP: Toggle breackpoint" })

vim.keymap.set("n", "<leader>dB", function()
    require("dap").set_breakpoint(fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set breakpoint" })

vim.keymap.set("n", "<leader>do", require("dap").step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>dO", require("dap").step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dn", require("dap").step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>dN", require("dap").step_back, { desc = "DAP: Step back" })
vim.keymap.set("n", "<leader>dr", require("dap").repl.toggle, { desc = "DAP: Toggle REPL" })
vim.keymap.set("n", "<leader>d.", require("dap").goto_, { desc = "DAP: Go to" })
vim.keymap.set("n", "<leader>dh", require("dap").run_to_cursor, { desc = "DAP: Run to cursor" })
vim.keymap.set("n", "<leader>de", require("dap").set_exception_breakpoints, { desc = "DAP: Set exception breakpoints" })
vim.keymap.set("n", "<leader>dv", function()
    require("telescope").extensions.dap.variables()
end, { desc = "DAP-Telescope: Variables" })

vim.keymap.set("n", "<leader>dc", function()
    require("telescope").extensions.dap.commands()
end, { desc = "DAP-Telescope: Commands" })

vim.keymap.set({ "n", "x" }, "<leader>dx", require("dapui").eval, { desc = "DAP-UI: Eval" })

vim.keymap.set("n", "<leader>dX", function()
    dapui.eval(fn.input("expression: "), {})
end, { desc = "DAP-UI: Eval expression" })

require('noirbuddy').setup {
  colors = {
    primary = '#00ffdd',
    background = '#000000',
  },
}

vim.api.nvim_set_hl (0, 'DiagnosticVirtualTextError', {fg="#ff0000"})
vim.api.nvim_set_hl (0, 'DiagnosticVirtualTextWarn', {fg="#303030"})
vim.api.nvim_set_hl (0, 'DiagnosticVirtualTextInfo', {fg="#303030"})
vim.api.nvim_set_hl (0, 'DiagnosticVirtualTextHint', {fg="#303030"})

vim.api.nvim_set_hl (0, 'DiagnosticSignError', {fg="#ff0000"})
vim.api.nvim_set_hl (0, 'DiagnosticSignWarn', {fg="#707070"})
vim.api.nvim_set_hl (0, 'DiagnosticSignInfo', {fg="#707070"})
vim.api.nvim_set_hl (0, 'DiagnosticSignHint', {fg="#707070"})

vim.api.nvim_set_hl (0, 'GitSignsAdd', {fg="#707070"})
vim.api.nvim_set_hl (0, 'GitSignsChange', {fg="#707070"})
vim.api.nvim_set_hl (0, 'GitSignsDelete', {fg="#707070"})
vim.api.nvim_set_hl (0, 'GitSignsChangedelete', {fg="#707070"})
vim.api.nvim_set_hl (0, 'GitSignsTopdelete', {fg="#707070"})
vim.api.nvim_set_hl (0, 'GitSignsUntracked', {fg="#707070"})

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("copilot_cmp").setup()
