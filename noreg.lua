local player = game.Players.LocalPlayer

local function safeDestroy(obj)
    if obj and obj.Destroy then
        pcall(function() obj:Destroy() end)
    end
end

local characterModel = workspace:FindFirstChild(player.Name)
