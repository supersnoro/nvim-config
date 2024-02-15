-- This file is loaded when using nvim within vscode, it enables integrations
-- such as opening different modals using nvim keybindings and other purposes.

local function VSCCmd(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

-- diagnostics --
vim.keymap.set('n', ']d', VSCCmd "editor.action.marker.nextInFiles")
vim.keymap.set('n', '[d', VSCCmd "editor.action.marker.prevInFiles")

-- Refactoring shortcuts --
vim.keymap.set('n', '<leader>rn', VSCCmd "editor.action.rename")
vim.keymap.set('n', '<leader>ca', VSCCmd "editor.action.quickFix")

-- Symbols navigation --
vim.keymap.set('n', '<leader>ds', VSCCmd "workbench.action.goToSymbol")
vim.keymap.set('n', '<leader>ws', VSCCmd "workbench.action.showAllSymbols")

-- MISC --
vim.keymap.set('n', '<C-k>', VSCCmd "editor.action.triggerParameterHints")