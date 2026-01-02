local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- CLEANUP
if _G.VehicleFlyConn then _G.VehicleFlyConn:Disconnect() end
if lp.PlayerGui:FindFirstChild("Tkns_VehicleFly_Ultra") then lp.PlayerGui.Tkns_VehicleFly_Ultra:Destroy() end

_G.FlyEnabled = true
_G.Noclip = false
_G.AntiFlip = true

local flySettings = {
    speed = 100,
    minimized = false
}

--------------------------------------------------
-- GUI DESIGN
--------------------------------------------------
local gui = Instance.new("ScreenGui", lp.PlayerGui); gui.Name = "Tkns_VehicleFly_Ultra"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.fromOffset(260, 320); main.Position = UDim2.new(0.05, 0, 0.2, 0); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.Active = true; main.Draggable = true
Instance.new("UICorner", main)

local titleFrame = Instance.new("Frame", main); titleFrame.Size = UDim2.new(1, 0, 0, 35); titleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); titleFrame.BorderSizePixel = 0
Instance.new("UICorner", titleFrame)
local titleLabel = Instance.new("TextLabel", titleFrame); titleLabel.Size = UDim2.new(1, -60, 1, 0); titleLabel.Position = UDim2.fromOffset(12, 0); titleLabel.Text = "Vehicle Fly v2"; titleLabel.TextColor3 = Color3.new(1,1,1); titleLabel.Font = "GothamBold"; titleLabel.TextSize = 14; titleLabel.BackgroundTransparency = 1; titleLabel.TextXAlignment = "Left"

-- CLOSE & MINIMIZE
local closeBtn = Instance.new("TextButton", titleFrame); closeBtn.Size = UDim2.fromOffset(25, 25); closeBtn.Position = UDim2.new(1, -30, 0.5, -12); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); closeBtn.Font = "GothamBold"
Instance.new("UICorner", closeBtn)

local content = Instance.new("Frame", main); content.Size = UDim2.new(1, 0, 1, -35); content.Position = UDim2.fromOffset(0, 35); content.BackgroundTransparency = 1

local function createToggle(text, yPos, globalVar)
    local btn = Instance.new("TextButton", content); btn.Size = UDim2.new(1, -20, 0, 35); btn.Position = UDim2.fromOffset(10, yPos); btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40); btn.Text = text .. ": " .. (_G[globalVar] and "ON" or "OFF"); btn.TextColor3 = Color3.new(1,1,1); btn.Font = "Gotham"; btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
        btn.Text = text .. ": " .. (_G[globalVar] and "ON" or "OFF")
    end)
end

-- UI ELEMENTS
createToggle("Fly System", 10, "FlyEnabled")
createToggle("Noclip (Durch Wände)", 50, "Noclip")
createToggle("Stabilität (Anti-Flip)", 90, "AntiFlip")

-- SPEED SLIDER
local sLabel = Instance.new("TextLabel", content); sLabel.Size = UDim2.new(1, 0, 0, 20); sLabel.Position = UDim2.fromOffset(12, 140); sLabel.Text = "Geschwindigkeit: " .. flySettings.speed; sLabel.TextColor3 = Color3.new(1,1,1); sLabel.BackgroundTransparency = 1; sLabel.Font = "Gotham"; sLabel.TextSize = 12; sLabel.TextXAlignment = "Left"
local bar = Instance.new("Frame", content); bar.Size = UDim2.new(1, -30, 0, 8); bar.Position = UDim2.fromOffset(15, 165); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
local fill = Instance.new("Frame", bar); fill.Size = UDim2.new(flySettings.speed/1000, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); fill.BorderSizePixel = 0
local sBtn = Instance.new("TextButton", bar); sBtn.Size = UDim2.new(1, 0, 1, 0); sBtn.BackgroundTransparency = 1; sBtn.Text = ""

sBtn.MouseButton1Down:Connect(function()
    local conn; conn = RunService.RenderStepped:Connect(function()
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
        local relPos = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        flySettings.speed = math.floor(relPos * 1000)
        sLabel.Text = "Geschwindigkeit: " .. flySettings.speed
        fill.Size = UDim2.new(relPos, 0, 1, 0)
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    if _G.VehicleFlyConn then _G.VehicleFlyConn:Disconnect() end
    gui:Destroy()
end)

--------------------------------------------------
-- FLY ENGINE
--------------------------------------------------
_G.VehicleFlyConn = RunService.Heartbeat:Connect(function()
    if not _G.FlyEnabled then return end
    
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") then
        local seat = char.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            local root = seat
            local vel = Vector3.new(0, 0.05, 0)
            local cam = workspace.CurrentCamera
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + (cam.CFrame.LookVector * flySettings.speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - (cam.CFrame.LookVector * flySettings.speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - (cam.CFrame.RightVector * flySettings.speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + (cam.CFrame.RightVector * flySettings.speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0, flySettings.speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0, flySettings.speed, 0) end
            
            root.AssemblyLinearVelocity = vel
            
            if _G.AntiFlip then
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            
            -- NOCLIP LOGIC
            if _G.Noclip then
                local vehicle = seat.Parent
                while vehicle and not vehicle:IsA("Model") do vehicle = vehicle.Parent end
                if vehicle then
                    for _, part in ipairs(vehicle:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)
