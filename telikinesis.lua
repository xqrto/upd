local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- CLEANUP
if _G.FlingConnection then _G.FlingConnection:Disconnect() end
local oldGui = lp.PlayerGui:FindFirstChild("Tkns_xqrto_Aura")
if oldGui then oldGui:Destroy() end

-- INITIAL SETTINGS
local settings = {
    color = Color3.fromRGB(0, 170, 255),
    distance = 7,
    height = 1,
    transparency = 0.5,
    glowStrength = 10,
    orbitSpeed = 15,
    waveSpeed = 10,
    maxSearchDist = 400,
    Red = 0, Green = 170, Blue = 255
}

local auraParts = {}
local shotItems = {} 
local manualMode = false 

-- PHYSIK KONSTANTEN
local FFE_POWER = 99999999
local MAGNET_FORCE = 8000
local MAX_RECALL_SPEED = 15000 -- Extrem schnell für weite Distanzen

--------------------------------------------------
-- TOOLS SYSTEM
--------------------------------------------------
local function giveTools()
    local configs = {
        {name = "add", func = function()
            local target = mouse.Target
            local newPart = nil
            if target and target:IsA("BasePart") and not target.Anchored and not target:IsDescendantOf(lp.Character) then
                newPart = target
            else
                local pos = mouse.Hit.Position
                for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, 5)) do
                    if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(lp.Character) then
                        newPart = p; break
                    end
                end
            end
            
            if newPart then
                for _, p in ipairs(auraParts) do 
                    p.CanCollide = true 
                    p.Transparency = 0
                end
                auraParts = {newPart}
                shotItems = {} 
                manualMode = false 
            end
        end},
        {name = "shoot", func = function()
            if #auraParts == 0 then return end
            local item = auraParts[1]
            if item and mouse.Target then
                manualMode = false
                local m = mouse.Target:FindFirstAncestorOfClass("Model")
                local target = (m and m:FindFirstChildOfClass("Humanoid")) and m or mouse.Target
                shotItems[item] = {target = target, returning = false, startTime = tick()}
                
                -- Automatischer Rückzug nach 6 Sekunden oder Treffer
                task.delay(6, function() 
                    if shotItems[item] then 
                        shotItems[item].returning = true 
                        -- Sicherheits-Teleport nach insgesamt 10 Sekunden
                        task.wait(4)
                        if shotItems[item] then
                            item.CFrame = lp.Character:GetPivot()
                            shotItems[item] = nil
                        end
                    end 
                end)
            end
        end},
        {name = "Precision Control", func = nil}
    }
    
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        for _, c in ipairs(configs) do
            if not backpack:FindFirstChild(c.name) and not (lp.Character and lp.Character:FindFirstChild(c.name)) then
                local t = Instance.new("Tool"); t.Name = c.name; t.RequiresHandle = false; t.Parent = backpack
                if c.func then t.Activated:Connect(c.func) end
            end
        end
    end
end

-- Input Steuerung
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not lp.Character or not lp.Character:FindFirstChild("Precision Control") then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        manualMode = not manualMode 
    end
end)

--------------------------------------------------
-- GUI (Titel wieder da, Distance ab 0)
--------------------------------------------------
local gui = Instance.new("ScreenGui", lp.PlayerGui); gui.Name = "Tkns_xqrto_Aura"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.fromOffset(280, 450); main.Position = UDim2.new(0.02, 0, 0.3, 0); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.Active = true; main.Draggable = true
Instance.new("UICorner", main)

local titleFrame = Instance.new("Frame", main); titleFrame.Size = UDim2.new(1, 0, 0, 35); titleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); titleFrame.BorderSizePixel = 0
local titleLabel = Instance.new("TextLabel", titleFrame); titleLabel.Size = UDim2.new(1, 0, 1, 0); titleLabel.Text = "Tkns (xqrto) Settings"; titleLabel.TextColor3 = Color3.new(1,1,1); titleLabel.Font = "GothamBold"; titleLabel.TextSize = 14; titleLabel.BackgroundTransparency = 1
Instance.new("UICorner", titleFrame)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -20, 1, -55); scroll.Position = UDim2.fromOffset(10, 45); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 500); scroll.ScrollBarThickness = 3

