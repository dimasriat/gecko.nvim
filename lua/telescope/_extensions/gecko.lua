local has_telescope, telescope = pcall(require, "telescope")
local find_coin = require("telescope._extensions.find_coin")

if not has_telescope then
    error("gecko.nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    exports = {
        find_coin = find_coin,
    },
})
