--[[--------------------------------------------------------------------
    Aimbot-FFA (spiel-intern)
    LocalScript -> StarterPlayerScripts
    - Jeder Spieler hat Aimbot als Gameplay-Mechanik
    - Kein CoreGui-Exploit, kein VirtualInputManager
    - performShot() als Hook für euer Waffen-/Feuer-System
----------------------------------------------------------------------]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SETTINGS (passte nach Wunsch an)
local teamCheck = true
local visibilityCheck = true
local aimlockEnabled = false
local triggerBotEnabled = false
local rightMouseDown = false
local guiVisible = true

local currentFOV = 100 -- Startradius
local minFOV, maxFOV = 50, 300
local aimSmooth = 0.5 -- 0 = instant, 1 = sehr smooth (0..1)

-- UI (in PlayerGui, nicht CoreGui)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (dragbar + buttons + slider)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 170, 170)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "AimBoT-FFA"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Button helper
local function createButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 280, 0, 28)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Parent = mainFrame
    return b
end

local fovBtn = createButton("FOV: OFF", 34)
local teamBtn = createButton("TeamCheck: ON", 68)
local visBtn = createButton("Visibility: ON", 102)
local aimBtn = createButton("Aimlock: OFF", 136)
local triggerBtn = createButton("TriggerBot: OFF", 170)

-- Slider
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 280, 0, 16)
sliderFrame.Position = UDim2.new(0, 10, 0, 204)
sliderFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
sliderFrame.Parent = mainFrame

local fill = Instance.new("Frame")
fill.Size = UDim2.new((currentFOV - minFOV) / (maxFOV - minFOV), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
fill.Parent = sliderFrame

-- FOV Circle (ImageLabel)
local FOVCircle = Instance.new("ImageLabel")
FOVCircle.Size = UDim2.new(0, currentFOV*2, 0, currentFOV*2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.65)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Image = "rbxassetid://87107069659024"
FOVCircle.ImageTransparency = 0
FOVCircle.ImageColor3 = Color3.fromRGB(255,255,255)
FOVCircle.Visible = false
FOVCircle.Parent = screenGui

-- Dragging logic für mainFrame und slider
local guiDragging = false
local sliderDragging = false
local dragOffset = Vector2.new()

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        guiDragging = true
        local mousePos = UserInputService:GetMouseLocation()
        dragOffset = Vector2.new(mousePos.X - mainFrame.AbsolutePosition.X, mousePos.Y - mainFrame.AbsolutePosition.Y)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if guiDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local m = UserInputService:GetMouseLocation()
        mainFrame.Position = UDim2.new(0, m.X - dragOffset.X, 0, m.Y - dragOffset.Y)
    end

    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = UserInputService:GetMouseLocation().X
        local posX = math.clamp(mouseX - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        fill.Size = UDim2.new(posX / sliderFrame.AbsoluteSize.X, 0, 1, 0)
        currentFOV = math.floor(minFOV + (posX / sliderFrame.AbsoluteSize.X) * (maxFOV - minFOV))
        FOVCircle.Size = UDim2.new(0, currentFOV*2, 0, currentFOV*2)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        guiDragging = false
        sliderDragging = false
    end
end)

sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)

-- Button Logic
fovBtn.MouseButton1Click:Connect(function()
    FOVCircle.Visible = not FOVCircle.Visible
    FOVBtnState = FOVCircle.Visible
    fovBtn.Text = "FOV: "..(FOVCircle.Visible and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    teamBtn.Text = "TeamCheck: "..(teamCheck and "ON" or "OFF")
end)

visBtn.MouseButton1Click:Connect(function()
    visibilityCheck = not visibilityCheck
    visBtn.Text = "Visibility: "..(visibilityCheck and "ON" or "OFF")
end)

aimBtn.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    aimBtn.Text = "Aimlock: "..(aimlockEnabled and "ON" or "OFF")
end)

