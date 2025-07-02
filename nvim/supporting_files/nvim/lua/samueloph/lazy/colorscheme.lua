-- return { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...}
return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                overrides = {
                    -- Preserve exact same colors from before for diffs
                    DiffAdd = { bg = "#32502d", fg = "#b8bb26" },     -- Keep original green contrast
                    DiffChange = { bg = "#2b3c44", fg = "#83a598" },  -- Keep original blue contrast
                    DiffDelete = { bg = "#3c2a2a", fg = "#fb4934" },  -- Keep original red contrast
                    DiffText = { bg = "#394f5a", fg = "#ebdbb2" },    -- Keep original text contrast
                    -- Sign column indicators remain unchanged
                    SignAdd = { fg = "#b8bb26", bg = "NONE" },
                    SignChange = { fg = "#83a598", bg = "NONE" },
                    SignDelete = { fg = "#fb4934", bg = "NONE" },
                    -- Line number column in diff view with original colors
                    DiffAddNr = { bg = "#32502d", fg = "#b8bb26" },
                    DiffChangeNr = { bg = "#2b3c44", fg = "#83a598" },
                    DiffDeleteNr = { bg = "#3c2a2a", fg = "#fb4934" },
                }
            })
            vim.o.background = 'dark'
            vim.cmd("colorscheme gruvbox")
        end
    }
}
