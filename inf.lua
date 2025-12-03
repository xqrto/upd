local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local target = workspace:WaitForChild("ShrineTrigger") -- or any part you want
local buttonUI = script.Parent:WaitForChild("GrabButton") -- your ScreenGui button

local range = 20 -- set your desired distance

game:GetService("RunService").RenderStepped:Connect(function()
    if target and hrp then
        local dist = (hrp.Position - target.Position).Magnitude
        buttonUI.Visible = dist <= range
    end
end)

buttonUI.MouseButton1Click:Connect(function()
    -- shrine-clean action here
    print("Grabbed from distance!")
end)
