local data_home = vim.env.HOME .. "/.local/share/nvim-bookmark"
local storage = data_home .. "/bookmark"

if not vim.uv.fs_stat(data_home) then
    vim.fn.mkdir(data_home)
end

local file = io.open(storage, "w+")
if file then
    file:close()
end

function save_bookmark(data)
    local file = io.open(storage, "a+")
    if not file then
        return
    end
    file:write(data)
    file:close()
end

function serialize_bookmark(bookmark)
    return bookmark.path .. "%%" .. bookmark.line .. "\n"
end

function serialize_bookmark_list(bookmark_list)
    local result = ""
    for _, bookmark in pairs(bookmark_list) do
        result = result .. serialize_bookmark(bookmark)
    end
    return result
end

local bookmark_list = {
    {
        path = "/home/yongjoon/repos/nvim-bookmark",
        line = 22
    },
    {
        path = "/home/yongjoon/repos/nvim-bookmark",
        line = 23
    },
    {
        path = "/home/yongjoon/repos/nvim-bookmark",
        line = 24
    },
}

local data = serialize_bookmark_list(bookmark_list)
save_bookmark(data)

