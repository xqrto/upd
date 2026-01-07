local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

------------------------------------------------------------------------
-- 1. SETTINGS & STATE
------------------------------------------------------------------------
local settings = {
    aimlock = false,        -- Toggle Aimlock
    triggerbot = false,     -- Toggle Triggerbot
    teamCheck = true,       -- Toggle Team Check
    wallCheck = true,       -- Toggle Visibility Check
    fovEnabled = true,      -- Toggle FOV Circle
    
    fovRadius = 150,        -- Slider Value
    smoothness = 0.5,       -- Slider Value (0.1 - 1.0)
    triggerDelay = 0.1      -- Cooldown
}

local state = {
    guiDragging = false,
    sliderDragging = false, -- Verhindert Window-Drag beim Slider bewegen
    rightMouseDown = false,
    lastShot = 0,
    target = nil
}

------------------------------------------------------------------------
-- 2. GUI CREATION (Modern & Complete)
------------------------------------------------------------------------
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup altes GUI
if playerGui:FindFirstChild("UltimateAimGui") then
    playerGui.UltimateAimGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateAimGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- WICHTIG: Fixt, dass der Kreis nicht mittig ist
screenGui.Parent = playerGui

-- Main Window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Top Bar (Drag & Title)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner"); topCorner.CornerRadius = UDim.new(0, 8); topCorner.Parent = topBar
-- Fix bottom corners of topbar
local topFix = Instance.new("Frame"); topFix.Size = UDim2.new(1,0,0,10); topFix.Position = UDim2.new(0,0,1,-10); topFix.BackgroundColor3 = Color3.fromRGB(35,35,40); topFix.BorderSizePixel=0; topFix.Parent=topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Text = "ULTIMATE AIM SUITE"
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 16
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.Size = UDim2.new(1, -50, 1, 0)
titleLbl.Position = UDim2.new(0, 15, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Text = "-"
minBtn.Size = UDim2.new(0, 40, 0, 40)
minBtn.Position = UDim2.new(1, -40, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.Parent = topBar

-- Content Container
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = content
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

------------------------------------------------------------------------
-- 3. UI HELPER FUNCTIONS (Toggles & Sliders)
------------------------------------------------------------------------
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    frame.BorderSizePixel = 0
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = frame
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(1, -25, 0.5, -6)
    indicator.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    indicator.BorderSizePixel = 0
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(1,0); ic.Parent = indicator
    indicator.Parent = frame
    
    local active = default
    btn.MouseButton1Click:Connect(function()
        active = not active
        indicator.BackgroundColor3 = active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        callback(active)
    end)
    
    frame.Parent = content
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text .. ": " .. default
    label.Parent = frame
    
    local slideBg = Instance.new("Frame")
    slideBg.Size = UDim2.new(1, 0, 0, 8)
    slideBg.Position = UDim2.new(0, 0, 0, 25)
    slideBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    slideBg.BorderSizePixel = 0
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = slideBg
    slideBg.Parent = frame
    
    local fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    fill.Parent = slideBg
    
    local trigger = Instance.new("TextButton")
    trigger.Size = UDim2.new(1, 0, 1, 0) -- Größerer Hitbox
    trigger.BackgroundTransparency = 1
    trigger.Text = ""
    trigger.Parent = slideBg
    
    local dragging = false
    
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            state.sliderDragging = true -- Sperrt Window-Drag
        end
    end)
    
    trigger.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            state.sliderDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mLoc = UserInputService:GetMouseLocation().X
            local rLoc = mLoc - slideBg.AbsolutePosition.X
            local p = math.clamp(rLoc / slideBg.AbsoluteSize.X, 0, 1)
            
            fill.Size = UDim2.new(p, 0, 1, 0)
            local val = min + (p * (max - min))
            
            -- Runden
            if max <= 1 then -- Float für Smoothness
                val = math.floor(val * 100) / 100
            else -- Int für Radius
                val = math.floor(val)
            end
            
            label.Text = text .. ": " .. val
            callback(val)
        end
    end)
    
    frame.Parent = content
