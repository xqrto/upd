--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local player = game.Players.LocalPlayer

local function safeDestroy(obj)
    if obj and obj.Destroy then
        pcall(function() obj:Destroy() end)
    end
end

local characterModel = workspace:FindFirstChild(player.Name)
if characterModel then
    safeDestroy(characterModel:FindFirstChild("RagdollClient"))
end

local coreGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
if coreGui then
    local modules = coreGui:FindFirstChild("Modules")
    if modules and modules:FindFirstChild("Common") then
        safeDestroy(modules.Common:FindFirstChild("RagdollRigging"))
    end
end

local replicatedStorage = game:GetService("ReplicatedStorage")
if replicatedStorage then
    if replicatedStorage:FindFirstChild("Controllers") then
        safeDestroy(replicatedStorage.Controllers:FindFirstChild("RagdollController"))
    end
    safeDestroy(replicatedStorage:FindFirstChild("Packages"))
end

safeDestroy(game:GetService("StarterPlayer").StarterCharacterScripts:FindFirstChild("RagdollClient"))
