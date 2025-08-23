return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    options = { theme = 'gruvbox'},
    config = function ()
        require('lualine').setup {
            sections = {
                lualine_b = { "grapple" },
                lualine_c = {
                    {
                        'filename',
                        file_status = true, -- displays file status (readonly status, modified status)
                        path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
                    }
                }
            },
            tabline = {
                lualine_a = {
                    {
                        function()
                            local tags = require("grapple").tags()
                            if not tags then return "" end
                            local current_buf_path = vim.fn.expand('%:p')
                            return table.concat(vim.tbl_map(function(tag)
                                -- local redacted_path = vim.fn.fnamemodify(tag.path, ":~:.")
                                local redacted_path = vim.fn.fnamemodify(tag.path, ":t")
                                if tag.path == current_buf_path then
                                    return "[" .. redacted_path .. "]"  -- or use * or any other indicator you prefer
                                end
                                return redacted_path
                            end, tags), " | ")
                        end,
                    }
                }
            },
        }
    end
}
