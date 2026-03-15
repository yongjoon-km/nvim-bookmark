# nvim-bookmark

This is simple bookmark feature on neovim. I created this because I make
bookmark on neovim to find some docs later from repositories I pulled on my
local machine.

## Installation

You can install `nvim-bookmark` with package manager.

- lazy.nvim
```lua
return {
    "yongjoon-km/nvim-bookmark",
    branch="main",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- Required by telescope
    },
    config = function()
        local nvim_bookmark = require('nvim-bookmark')
        local keymap = vim.keymap

        keymap.set("n", "<leader>bl", function() nvim_bookmark.select_bookmark() end)
        keymap.set("n", "<leader>bb", function() nvim_bookmark.save_bookmark() end)
        keymap.set("n", "<leader>bd", function() nvim_bookmark.delete_bookmark() end)
    end
}
```
