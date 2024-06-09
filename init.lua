-- opts set in a table to not repeat them everytime
local opts = { noremap = true, silent = true }

-- Leader
vim.g.mapleader = " "       -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- Sets
vim.opt.history = 50
vim.opt.tabstop = 2
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.ruler = true
vim.opt.smartcase = true
vim.opt.relativenumber = true
vim.opt.incsearch = true
vim.opt.showcmd = true
vim.opt.hlsearch = true
vim.opt.modeline = true
vim.opt.mouse = "a"
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.wildmode = { "list:longest", "full" }
vim.opt.wildmenu = true
vim.opt.textwidth = 80
vim.opt.colorcolumn = "+1"

-- Escape
vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set("v", "<leader>jk", "<Esc>", opts)

-- Search center in screen
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Quicker window movement
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)

-- Setup lazy.nvim if not in autoload
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  "jose-elias-alvarez/typescript.nvim",
  "nvim-lua/plenary.nvim",
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  "debugloop/telescope-undo.nvim",
  "rafamadriz/friendly-snippets",
  "tpope/vim-surround",
  "jiangmiao/auto-pairs",
  "unblevable/quick-scope",
  "morhetz/gruvbox",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "hrsh7th/nvim-cmp",
  { 'VonHeikemen/lsp-zero.nvim',      branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'nvim-treesitter/nvim-treesitter' },
  { 'hrsh7th/nvim-cmp' },
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "saadparwaiz1/cmp_luasnip",
  { 'L3MON4D3/LuaSnip' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { "folke/neodev.nvim",                opts = {} }
})

-- Syntax Highilighting
vim.api.nvim_create_autocmd("BufEnter",
  { pattern = { "*.templ", "*" }, callback = function() vim.cmd("TSBufEnable highlight") end })

vim.api.nvim_create_autocmd("BufReadPost",
  { pattern = { "*.svelte" }, callback = function() vim.cmd("set syntax=html") end })

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({ buffer = bufnr })
  lsp_zero.buffer_autoformat()
end)

--- if you want to know more about lsp-zero and mason.nvim
--- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

require("neodev").setup({})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Insert }

-- this is the function that loads the extra snippets to luasnip
-- from rafamadriz/friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'luasnip', keyword_length = 2 },
    { name = 'buffer',  keyword_length = 3 },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
  callback = function(event)
    local optsLsp = { buffer = event.buf }

    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, optsLsp)
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, optsLsp)
    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, optsLsp)
    vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, optsLsp)
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, optsLsp)
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, optsLsp)
    vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, optsLsp)
    vim.keymap.set('n', '<leader>rr', function() vim.lsp.buf.references() end, optsLsp)
    vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, optsLsp)
    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, optsLsp)
  end,
})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Templ LSP Integration
lspconfig.html.setup({
  filetypes = { "html", "templ" },
})

lspconfig.htmx.setup({
  filetypes = { "html", "templ" },
})

lspconfig.tailwindcss.setup({
  filetypes = { "templ", "astro", "javascript", "typescript", "react" },
  init_options = { userLanguages = { templ = "html" } },
})

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- Nvim Tree
local nvim_tree = require("nvim-tree")

nvim_tree.setup({
  update_cwd = true,
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  view = {
    side = "left",
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  filters = {
    dotfiles = false,
    git_ignored = false
  },
  diagnostics = {
    enable = true,
  },
  renderer = {
    highlight_opened_files = "all"
  }
})

local nvimTreeView = require('nvim-tree.view')

vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<Enter>", opts)
nvimTreeView.View.winopts.relativenumber = true

-- Colorcheme
vim.cmd.colorscheme('gruvbox')

-- Templ
vim.filetype.add({ extension = { templ = "templ" } })

-- Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<cr>", opts)
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<cr>", opts)
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>", opts)
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>", opts)
vim.keymap.set("n", "<leader>u", ":Telescope undo<cr>", opts)
require("telescope").load_extension("undo")

require("typescript").setup({
  disable_commands = false,   -- prevent the plugin from creating Vim commands
  debug = false,              -- enable debug logging for commands
  go_to_source_definition = {
    fallback = true,          -- fall back to standard LSP definition on failure
  },
  server = {                  -- pass options to lspconfig's setup method
    on_attach = ...,
  },
})
