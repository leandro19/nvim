-- Set up lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({

    -- Git related plugins
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            { 'j-hui/fidget.nvim', opts = {} },

            -- Additional lua configuration
            'folke/neodev.nvim',
        },
    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim', opts = {} },

    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({ 'n', 'v' }, ']c', function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, desc = 'Jump to next hunk' })

                map({ 'n', 'v' }, '[c', function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, desc = 'Jump to previous hunk' })

                -- Actions
                -- visual mode
                map('v', '<leader>hs', function()
                    gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, { desc = 'stage git hunk' })
                map('v', '<leader>hr', function()
                    gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
                end, { desc = 'reset git hunk' })
                -- normal mode
                map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
                map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
                map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
                map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
                map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
                map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
                map('n', '<leader>hb', function()
                    gs.blame_line { full = false }
                end, { desc = 'git blame line' })
                map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
                map('n', '<leader>hD', function()
                    gs.diffthis '~'
                end, { desc = 'git diff against last commit' })

                -- Toggles
                map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
                map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

                -- Text object
                map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
            end,
        },
    },

    {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd.colorscheme("kanagawa-wave")
        end,
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                icons_enabled = false,
                theme = 'kanagawa',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {},
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
    },


    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

                sync_install = false,

                auto_install = true,

                highlight = {
                    enable = true,

                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<Leader>ss", -- set to `false` to disable one of the mappings
                        node_incremental = "<Leader>si",
                        scope_incremental = "<Leader>sc",
                        node_decremental = "<Leader>sd",
                    },
                },


                textobjects = {
                    select = {
                        enable = true,

                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            -- You can also use captures from other query groups like `locals.scm`
                            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        },
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'v', -- linewise
                            ['@class.outer'] = '<c-v>', -- blockwise
                        },
                        -- If you set this to `true` (default is `false`) then any textobject is
                        -- extended to include preceding or succeeding whitespace. Succeeding
                        -- whitespace has priority in order to act similarly to eg the built-in
                        -- `ap`.
                        include_surrounding_whitespace = true,
                    },
                },
            })
        end,
    },
})

