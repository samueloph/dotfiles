return {
    "cbochs/grapple.nvim",
    opts = {
        scope = "static", -- also try out "git_branch"
        icons = true, -- setting to "true" requires "nvim-web-devicons"
        status = true,
    },
    keys = {
        { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
        { "<c-e>", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },

        { "<c-j>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
        { "<c-k>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
        { "<c-l>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
        { "<c-h>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },

        { "<c-s-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
        { "<c-s-p>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
    },
}
