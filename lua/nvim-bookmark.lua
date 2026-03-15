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
    return bookmark.path .. "%%" .. bookmark.line
end

function serialize_bookmark_list(bookmark_list)
    local result = ""
    for _, bookmark in pairs(bookmark_list) do
        result = result .. serialize_bookmark(bookmark) .. "\n"
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
        if choice == nil then
            return
        end
        local path, line_num = deserialize_bookmark_str(choice)
        vim.cmd("edit " .. "+" .. line_num .. " " .. path)
    end)
end

M.delete_bookmark = function()
    -- TODO: Try to use only native buffer for multiple selection and remove 
    -- telescope dependency.
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local bookmark_list = load_bookmark()
    local bookmark_str_list = {}
    for _, bookmark in ipairs(bookmark_list) do
        table.insert(bookmark_str_list, serialize_bookmark(bookmark))
    end

    local function multi_select_example(opts)
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = "Select bookmarks to delete",
            finder = finders.new_table { results = opts.bookmark_list },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    local selections = picker:get_multi_selection()

                    -- If nothing is marked with <Tab>, take the current selection
                    if vim.tbl_isempty(selections) then
                        table.insert(selections, action_state.get_selected_entry())
                    end

                    actions.close(prompt_bufnr)

                    -- Remove selected bookmark and save
                    for _, v in ipairs(selections) do
                        for j, o in ipairs(bookmark_str_list) do
                            if v[1] == o then
                                table.remove(bookmark_str_list, j)
                            end
                        end
                    end

                    local result_bookmark = ""
                    for _, v in ipairs(bookmark_str_list) do
                        result_bookmark = result_bookmark .. v .. "\n"
                    end
                    save_bookmark(result_bookmark)
                end)
                return true
            end,
        }):find()
    end
    multi_select_example({bookmark_list = bookmark_str_list})
end

return M
