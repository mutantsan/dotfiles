-- Python LSP configuration for Neovim with pyenv/direnv
return {
    -- Mason for LSP management
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- "basedpyright", -- Python LSP
                    "pylsp",
                    "ruff", -- Python linter/formatter
                },
                automatic_installation = true,
            })
        end,
        dependencies = {
            "williamboman/mason.nvim",
        },
    },

    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- Helper function to find direnv Python path
            local function get_python_path()
                -- First check if we're in a direnv environment
                local handle = io.popen("echo $DIRENV_DIR")
                if not handle then return vim.fn.exepath("python3") end
                local direnv_dir = handle:read("*a"):gsub("%s+$", "")
                handle:close()

                if direnv_dir ~= "" then
                    -- Try to get the Python path from direnv
                    handle = io.popen("which python")
                    if not handle then return vim.fn.exepath("python3") end
                    local python_path = handle:read("*a"):gsub("%s+$", "")
                    handle:close()

                    if python_path ~= "" then
                        return python_path
                    end
                end

                -- Fallback: check for virtual env
                if vim.env.VIRTUAL_ENV then
                    return vim.env.VIRTUAL_ENV .. "/bin/python"
                end

                -- Last resort: use system Python
                return vim.fn.exepath("python3")
            end

            lspconfig.pylsp.setup({
                settings = {
                    pylsp = {
                      plugins = {
                        pycodestyle = {
                          ignore = {'W391'},
                          maxLineLength = 100
                        }
                      }
                    }
                }
            })

            -- Configure basedpyright (Python LSP)
            lspconfig.ruff.setup({
                init_options = {
                    settings = {
                        -- Modification to any of these settings has no effect.
                        enable = true,
                        ignoreStandardLibrary = true,
                        organizeImports       = true,
                        fixAll                = true,
                        lint = {
                            enable = true,
                            run    = 'onType',
                        }
                    },
                },
            })
            -- lspconfig.basedpyright.setup({
            --     on_attach = function(client, bufnr)
            --         -- LSP keymappings
            --         vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
            --         vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
            --         vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
            --         vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
            --         vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
            --
            --         -- Additional keybindings can be added here
            --         vim.keymap.set("n", "<leader>f", function()
            --             vim.lsp.buf.format({ async = true })
            --         end, { buffer = bufnr })
            --     end,
            --     settings = {
            --         python = {
            --             analysis = {
            --                 autoSearchPaths = true,
            --                 diagnosticMode = "workspace",
            --                 useLibraryCodeForTypes = true,
            --                 typeCheckingMode = "basic",
            --                 extraPaths = { "./", "./ckanext", "./ckan" },
            --                 logLevel = "Trace",
            --             },
            --             pythonPath = get_python_path(),
            --         },
            --     },
            --     before_init = function(_, config)
            --         -- This ensures the Python path is refreshed for each project
            --         config.settings.python.pythonPath = get_python_path()
            --     end,
            -- })

            -- Configure ruff for linting and formatting
            -- lspconfig.ruff.setup({})
        end,
    },

    -- Syntax highlighting enhancement
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "python",
                    "javascript",
                    "rust",
                    "lua",
                },
                highlight = {
                    enable = true,
                },
            })
        end,
    },

    -- Autocompletion setup
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },
}
