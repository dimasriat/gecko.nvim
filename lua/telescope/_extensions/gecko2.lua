local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
    error("gecko.nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
    exports = {
        coingecko = require("telescope._extensions.coingecko"),
    },
})
