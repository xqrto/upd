-- True NoClip LocalScript (normal laufen)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local noclip = false

-- Toggle mit N
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
        noclip = not noclip
        if noclip then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        else
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- RunService Loop
RunService.Stepped:Connect(function()
    if character and character.Parent then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = not noclip
            end
        end
    end
end)

-- Respawn Handhabung
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end)
