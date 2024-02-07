local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("gecko.nvim requires nvim-telescope/telescope.nvim")
end

local function find_coin()
end

return telescope.register_extension({
    exports = {
        find_coin = find_coin,
    },
})