local function createSlider(name, prop, min, max, yPos)
    local frame = Instance.new("Frame", scroll); frame.Size = UDim2.new(1, 0, 0, 45); frame.Position = UDim2.fromOffset(0, yPos); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, 0, 0, 20); label.Text = name .. ": " .. tostring(settings[prop]); label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.Font = "Gotham"; label.TextSize = 12; label.TextXAlignment = "Left"
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1, -10, 0, 6); bar.Position = UDim2.fromOffset(0, 25); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((settings[prop] - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = settings.color; fill.BorderSizePixel = 0
    local btn = Instance.new("TextButton", bar); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    
    btn.MouseButton1Down:Connect(function()
        local conn; conn = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() return end
            local relPos = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor((min + (max - min) * relPos) * 10) / 10
            settings[prop] = val
            label.Text = name .. ": " .. tostring(val)
            fill.Size = UDim2.new(relPos, 0, 1, 0)
            settings.color = Color3.fromRGB(settings.Red, settings.Green, settings.Blue)
        end)
    end)
end

createSlider("Red", "Red", 0, 255, 0)
createSlider("Green", "Green", 0, 255, 50)
createSlider("Blue", "Blue", 0, 255, 100)
createSlider("Orbit Speed", "orbitSpeed", 0, 100, 150)
createSlider("Wave Speed", "waveSpeed", 0, 100, 200)
createSlider("Distance", "distance", 0, 50, 250)
createSlider("Height", "height", -10, 30, 300)
createSlider("Glow Power", "glowStrength", 1, 50, 350)
createSlider("Transparency", "transparency", 0, 1, 400)

--------------------------------------------------
-- MAIN LOOP (HYPER RECALL & FE LOGIC)
--------------------------------------------------
local angle, waveTimer = 0, 0
_G.FlingConnection = RunService.Heartbeat:Connect(function(dt)
    local char = lp.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    giveTools()
    angle = angle + dt * settings.orbitSpeed; waveTimer = waveTimer + dt * settings.waveSpeed
    
    -- ADD ESP
    if char:FindFirstChild("add") then
        local partsInRegion = workspace:GetPartBoundsInRadius(hrp.Position, settings.maxSearchDist)
        for _, p in ipairs(partsInRegion) do
            if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(char) and not table.find(auraParts, p) then
                if not p:FindFirstChild("AuraESP") then
                    local h = Instance.new("Highlight", p); h.Name = "AuraESP"; h.FillTransparency = 0.5; h.OutlineColor = Color3.new(1,1,1); h.FillColor = settings.color
                    task.delay(0.1, function() if h then h:Destroy() end end)
                end
            end
        end
    end

    local controlActive = char:FindFirstChild("Precision Control")

    for i, part in ipairs(auraParts) do
        if not part or not part:IsDescendantOf(workspace) then table.remove(auraParts, i); continue end
        part.CanCollide = false
        part.Transparency = settings.transparency
        
        -- Visuals
        local f = part:FindFirstChild("AF") or Instance.new("Fire", part); f.Name = "AF"; f.Color = settings.color; f.Size = settings.glowStrength / 2
        local l = part:FindFirstChild("AL") or Instance.new("PointLight", part); l.Name = "AL"; l.Color = settings.color; l.Brightness = settings.glowStrength / 5

        local s = shotItems[part]

        if s then
            local distToPlayer = (hrp.Position - part.Position).Magnitude
            if s.returning then
                -- HYPER RECALL PHYSICS
                local direction = (hrp.Position - part.Position).Unit
                local speed = math.clamp(distToPlayer * 25, 500, MAX_RECALL_SPEED)
                part.AssemblyLinearVelocity = direction * speed
                
                -- Ankunft in Aura
                if distToPlayer < 8 then shotItems[part] = nil end
            else
                -- MAGNET SCHUSS
                local tP = (s.target:IsA("Model") and s.target:GetPivot().Position or s.target.Position)
                local distToTarget = (tP - part.Position).Magnitude
                part.AssemblyLinearVelocity = (tP - part.Position).Unit * MAGNET_FORCE
                
                -- Fling bei Treffer
                if distToTarget < 5 then 
                    part.AssemblyLinearVelocity = Vector3.new(0, 1000, 0) * FFE_POWER 
                    s.returning = true -- Sofort zurück nach Treffer
                end
            end
        elseif controlActive and manualMode then
            local mPos = mouse.Hit.Position
            part.CFrame = CFrame.new(mPos) 
            part.AssemblyLinearVelocity = hrp.Velocity * FFE_POWER 
        else
            -- NORMAL AURA
            local tPos = hrp.Position + Vector3.new(math.cos(angle) * settings.distance, settings.height + math.sin(waveTimer * 0.5) * 2, math.sin(angle) * settings.distance)
            if (part.Position - hrp.Position).Magnitude > 80 then
                part.AssemblyLinearVelocity = (hrp.Position - part.Position).Unit * 500
            else
                part.AssemblyLinearVelocity = (tPos - part.Position) * 35
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.F8 then main.Visible = not main.Visible end end)
