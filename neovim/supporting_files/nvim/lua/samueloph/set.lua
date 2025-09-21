vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

vim.opt.spell = true

vim.api.nvim_set_keymap('n', '<C-N>', ":NvimTreeToggle<CR>", { noremap = true })

-- Highlight trailing whitespaces
vim.api.nvim_set_hl(0, 'ExtraWhitespace', { bg = 'red' })

-- Create autocmd for trailing whitespace highlighting
vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertLeave", "TextChanged" }, {
    pattern = "*",
    callback = function()
        vim.fn.matchadd('ExtraWhitespace', [[\s\+$]])
    end,
    desc = "Highlight trailing whitespace",
})


-- Press return to temporarily get out of the highlighted search
-- https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches
vim.keymap.set('n', '<CR>', ':nohlsearch<CR><CR>', { silent = true })

-- Open file on last place visited
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})


-- Function to check if file has been modified externally
local function check_file_changed()
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath == '' then return false end

    local mod_time = vim.fn.getftime(filepath)
    local last_known_mod_time = vim.b[bufnr].last_known_mod_time or mod_time

    if mod_time > last_known_mod_time then
        vim.b[bufnr].last_known_mod_time = mod_time
        return true
    end
    return false
end

-- Trigger `autoread` when files changes on disk
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    callback = function()
        if vim.api.nvim_get_mode().mode ~= 'c' then
            local bufnr = vim.api.nvim_get_current_buf()
            local is_modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
            local file_changed = check_file_changed()

            if file_changed then
                if is_modified then
                    -- File changed externally and we have local modifications
                    vim.api.nvim_echo({
                        { 'Warning: ', 'WarningMsg' },
                        { 'File changed on disk and you have local modifications!\n', 'None' },
                        { 'Use :checktime to reload from disk or :w to save your changes.', 'None' }
                    }, true, {})
                else
                    -- File changed externally but no local modifications, safe to reload
                    vim.cmd('checktime')
                end
            end
        end
    end,
})

-- Notification after file change
vim.api.nvim_create_autocmd('FileChangedShellPost', {
    callback = function()
        if not vim.api.nvim_buf_get_option(0, 'modified') then
            vim.api.nvim_echo({
                { 'File changed on disk. Buffer reloaded.', 'WarningMsg' }
            }, true, {})
        end
    end,
})
