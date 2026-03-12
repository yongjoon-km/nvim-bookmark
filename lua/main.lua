local M = {}

local data_home = vim.env.HOME .. "/.local/share/nvim-bookmark"
local storage = data_home .. "/bookmark"

if not vim.uv.fs_stat(data_home) then
    vim.fn.mkdir(data_home)
end

if not vim.uv.fs_stat(storage) then
    local file = io.open(storage, "w+")
    if file then
        file:close()
    end
end

function save_bookmark(data)
    local file = io.open(storage, "w+")
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

function deserialize_bookmark_str(bookmark_str)
    return string.gmatch(bookmark_str, "([^%%%%]+)%%%%(%d+)")()
end

function load_bookmark()
    local file = io.open(storage, "r+")
    if not file then
        return
    end

    local bookmark_list = {}
    local line
    while true do
        line = file:read("*l")
        if line == nil then
            break
        end
        local path, line_num = deserialize_bookmark_str(line)
        local bookmark = {
            path = path,
            line = line_num,
        }
        table.insert(bookmark_list, bookmark)
    end
    file:close()
    return bookmark_list
end

function get_bookmark_from_current_location()
    local file_path = vim.fn.expand('%:p')
    local line = vim.fn.line('.')
    return {
        path = file_path,
        line = line,
    }
end

M.save_bookmark = function()
    local bookmark_list = load_bookmark()
    table.insert(bookmark_list, get_bookmark_from_current_location())
    save_bookmark(serialize_bookmark_list(bookmark_list))
end

M.select_bookmark = function()
    local bookmark_list = load_bookmark()
    local bookmark_str_list = {}
    for _, bookmark in pairs(bookmark_list) do
        table.insert(bookmark_str_list, serialize_bookmark(bookmark))
    end

    vim.ui.select(bookmark_str_list, {
        prompt = 'Select your bookmark',
    }, function(choice)
        local path, line_num = deserialize_bookmark_str(choice)
        vim.cmd("edit " .. "+" .. line_num .. " " .. path)
    end)
end

return M
