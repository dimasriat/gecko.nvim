local curl = require("plenary.curl")

local M = {}

function M.fetch_url(req_url)
    local response = curl.request {
        url = req_url,
        method = "get",
        accept = "application/json"
    }
    if response.status == 429 then
        print("Got rate limitted. Please try again a minute later.")
    end
    if response.status ~= 200 then
        error("Could not make request")
    end
    return response.body
end

return M
