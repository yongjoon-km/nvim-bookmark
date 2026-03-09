local data_home = vim.env.HOME .. "/.local/share/nvim-bookmark"
local storage = data_home .. "/bookmark"

if not vim.uv.fs_stat(data_home) then
    vim.fn.mkdir(data_home)
end

local file = io.open(storage, "w+")
if file then
    file.close()
end
