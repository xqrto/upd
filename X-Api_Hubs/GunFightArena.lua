local allowedPlaceIds = {
    14518422161,
}

local function isAllowed(id)
    for _, allowedId in ipairs(allowedPlaceIds) do
        if id == allowedId then
            return true
        end
    end
    return false
end

local currentId = game.PlaceId

local StarterGui = game:GetService("StarterGui")

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 4
    })
end

if isAllowed(currentId) then
    notify("X-Api", "Game supported")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"))()
else
    notify("X-Api", "Game not supported")
end
