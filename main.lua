-- X-HUB ULTIMATE: ORGANIZED EDITION
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")  

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FILE_NAME = "XHub_Config_V5.json"

-- --- DEINE NEUE SORTIERTE LISTE ---
local mods = {
    -- >> COMBAT TAB
    {"Combat", "AimBot", "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
    {"Combat", "AimBot (Old)", "https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
    {"Combat", "Gun Mods", "https://raw.githubusercontent.com/xqrto/upd/main/gunm.lua"},

    -- >> MOVEMENT TAB
    {"Movement", "NoClip", "https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
    {"Movement", "Fly", "https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
    {"Movement", "Vehicle Fly", "https://raw.githubusercontent.com/xqrto/upd/main/vehicle.lua"},
    {"Movement", "Speed Mirage", "https://raw.githubusercontent.com/xqrto/upd/main/speedmirage.lua"},

    -- >> VISUALS TAB
    {"Visuals", "ESP", "https://raw.githubusercontent.com/xqrto/upd/main/chams.lua"},
    {"Visuals", "Name ESP", "https://raw.githubusercontent.com/xqrto/upd/main/nameESP.lua"},
    {"Visuals", "Tracer", "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
    {"Visuals", "FreeCam", "https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},

    -- >> BROOKHAVEN TAB (Alles zusammen hier)
    {"Brookhaven", "Brookhaven XR", "https://raw.githubusercontent.com/xqrto/upd/main/brook.lua"},
    {"Brookhaven", "XR Safety", "https://raw.githubusercontent.com/xqrto/upd/main/xrsafe.lua"},
    {"Brookhaven", "Soccer Fling", "https://raw.githubusercontent.com/xqrto/upd/main/soccer.lua"},

    -- >> ITEMS TAB
    {"Items", "Telekinesis", "https://raw.githubusercontent.com/xqrto/upd/main/telikinesis.lua"},
    {"Items", "TP Tool", "https://raw.githubusercontent.com/xqrto/upd/main/tp.lua"},

    -- >> TROLL & FUN TAB
    {"Troll & Fun", "Fling", "https://raw.githubusercontent.com/xqrto/upd/main/fling.lua"},
    {"Troll & Fun", "2D Mode", "https://raw.githubusercontent.com/xqrto/upd/main/2d.lua"},
    {"Troll & Fun", "Reverse", "https://raw.githubusercontent.com/xqrto/upd/main/reverse.lua"},
}

-- --- THEME DEFAULT ---
local CurrentTheme = {
    Bg = Color3.fromRGB(25, 25, 30),
    Btn = Color3.fromRGB(45, 45, 50),
    Txt = Color3.fromRGB(255, 255, 255),
    Trans = 0.1
}

local Styles = {
    Midnight = {Bg = Color3.fromRGB(15, 15, 20), Btn = Color3.fromRGB(35, 35, 40), Txt = Color3.fromRGB(255,255,255), Trans = 0},
    Glass = {Bg = Color3.fromRGB(10, 10, 10), Btn = Color3.fromRGB(70, 70, 70), Txt = Color3.fromRGB(255,255,255), Trans = 0.5},
    Ocean = {Bg = Color3.fromRGB(5, 20, 40), Btn = Color3.fromRGB(20, 50, 80), Txt = Color3.fromRGB(200, 240, 255), Trans = 0.1}
}

-- --- GUI SETUP ---
if PlayerGui:FindFirstChild("XHub_Organized") then PlayerGui.XHub_Organized:Destroy() end
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "XHub_Organized"
sg.ResetOnSpawn = false

-- --- ICON ---
local icon = Instance.new("TextButton", sg)
icon.Size = UDim2.new(0, 60, 0, 60)
icon.Position = UDim2.new(0.05, 0, 0.2, 0)
icon.BackgroundColor3 = Color3.new(1,1,1)
icon.Text = "X"
icon.Font = "FredokaOne"
icon.TextSize = 36
icon.TextColor3 = Color3.new(1,1,1)
icon.ZIndex = 10
icon.AutoButtonColor = false
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

local ig = Instance.new("UIGradient", icon)
ig.Color = ColorSequence.new(Color3.fromRGB(120, 100, 255), Color3.fromRGB(255, 100, 150))

local shadow = Instance.new("ImageLabel", icon)
shadow.Size = UDim2.new(1, 30, 1, 30); shadow.Position = UDim2.new(0.5,0,0.5,0); shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.BackgroundTransparency = 1; shadow.Image = "rbxassetid://1316045217"; shadow.ImageColor3 = Color3.new(0,0,0); shadow.ImageTransparency = 0.6; shadow.ZIndex = 9

-- --- MAIN FRAME ---
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,0,0,0); main.Position = UDim2.new(0.5,0,0.5,0); main.AnchorPoint = Vector2.new(0.5,0.5)
main.ClipsDescendants = true; main.Visible = false
Instance.new("UICorner", main)

local sidebar = Instance.new("ScrollingFrame", main)
sidebar.Size = UDim2.new(0, 130, 1, -20); sidebar.Position = UDim2.new(0, 5, 0, 10); sidebar.BackgroundTransparency = 1
sidebar.ScrollBarThickness = 2; sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; sidebar.CanvasSize = UDim2.new(0,0,0,0)
local sideLayout = Instance.new("UIListLayout", sidebar); sideLayout.Padding = UDim.new(0, 5); sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -150, 1, -20); container.Position = UDim2.new(0, 140, 0, 10); container.BackgroundTransparency = 1

local allElements = {}

-- --- FUNCTIONS ---
local function updateUI()
    main.BackgroundColor3 = CurrentTheme.Bg
    main.BackgroundTransparency = CurrentTheme.Trans
    for _, el in pairs(allElements) do
        if el:IsA("TextButton") or el:IsA("TextBox") then
            el.BackgroundColor3 = CurrentTheme.Btn
            el.TextColor3 = CurrentTheme.Txt
        end
    end
end

local function createTab(name, order)
    local f = Instance.new("ScrollingFrame", container)
    f.Name = name; f.Size = UDim2.new(1, 0, 1, 0); f.Visible = false; f.BackgroundTransparency = 1; f.ScrollBarThickness = 3; f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local l = Instance.new("UIListLayout", f); l.Padding = UDim.new(0, 6); l.SortOrder = Enum.SortOrder.LayoutOrder

    local b = Instance.new("TextButton", sidebar)
    b.Name = name.."_Btn"; b.Size = UDim2.new(1, -10, 0, 35); b.Text = name; b.Font = "GothamBold"; b.TextSize = 13; b.LayoutOrder = order or 999
    Instance.new("UICorner", b)
    table.insert(allElements, b)

    b.MouseButton1Click:Connect(function()
        for _, x in pairs(container:GetChildren()) do x.Visible = false end
        f.Visible = true
    end)
    return f
end

local function addScriptBtn(parentFrame, name, url)
    local b = Instance.new("TextButton", parentFrame)
    b.Size = UDim2.new(1, -5, 0, 35); b.Text = name; b.Font = "Gotham"; b.TextSize = 14
    Instance.new("UICorner", b)
    table.insert(allElements, b)
    b.MouseButton1Click:Connect(function()
        local s, err = pcall(function() loadstring(game:HttpGet(url))() end)
        if not s then b.Text = "Error!"; wait(1); b.Text = name end
    end)
end

-- --- 1. EXECUTOR ---
local tabExec = createTab("Executor", 1)
local box = Instance.new("TextBox", tabExec)
box.Size = UDim2.new(1,-5,0,150); box.MultiLine = true; box.Text = "-- Script Here"; box.Font = "Code"; box.TextSize = 12
box.ClearTextOnFocus = false; box.TextXAlignment = "Left"; box.TextYAlignment = "Top"; Instance.new("UICorner", box)
table.insert(allElements, box)
local exBtn = Instance.new("TextButton", tabExec); exBtn.Size = UDim2.new(1,-5,0,35); exBtn.Text = "Execute"; Instance.new("UICorner", exBtn)
table.insert(allElements, exBtn); exBtn.MouseButton1Click:Connect(function() pcall(function() loadstring(box.Text)() end) end)

-- --- 2. AUTO-TABS ---
local createdTabs = {}
for _, entry in pairs(mods) do
    local tabName, scriptName, scriptUrl = entry[1], entry[2], entry[3]
    if not createdTabs[tabName] then
        -- Brookhaven bekommt Priorität (Order 10), andere Order 50
        local order = (tabName == "Brookhaven") and 10 or 50
        createdTabs[tabName] = createTab(tabName, order)
    end
    addScriptBtn(createdTabs[tabName], scriptName, scriptUrl)
end

-- --- 3. SETTINGS ---
local tabSet = createTab("Settings", 1000)
for n, s in pairs(Styles) do
    local b = Instance.new("TextButton", tabSet); b.Size = UDim2.new(1,-5,0,35); b.Text = "Theme: "..n; Instance.new("UICorner", b)
    table.insert(allElements, b)
    b.MouseButton1Click:Connect(function()
        CurrentTheme = {Bg=s.Bg, Btn=s.Btn, Txt=s.Txt, Trans=s.Trans}
        updateUI()
    end)
end
local saveB = Instance.new("TextButton", tabSet); saveB.Size = UDim2.new(1,-5,0,35); saveB.Text = "SAVE CONFIG"; Instance.new("UICorner", saveB)
table.insert(allElements, saveB)
saveB.MouseButton1Click:Connect(function()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode({bgR=CurrentTheme.Bg.R, bgG=CurrentTheme.Bg.G, bgB=CurrentTheme.Bg.B, btnR=CurrentTheme.Btn.R, btnG=CurrentTheme.Btn.G, btnB=CurrentTheme.Btn.B, txtR=CurrentTheme.Txt.R, txtG=CurrentTheme.Txt.G, txtB=CurrentTheme.Txt.B, trans=CurrentTheme.Trans}))
        saveB.Text = "SAVED!"; wait(1); saveB.Text = "SAVE CONFIG"
    end
end)

-- --- LOGIC ---
local open = false; local isDragging = false
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true; local dragStart = input.Position; local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false; connection:Disconnect()
                if (input.Position - dragStart).Magnitude < 5 then
                    open = not open
                    TweenService:Create(icon, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Rotation = open and 45 or 0}):Play()
                    if open then main.Visible = true; main:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Back", 0.4)
                    else main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true, function() main.Visible = false end) end
                end
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local m = UserInputService:GetMouseLocation()
        icon.Position = UDim2.new(0, m.X - 30, 0, m.Y - 66)
    end
end)

if isfile and isfile(FILE_NAME) then
    local s, d = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
    if s and d then CurrentTheme.Bg = Color3.new(d.bgR, d.bgG, d.bgB); CurrentTheme.Btn = Color3.new(d.btnR, d.btnG, d.btnB); CurrentTheme.Txt = Color3.new(d.txtR, d.txtG, d.txtB); CurrentTheme.Trans = d.trans or 0.1 end
end
updateUI(); tabExec.Visible = true
