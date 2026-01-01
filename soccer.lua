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
frame.Size = UDim2.fromOffset(300,250)
frame.Position = UDim2.fromScale(0.35,0.35)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

-- Titelbar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -60,1,0)
title.Position = UDim2.new(0,5,0,0)
title.Text = "Soccer Fling(xqrto)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-30,0,2)
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize Button
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0,25,0,25)
minBtn.Position = UDim2.new(1,-60,0,2)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 18

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(frame:GetChildren()) do
        if v ~= titleBar then
            v.Visible = not minimized
        end
    end
end)

-- Search Field
local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.fromOffset(230,25)
searchBox.Position = UDim2.fromOffset(10,40)
searchBox.PlaceholderText = "Search Player..."
searchBox.ClearTextOnFocus = false
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.Text = ""
searchBox.TextScaled = true

-- Dropdown Button
local selectBtn = Instance.new("TextButton", frame)
selectBtn.Size = UDim2.fromOffset(230,25)
selectBtn.Position = UDim2.fromOffset(10,70)
selectBtn.Text = "Target"
selectBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
selectBtn.TextColor3 = Color3.new(1,1,1)

-- Tool Button
local toolBtn = Instance.new("TextButton", frame)
toolBtn.Size = UDim2.fromOffset(230,25)
toolBtn.Position = UDim2.fromOffset(10,100)
toolBtn.Text = "Give Player Selector Tool"
toolBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toolBtn.TextColor3 = Color3.new(1,1,1)

-- Fling Toggle
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(230,30)
toggleBtn.Position = UDim2.fromOffset(10,135)
toggleBtn.Text = "Fling: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)

-- Info (Hilfstext, bleibt unverändert)
local info = Instance.new("TextLabel", frame)
info.Size = UDim2.fromOffset(230,50)
info.Position = UDim2.fromOffset(10,175)
info.TextWrapped = true
info.TextScaled = true
info.Text = "Equip Soccer, start fling throw"
info.TextColor3 = Color3.new(1,1,1)
info.BackgroundTransparency = 1

--------------------------------------------------
-- DROPDOWN LOGIC
--------------------------------------------------
local selectedPlayer
local drop = {}

local function clearDrop()
    for _,b in pairs(drop) do b:Destroy() end
    drop = {}
end

local function refreshDrop()
    clearDrop()
    local y = 125
    local searchText = string.lower(searchBox.Text)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Name:lower():find(searchText) then
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.fromOffset(230,22)
            b.Position = UDim2.fromOffset(10,y)
            b.Text = plr.Name
            b.BackgroundColor3 = Color3.fromRGB(50,50,50)
            b.TextColor3 = Color3.new(1,1,1)

            b.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selectBtn.Text = "Target: "..plr.Name
                clearDrop()
            end)

            table.insert(drop,b)
            y += 24
        end
    end
end

selectBtn.MouseButton1Click:Connect(refreshDrop)
searchBox:GetPropertyChangedSignal("Text"):Connect(refreshDrop)

--------------------------------------------------
-- GIVE PLAYER SELECTOR TOOL LOGIC
--------------------------------------------------
toolBtn.MouseButton1Click:Connect(function()
    if lp.Backpack:FindFirstChild("PlayerSelectorTool") then
        return -- Tool bereits vorhanden
    end

    local tool = Instance.new("Tool")
    tool.Name = "PlayerSelectorTool"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Parent = lp.Backpack

    tool.Equipped:Connect(function(mouse)
        -- Permanent Connection
        local conn
        conn = mouse.Button1Down:Connect(function()
            local targetPart = mouse.Target
            if targetPart and targetPart.Parent then
                local plr = Players:GetPlayerFromCharacter(targetPart.Parent)
                if plr and plr ~= lp then
                    selectedPlayer = plr
                    selectBtn.Text = "Target: "..plr.Name
                end
            end
        end)
        tool.Unequipped:Connect(function()
            conn:Disconnect()
        end)
    end)
end)

--------------------------------------------------
-- AUTO BALL FFE LOGIC
--------------------------------------------------
local ENABLED = false
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

    if dist > HIT_DISTANCE then
        ball.AssemblyLinearVelocity = dir.Unit * MAGNET_FORCE + Vector3.new(0,10,0)
        return
    end

    local vel = myHRP.Velocity
    ball.AssemblyLinearVelocity = vel * FFE_POWER + Vector3.new(0, FFE_POWER, 0)

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
