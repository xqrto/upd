-- Robust NoClip GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NoClipGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0,20,0,20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "NoClip (xqrto)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0,180,0,40)
toggleBtn.Position = UDim2.new(0,10,0,40)
toggleBtn.Text = "Toggle NoClip"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSans
toggleBtn.TextSize = 18

-- NoClip Logic
local Clip = true
local NoclipConnection = nil

local function setCollisions(state)
    if player.Character then
        for _,v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") and v ~= player.Character:FindFirstChild("HumanoidRootPart") then
                v.CanCollide = state
            end
        end
    end
end

local function noclip()
    Clip = false
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        setCollisions(false)
    end)
end

local function clip()
    Clip = true
    if NoclipConnection then NoclipConnection:Disconnect() end
    -- Sanftes Reaktivieren: kurz warten, damit Physics sich stabilisiert
    setCollisions(true)
end

toggleBtn.MouseButton1Click:Connect(function()
    if Clip then
        noclip()
        toggleBtn.Text = "NoClip ON"
    else
        clip()
        toggleBtn.Text = "NoClip OFF"
    end
end)
