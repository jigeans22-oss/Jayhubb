-- loader.lua (PUBLIC, SAFE)

local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")

local HWID = Analytics:GetClientId()
local KEY = getgenv().SCRIPT_KEY

if not KEY then
    error("No key provided")
end

local response = request({
    Url = "https://api.authguard.org/v1/validate",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode({
        key = KEY,
        hwid = HWID
    })
})

local data = HttpService:JSONDecode(response.Body)

if not data.success then
    error(data.message or "Auth failed")
end

loadstring(data.script)()
