--[[
Complete Script Hub + Owner Display
LocalScript in StarterPlayerScripts
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
    local r = math.sin(t) * 0.5 + 0.5
    local g = math.sin(t + 2) * 0.5 + 0.5
    local b = math.sin(t + 4) * 0.5 + 0.5
    return Color3.new(r,g,b)
end

-----------------------------
-- Owner Label erstellen
-----------------------------
local function createOwnerLabel(character)
    local head = character:FindFirstChild("Head")
    if not head then return end

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
    text.Text = "OWNER"
    text.Font = Enum.Font.GothamBold
    text.TextSize = 20
    text.TextColor3 = Color3.new(1,0,0)
    text.Parent = bill

    RunService.RenderStepped:Connect(function()
        if text.Parent then
            text.TextColor3 = getRainbowColor()
        end
    end)
end

local function onPlayerAdded(player)
    if ownerNames[player.Name] then
        if player.Character then
            createOwnerLabel(player.Character)
        end
        player.CharacterAdded:Connect(function(char)
            createOwnerLabel(char)
        end)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end
Players.PlayerAdded:Connect(onPlayerAdded)

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

    -- Hover Effekt
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70,70,80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
    end)

    btn.MouseButton1Click:Connect(callback)
end

-- Skripte Buttons
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