triggerBtn.MouseButton1Click:Connect(function()
    triggerBotEnabled = not triggerBotEnabled
    triggerBtn.Text = "TriggerBot: "..(triggerBotEnabled and "ON" or "OFF")
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        aimlockEnabled = not aimlockEnabled
        aimBtn.Text = "Aimlock: "..(aimlockEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F7 then
        triggerBotEnabled = not triggerBotEnabled
        triggerBtn.Text = "TriggerBot: "..(triggerBotEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.F9 then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)

-- Right mouse state
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then rightMouseDown = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then rightMouseDown = false end
end)

-- Utilities
local function getPlayersCharacters()
    local chars = {}
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(chars, pl.Character)
        end
    end
    return chars
end

local function isVisible(targetPart)
    if not visibilityCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local res = workspace:Raycast(origin, dir.Unit * math.clamp(dir.Magnitude, 0, 2000), rayParams)
    if not res then return true end
    -- true if hit is part of the target model (descendant)
    if res.Instance and res.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- Gibt nächsten Ziel-Bodypart (HumanoidRootPart) zurück, oder nil
local function getClosestEnemy()
    local mousePos = UserInputService:GetMouseLocation()
    local best = nil
    local bestDist = math.huge

    for _, char in pairs(getPlayersCharacters()) do
        -- team check (nur wenn der player ein Team hat)
        if teamCheck and LocalPlayer.Team and char:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(char) and Players:GetPlayerFromCharacter(char).Team == LocalPlayer.Team then
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if hrp and humanoid and humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (screenVec - mousePos).Magnitude
                if dist <= currentFOV and dist < bestDist and isVisible(hrp) then
                    bestDist = dist
                    best = hrp
                end
            end
        end
    end

    return best
end

-- Hook: Schuss-Mechanik einbauen
-- Ersetze den Inhalt dieser Funktion so, dass es zu deinem Waffen-System passt.
-- Beispiele:
--  - Wenn du ein RemoteEvent "Fire" hast: ReplicatedStorage:WaitForChild("Fire"):FireServer(parameters)
--  - Wenn das Tool:Activate() verwendet, rufe Tool:Activate()
local function performShot()
    -- BEISPIEL: RemoteEvent namens "Fire" -> du kannst das anpassen
    local evt = ReplicatedStorage:FindFirstChild("Fire")
    if evt and evt:IsA("RemoteEvent") then
        -- Passe hier die Parameter an dein Spiel an
        evt:FireServer()
        return
    end

    -- FALLBACK: Wenn Spieler ein Tool hat, aktiviere es
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool.Parent == char then
                -- viele Waffensysteme reagieren auf Activate()
                tool:Activate()
                return
            end
        end
    end

    -- Wenn nichts vorhanden ist, nur debug
    -- print("performShot() wurde aufgerufen — integriere hier dein Feuer-Event.")
end

-- Tween helper für Farbe (smooth color change)
local function tweenCircleColor(targetColor, duration)
    local info = TweenInfo.new(duration or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(FOVCircle, info, {ImageColor3 = targetColor})
    tween:Play()
end

-- Main loop
RunService.RenderStepped:Connect(function()
    -- FOV folgt Maus
    local mousePos = UserInputService:GetMouseLocation()
    if FOVCircle.Visible then
        FOVCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    end

    -- Zielermittlung (nur wenn RMB down oder Trigger aktiv)
    local target = nil
    if rightMouseDown or triggerBotEnabled then
        target = getClosestEnemy()
    end

    -- FOV-Farbe (smooth tween)
    if target then
        tweenCircleColor(Color3.fromRGB(255,0,0))
    else
        tweenCircleColor(Color3.fromRGB(255,255,255))
    end

    -- Aimlock & Trigger (wenn target vorhanden und entweder RMB down OR triggerBot aktiv)
    if target and (rightMouseDown or triggerBotEnabled) then
        if aimlockEnabled then
            -- berechne Richtung & slerp/lerp Kamera (smooth)
            local camPos = Camera.CFrame.Position
            local desiredCFrame = CFrame.new(camPos, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, math.clamp(1 - aimSmooth, 0.01, 1))
        end

        if triggerBotEnabled then
            performShot()
        end
    end
end)

-- initiale UI states
FOVCircle.Visible = false
fovBtn.Text = "FOV: OFF"
teamBtn.Text = "TeamCheck: ON"
visBtn.Text = "Visibility: ON"
aimBtn.Text = "Aimlock: OFF"
triggerBtn.Text = "TriggerBot: OFF"
