-- This file is loaded when using nvim within vscode, it enables integrations
-- such as opening different modals using nvim keybindings and other purposes.

local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

-- diagnostics --
vim.keymap.set('n', ']d', notify "editor.action.marker.nextInFiles")
vim.keymap.set('n', '[d', notify "editor.action.marker.prevInFiles")