local curl = require("plenary.curl")

local M = {}

local function get_request(req_url, decode_body_as_json)
    local response = curl.request{
        url=req_url,
        method="get",
        accept="application/json"
    }

    local response_decoded = nil

    if response.status ~= 200 then
        return {success=false, json_table=response_decoded}
    end

    if decode_body_as_json then
        response_decoded = vim.fn.json_decode(response.body)
    end

    return {success=true, json_table=response_decoded}
end

function M.get_random_user()
    local req_url = "https://random-data-api.com/api/v2/users"
    return get_request(req_url, true)
end

return M

