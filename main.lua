--[[
Complete Script Hub + Owner Display + Rainbow Aura
LocalScript in StarterPlayerScripts
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = workspace

-----------------------------
-- Skriptliste
-----------------------------
local scripts = {
    {name = "AimBot", url = "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
    {name = "Tracer", url = "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
}

-----------------------------
-- Owner-Liste
-----------------------------
local ownerNames = {
    ["f7007l"] = true,
    ["Ipnuuball1"] = true
}

-----------------------------
-- Rainbow-Funktion
-----------------------------
local function getRainbowColor()
    local t = tick() * 2
    return Color3.fromHSV(t % 1,1,1)
end

-----------------------------
-- Owner Label + Sichtlinienprüfung
-----------------------------
local function createOwnerLabelAndAura(character)
    local head = character:WaitForChild("Head")

    -- Label
    if not head:FindFirstChild("OwnerLabel") then
        local bill = Instance.new("BillboardGui")
        bill.Name = "OwnerLabel"
        bill.Adornee = head
        bill.Size = UDim2.new(0,120,0,40)
        bill.StudsOffset = Vector3.new(0,2.5,0)
        bill.AlwaysOnTop = true
        bill.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = "XQRTO"
        text.Font = Enum.Font.GothamBold
        text.TextSize = 20
        text.TextColor3 = getRainbowColor()
        text.Parent = bill

        -- Rainbow-Aura nur sichtbar für Dritte
        local aura = Instance.new("Part")
        aura.Name = "RainbowAura"
        aura.Anchored = false
        aura.CanCollide = false
        aura.Size = Vector3.new(4,5,4)
        aura.Transparency = 0.7
        aura.Material = Enum.Material.Neon
        aura.Color = getRainbowColor()
        aura.CFrame = character.PrimaryPart and character.PrimaryPart.CFrame or head.CFrame
        aura.Parent = Workspace

        local attachments = {}
        for i = 1,8 do
            local attach = Instance.new("Attachment")
            attach.Position = Vector3.new(math.random()-0.5, math.random(), math.random()-0.5)*2
            attach.Parent = aura
            table.insert(attachments, attach)
        end
        local emitter = Instance.new("ParticleEmitter")
        emitter.Rate = 50
        emitter.Lifetime = NumberRange.new(0.5,1)
        emitter.Speed = NumberRange.new(0.5,1)
        emitter.Size = NumberSequence.new(0.5,1)
        emitter.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255))
        emitter.LightEmission = 0.8
        emitter.Rotation = NumberRange.new(0,360)
        emitter.RotSpeed = NumberRange.new(-180,180)
        emitter.Parent = aura

        -- Update RenderStepped
        RunService.RenderStepped:Connect(function()
            -- Sichtlinienprüfung für Label und Aura
            local origin = Camera.CFrame.Position
            local dir = head.Position - origin
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local ray = Workspace:Raycast(origin, dir, params)

            local visible = true
            if ray and not ray.Instance:IsDescendantOf(character) then
                visible = false
            end

            bill.Enabled = visible

            -- Aura nur aus 3rd-Person sichtbar
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local camToPlayer = (Camera.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local isFirstPerson = camToPlayer < 2
                aura.Transparency = isFirstPerson and 1 or 0.7
            end

            -- Regenbogenfarben
            text.TextColor3 = getRainbowColor()
            aura.Color = getRainbowColor()

            -- Aura Position aktualisieren
            aura.CFrame = (character.PrimaryPart or head).CFrame
        end)
    end
end

local function checkPlayer(player)
    if ownerNames[player.Name] then
        if player.Character then
            createOwnerLabelAndAura(player.Character)
        end
        player.CharacterAdded:Connect(function(char)
            createOwnerLabelAndAura(char)
        end)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    checkPlayer(p)
end
Players.PlayerAdded:Connect(checkPlayer)

-----------------------------
-- GUI erstellen
-----------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XQRTO_ScriptHub"
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,450,0,350)
frame.Position = UDim2.new(0.25,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true

-- Titel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "XQRTO Script Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Parent = frame

-- ScrollFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,1,-60)
scrollFrame.Position = UDim2.new(0,10,0,50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,8)
layout.Parent = scrollFrame

-- Button erstellen Funktion
local function createButton(parent,text,callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    btn.AutoButtonColor = true
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 20
    btn.Text = text
    btn.Parent = parent

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    end)

    btn.MouseButton1Click:Connect(callback)
end

-- Skript laden Funktion
local function loadScript(url)
    local success, response = pcall(function() return game:HttpGet(url) end)
    if success and response then
        local funcSuccess, funcErr = pcall(function()
            loadstring(response)()
        end)
        if not funcSuccess then
            warn("Fehler beim Ausführen:", funcErr)
        end
    else
        warn("Fehler beim Laden:", url)
    end
end

-- Skript Buttons
for _,s in ipairs(scripts) do
    createButton(scrollFrame,s.name,function()
        screenGui:Destroy()
        loadScript(s.url)
    end)
end

-- Dynamische CanvasSize
scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)