end

-- Elemente hinzufügen
createToggle("Enable Aimlock (RMB)", false, function(v) settings.aimlock = v end)
createToggle("Enable Triggerbot", false, function(v) settings.triggerbot = v end)
createToggle("Wall Check (Visibility)", true, function(v) settings.wallCheck = v end)
createToggle("Team Check", true, function(v) settings.teamCheck = v end)
createToggle("Draw FOV Circle", true, function(v) settings.fovEnabled = v end)

createSlider("FOV Radius", 50, 500, settings.fovRadius, function(v) settings.fovRadius = v end)
createSlider("Lock Speed (Smooth)", 0.01, 1.0, settings.smoothness, function(v) settings.smoothness = v end)

------------------------------------------------------------------------
-- 4. GUI LOGIC (Drag & Minimize)
------------------------------------------------------------------------
local dragStart, startPos
local isMin = false

minBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 40), "Out", "Quad", 0.3, true)
        content.Visible = false
        minBtn.Text = "+"
    else
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 420), "Out", "Quad", 0.3, true)
        content.Visible = true
        minBtn.Text = "-"
    end
end)

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.guiDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.guiDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and state.guiDragging and not state.sliderDragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Rechte Maustaste & Keys
UserInputService.InputBegan:Connect(function(input, p)
    if p then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        state.rightMouseDown = true
    end
    if input.KeyCode == Enum.KeyCode.RightControl then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        state.rightMouseDown = false
    end
end)

------------------------------------------------------------------------
-- 5. AIM LOGIC (Visuals & Mechanics)
------------------------------------------------------------------------

-- FOV Circle
local circle = Instance.new("ImageLabel")
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.BackgroundTransparency = 1
circle.Image = "rbxassetid://87107069659024"
circle.ImageTransparency = 0.4
circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
circle.ZIndex = 0
circle.Parent = screenGui

local function checkWall(targetPart)
    if not settings.wallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    -- WICHTIG: Kamera und eigenen Charakter ausschließen
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local res = Workspace:Raycast(origin, dir, params)
    
    if res then
        -- Wenn wir etwas treffen, muss es zum Gegner gehören
        if res.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false -- Wand getroffen
    end
    return true -- Freie Sicht
end

local function getClosest()
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, settings.fovRadius
    
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if settings.teamCheck and p.Team == LocalPlayer.Team then continue end
        
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum.Health > 0 then
                local part = char.HumanoidRootPart -- Oder "Head"
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        -- Check Visibility
                        if checkWall(part) then
                            closestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Trigger Action
local function shoot()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end

------------------------------------------------------------------------
-- 6. MAIN LOOP
------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Update Circle
    local m = UserInputService:GetMouseLocation()
    circle.Visible = settings.fovEnabled
    circle.Position = UDim2.new(0, m.X, 0, m.Y)
    circle.Size = UDim2.new(0, settings.fovRadius*2, 0, settings.fovRadius*2)
    
    -- Target Logic
    local target = nil
    if state.rightMouseDown or settings.triggerbot then
        target = getClosest()
    end
    
    -- Visual Feedback
    if target then
        circle.ImageColor3 = Color3.fromRGB(255, 50, 50)
    else
        circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Aimlock
    if target and settings.aimlock and state.rightMouseDown then
        local curCF = Camera.CFrame
        local targetCF = CFrame.lookAt(curCF.Position, target.Position)
        Camera.CFrame = curCF:Lerp(targetCF, settings.smoothness)
    end
    
    -- Triggerbot
    if target and settings.triggerbot then
        -- Extra Check: Maus muss nah am Ziel sein
        local sPos = Camera:WorldToViewportPoint(target.Position)
        local dist = (Vector2.new(sPos.X, sPos.Y) - m).Magnitude
        
        if dist < 20 and (tick() - state.lastShot > settings.triggerDelay) then
            shoot()
            state.lastShot = tick()
        end
    end
end)
