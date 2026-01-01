local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- CLEANUP
if _G.FlingConnection then _G.FlingConnection:Disconnect() end
local oldGui = lp.PlayerGui:FindFirstChild("Aura_Master_v2")
if oldGui then oldGui:Destroy() end

-- SETTINGS
local settings = {
    color = Color3.fromRGB(255, 0, 0),
    distance = 7,
    height = 1,
    transparency = 0.5,
    glowStrength = 10,
    orbitSpeed = 15,
    waveSpeed = 10,
    maxSearchDist = 300
}

local auraParts = {}
local attacking = false
local targetObject = nil

-- CONSTANTS
local MAGNET_FORCE = 5000   
local FFE_POWER = 99999999
local WAVE_WIDTH = 4     
local FOLLOW_DIST = 6    

--------------------------------------------------
-- TOOL AUTO-GIVER (Gibt Tools sofort zurück)
--------------------------------------------------
local function giveTools()
    local tool1Name = "1. [Add Part]"
    local tool2Name = "2. [Aura Punch]"
    
    local t1 = lp.Backpack:FindFirstChild(tool1Name) or (lp.Character and lp.Character:FindFirstChild(tool1Name))
    local t2 = lp.Backpack:FindFirstChild(tool2Name) or (lp.Character and lp.Character:FindFirstChild(tool2Name))
    
    if not t1 then
        local addTool = Instance.new("Tool")
        addTool.Name = tool1Name
        addTool.RequiresHandle = false
        addTool.Parent = lp.Backpack
        
        addTool.Activated:Connect(function()
            local t = mouse.Target
            if t and not t.Anchored and not table.find(auraParts, t) then
                pcall(function() t.AssemblyLinearVelocity = Vector3.new(0,1,0) end)
                table.insert(auraParts, t)
            end
        end)
    end
    
    if not t2 then
        local punchTool = Instance.new("Tool")
        punchTool.Name = tool2Name
        punchTool.RequiresHandle = false
        punchTool.Parent = lp.Backpack
        
        punchTool.Activated:Connect(function()
            if #auraParts == 0 or attacking then return end
            if mouse.Target then
                local m = mouse.Target:FindFirstAncestorOfClass("Model")
                targetObject = (m and m:FindFirstChildOfClass("Humanoid")) and m or mouse.Target
                attacking = true
                task.wait(4)
                attacking = false
                targetObject = nil
            end
        end)
    end
end

-- Prüfe alle 1 Sekunde, ob die Tools noch da sind
task.spawn(function()
    while task.wait(1) do
        giveTools()
    end
end)

--------------------------------------------------
-- MODERN GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "Aura_Master_v2"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.fromOffset(260, 450)
mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "AURA SETTINGS"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local container = Instance.new("ScrollingFrame", mainFrame)
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 600)
container.ScrollBarThickness = 2

local function createSlider(name, yPos, default, min, max, callback)
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20); label.Position = UDim2.new(0, 0, 0, yPos)
    label.Text = name .. ": " .. default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextSize = 12

    local bg = Instance.new("Frame", container)
    bg.Size = UDim2.new(1, 0, 0, 6); bg.Position = UDim2.new(0, 0, 0, yPos + 22); bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", bg)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill)

    local btn = Instance.new("TextButton", bg)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""

    local dragging = false
    local function update()
        local percent = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * percent) * 10) / 10
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. val
        callback(val)
    end
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function() if dragging then update() end end)
end

-- Sliders Setup
local r, g, b = 1, 0, 0
createSlider("Color: Red", 0, 255, 0, 255, function(v) r = v/255 settings.color = Color3.new(r,g,b) end)
createSlider("Color: Green", 45, 0, 0, 255, function(v) g = v/255 settings.color = Color3.new(r,g,b) end)
createSlider("Color: Blue", 90, 0, 0, 255, function(v) b = v/255 settings.color = Color3.new(r,g,b) end)
createSlider("Orbit Distance", 150, 7, 2, 30, function(v) settings.distance = v end)
createSlider("Height (Y-Axis)", 195, 1, -10, 20, function(v) settings.height = v end)
createSlider("Orbit Speed", 240, 15, 0, 50, function(v) settings.orbitSpeed = v end)
createSlider("Wave Speed", 285, 10, 0, 50, function(v) settings.waveSpeed = v end)
createSlider("Transparency", 330, 0.5, 0, 1, function(v) settings.transparency = v end)
createSlider("Glow Power", 375, 10, 1, 40, function(v) settings.glowStrength = v end)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
local angle, waveTimer = 0, 0

_G.FlingConnection = RunService.Heartbeat:Connect(function(dt)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    -- ESP Visuals (Nur wenn Add-Tool gehalten wird)
    local tool1 = lp.Backpack:FindFirstChild("1. [Add Part]") or (lp.Character and lp.Character:FindFirstChild("1. [Add Part]"))
    if tool1 and tool1.Parent == char then
        for _, p in ipairs(workspace:GetPartBoundsInRadius(hrp.Position, settings.maxSearchDist)) do
            if not p.Anchored and not p:IsDescendantOf(char) and not p:FindFirstChild("AuraESP") then
                local h = Instance.new("Highlight", p); h.Name = "AuraESP"; h.FillTransparency = 0.5; h.FillColor = Color3.new(1,1,1)
                task.delay(0.2, function() if h then h:Destroy() end end)
            end
        end
    end

    angle = angle + dt * settings.orbitSpeed
    waveTimer = waveTimer + dt * settings.waveSpeed

    for i, part in ipairs(auraParts) do
        if not part or not part:IsDescendantOf(workspace) then table.remove(auraParts, i); continue end

        part.CanCollide = false
        part.Transparency = settings.transparency
        
        local f = part:FindFirstChild("AuraF") or Instance.new("Fire", part); f.Name = "AuraF"
        f.Color = settings.color; f.Size = settings.glowStrength / 2
        
        local l = part:FindFirstChild("AuraL") or Instance.new("PointLight", part); l.Name = "AuraL"
        l.Color = settings.color; l.Brightness = settings.glowStrength / 5

        if attacking and targetObject then
            local tPos = (targetObject:IsA("Model") and targetObject:GetPivot().Position) or targetObject.Position
            part.AssemblyLinearVelocity = (tPos - part.Position).Unit * MAGNET_FORCE
            if (tPos - part.Position).Magnitude < 4 then part.AssemblyLinearVelocity = hrp.Velocity * FFE_POWER end
        else
            local dist = (part.Position - hrp.Position).Magnitude
            if dist > 25 then
                part.AssemblyLinearVelocity = (hrp.Position - part.Position).Unit * 250
            else
                local targetPos
                if hum.MoveDirection.Magnitude > 0 then
                    targetPos = hrp.Position - (hum.MoveDirection * (FOLLOW_DIST + (i*0.8))) + (hrp.CFrame.RightVector * math.sin(waveTimer + i) * WAVE_WIDTH) + Vector3.new(0, settings.height, 0)
                else
                    local offset = i * (math.pi * 2 / #auraParts)
                    targetPos = hrp.Position + Vector3.new(math.cos(angle + offset) * settings.distance, settings.height, math.sin(angle + offset) * settings.distance)
                end
                part.AssemblyLinearVelocity = (targetPos - part.Position) * 25
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F8 then mainFrame.Visible = not mainFrame.Visible end
end)
