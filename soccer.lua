local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AutoBallFFE_GUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(250,180)
frame.Position = UDim2.fromScale(0.4,0.4)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Soccer Fling(xqrto)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local selectBtn = Instance.new("TextButton", frame)
selectBtn.Size = UDim2.fromOffset(230,30)
selectBtn.Position = UDim2.fromOffset(10,40)
selectBtn.Text = "Target"

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(230,30)
toggleBtn.Position = UDim2.fromOffset(10,80)
toggleBtn.Text = "Fling: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.fromOffset(230,50)
info.Position = UDim2.fromOffset(10,120)
info.TextWrapped = true
info.TextScaled = true
info.Text = "Equip Soccer start fling trow"
info.TextColor3 = Color3.new(1,1,1)
info.BackgroundTransparency = 1

--------------------------------------------------
-- TARGET DROPDOWN
--------------------------------------------------
local selectedPlayer
local drop = {}

local function clearDrop()
    for _,b in pairs(drop) do b:Destroy() end
    drop = {}
end

selectBtn.MouseButton1Click:Connect(function()
    clearDrop()
    local y = 115
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.fromOffset(230,22)
            b.Position = UDim2.fromOffset(10,y)
            b.Text = plr.Name
            b.Parent = frame

            b.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selectBtn.Text = "Target: "..plr.Name
                clearDrop()
            end)

            table.insert(drop,b)
            y += 24
        end
    end
end)

--------------------------------------------------
-- AUTO BALL FFE LOGIC
--------------------------------------------------
local ENABLED = false

-- SETTINGS
local MAGNET_FORCE = 1000
local HIT_DISTANCE = 2.5
local FFE_POWER = 99999999

local function getBall()
    return workspace:FindFirstChild("Soccer"..lp.Name, true)
end

RunService.Heartbeat:Connect(function()
    if not ENABLED then return end
    if not selectedPlayer or not selectedPlayer.Character then return end
    if not lp.Character then return end

    local targetHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = lp.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local ball = getBall()
    if not ball or not ball:IsA("BasePart") then return end

    ball.Anchored = false
    ball.CanCollide = true

    local dir = (targetHRP.Position - ball.Position)
    local dist = dir.Magnitude

    -- 🧲 AUTO-MAGNET → Ball geht in den Spieler
    if dist > HIT_DISTANCE then
        ball.AssemblyLinearVelocity =
            dir.Unit * MAGNET_FORCE + Vector3.new(0,10,0)
        return
    end

    -- 🔥 FFE → Walk-Fling-Bewegungsart auf BALL
    local vel = myHRP.Velocity

    ball.AssemblyLinearVelocity =
        vel * FFE_POWER + Vector3.new(0, FFE_POWER, 0)

    RunService.RenderStepped:Wait()
    ball.AssemblyLinearVelocity = vel
end)

--------------------------------------------------
-- TOGGLE
--------------------------------------------------
toggleBtn.MouseButton1Click:Connect(function()
    ENABLED = not ENABLED
    if ENABLED then
        toggleBtn.Text = "Fling: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggleBtn.Text = "Fling: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)
