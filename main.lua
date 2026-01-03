-- X-HUB ULTIMATE: MEGA UPDATE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FILE_NAME = "XHub_Settings_V4.json"

-- --- THEME ENGINE ---
local CurrentTheme = {
    Bg = Color3.fromRGB(25, 25, 30),
    Btn = Color3.fromRGB(45, 45, 50),
    Txt = Color3.fromRGB(255, 255, 255),
    Trans = 0.1
}

local Styles = {
    Midnight = {Bg = Color3.fromRGB(15, 15, 20), Btn = Color3.fromRGB(35, 35, 40), Txt = Color3.fromRGB(255,255,255), Trans = 0},
    Glass = {Bg = Color3.fromRGB(10, 10, 10), Btn = Color3.fromRGB(70, 70, 70), Txt = Color3.fromRGB(255,255,255), Trans = 0.5},
    Kontrast = {Bg = Color3.fromRGB(0, 0, 0), Btn = Color3.fromRGB(255, 255, 255), Txt = Color3.fromRGB(0, 0, 0), Trans = 0},
    Ocean = {Bg = Color3.fromRGB(5, 20, 40), Btn = Color3.fromRGB(20, 50, 80), Txt = Color3.fromRGB(200, 240, 255), Trans = 0.1}
}

-- --- DATA ---
local ModButtons = {
    {name="AimBot", url="https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
    {name="AimBot-old", url="https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
    {name="Gun-Mods", url="https://raw.githubusercontent.com/xqrto/upd/main/gunm.lua"},
    {name="NoClip", url="https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
    {name="FreeCam", url="https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
    {name="Fly", url="https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
    {name="V-Fly", url="https://raw.githubusercontent.com/xqrto/upd/main/vehicle.lua"},
    {name="Tracer", url="https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
    {name="ESP", url="https://raw.githubusercontent.com/xqrto/upd/main/chams.lua"},
    {name="Name-ESP", url="https://raw.githubusercontent.com/xqrto/upd/main/nameESP.lua"},
}

local ItemButtons = {
    {name="Telikinesis", url="https://raw.githubusercontent.com/xqrto/upd/main/telikinesis.lua"},
    {name="Tp Tool", url="https://raw.githubusercontent.com/xqrto/upd/main/tp.lua"}
}

local ExtrasButtons = {
    {name="Fling", url="https://raw.githubusercontent.com/xqrto/upd/main/fling.lua"},
    {name="2D Mode", url="https://raw.githubusercontent.com/xqrto/upd/main/2d.lua"},
    {name="Reverse", url="https://raw.githubusercontent.com/xqrto/upd/main/reverse.lua"},
    {name="SpeedMirage", url="https://raw.githubusercontent.com/xqrto/upd/main/speedmirage.lua"},
    {name="Brookhaven-Xr", url="https://raw.githubusercontent.com/xqrto/upd/main/brook.lua"},
    {name="Brookhaven-Xr-Safety", url="https://raw.githubusercontent.com/xqrto/upd/main/xrsafe.lua"},
    {name="Brookhaven-Xr-Fling", url="https://raw.githubusercontent.com/xqrto/upd/main/soccer.lua"},
}

-- --- GUI ---
local sg = Instance.new("ScreenGui", PlayerGui)
sg.Name = "XHub_V4_Final"
sg.ResetOnSpawn = false

-- ICON
local icon = Instance.new("TextButton", sg)
icon.Size = UDim2.new(0, 58, 0, 58)
icon.Position = UDim2.new(0.05, 0, 0.2, 0)
icon.BackgroundColor3 = Color3.new(1,1,1)
icon.Text = "X"; icon.Font = "FredokaOne"; icon.TextSize = 30; icon.TextColor3 = Color3.new(1,1,1); icon.ZIndex = 10
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
local ig = Instance.new("UIGradient", icon)
ig.Color = ColorSequence.new(Color3.fromRGB(120, 100, 255), Color3.fromRGB(255, 100, 150))

local shadow = Instance.new("ImageLabel", icon)
shadow.Size = UDim2.new(1, 25, 1, 25); shadow.Position = UDim2.new(0.5,0,0.5,0); shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.BackgroundTransparency = 1; shadow.Image = "rbxassetid://1316045217"; shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.5; shadow.ZIndex = 9; Instance.new("UICorner", shadow).CornerRadius = UDim.new(1,0)

-- MAIN
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,0,0,0); main.Position = UDim2.new(0.5,0,0.5,0); main.AnchorPoint = Vector2.new(0.5,0.5)
main.ClipsDescendants = true; main.Visible = false; Instance.new("UICorner", main)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, 0); sidebar.BackgroundTransparency = 0.9; sidebar.BackgroundColor3 = Color3.new(0,0,0)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -140, 1, -20); container.Position = UDim2.new(0, 135, 0, 10); container.BackgroundTransparency = 1

local btnList = {}
local function updateUI()
    main.BackgroundColor3 = CurrentTheme.Bg
    main.BackgroundTransparency = CurrentTheme.Trans
    for _, b in pairs(btnList) do
        b.BackgroundColor3 = CurrentTheme.Btn
        b.TextColor3 = CurrentTheme.Txt
    end
end

local function createTab(name)
    local f = Instance.new("ScrollingFrame", container)
    f.Size = UDim2.new(1, 0, 1, 0); f.Visible = false; f.BackgroundTransparency = 1; f.ScrollBarThickness = 2
    local l = Instance.new("UIListLayout", f); l.Padding = UDim.new(0, 6)
    
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1, -10, 0, 35); b.Position = UDim2.new(0, 5, 0, (#sidebar:GetChildren()-1)*40 + 10)
    b.Text = name; b.Font = "GothamBold"; b.TextSize = 14; Instance.new("UICorner", b)
    table.insert(btnList, b)
    b.MouseButton1Click:Connect(function()
        for _, x in pairs(container:GetChildren()) do x.Visible = false end
        f.Visible = true
    end)
    return f
end

local function addScriptBtn(parent, data)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -5, 0, 35); b.Text = data.name; b.Font = "Gotham"; b.TextSize = 14; Instance.new("UICorner", b)
    table.insert(btnList, b)
    b.MouseButton1Click:Connect(function()
        local s, err = pcall(function() loadstring(game:HttpGet(data.url))() end)
        if not s then StarterGui:SetCore("SendNotification", {Title="Error", Text=data.name.." failed"}) end
    end)
end

-- --- BUILD TABS ---
local tabExec = createTab("Executor")
local tabMods = createTab("Mods")
local tabItems = createTab("Items")
local tabExtras = createTab("Extras")
local tabSet = createTab("Settings")

-- Executor
local box = Instance.new("TextBox", tabExec)
box.Size = UDim2.new(1,-5,0,140); box.MultiLine = true; box.Text = "-- Code here"; box.BackgroundColor3 = Color3.new(0,0,0); box.TextColor3 = Color3.new(1,1,1); box.Font = "Code"; box.ClearTextOnFocus = false; box.TextXAlignment = "Left"; box.TextYAlignment = "Top"
local exBtn = Instance.new("TextButton", tabExec); exBtn.Size = UDim2.new(1,-5,0,35); exBtn.Text = "Execute"; table.insert(btnList, exBtn); exBtn.MouseButton1Click:Connect(function() loadstring(box.Text)() end)

-- Populate Script Tabs
for _, d in pairs(ModButtons) do addScriptBtn(tabMods, d) end
for _, d in pairs(ItemButtons) do addScriptBtn(tabItems, d) end
for _, d in pairs(ExtrasButtons) do addScriptBtn(tabExtras, d) end

-- Settings
for n, s in pairs(Styles) do
    local b = Instance.new("TextButton", tabSet); b.Size = UDim2.new(1,-5,0,35); b.Text = "Style: "..n; table.insert(btnList, b)
    b.MouseButton1Click:Connect(function()
        CurrentTheme.Bg = s.Bg; CurrentTheme.Btn = s.Btn; CurrentTheme.Txt = s.Txt; CurrentTheme.Trans = s.Trans
        updateUI()
    end)
end
local saveB = Instance.new("TextButton", tabSet); saveB.Size = UDim2.new(1,-5,0,35); saveB.Text = "SAVE SETTINGS"; table.insert(btnList, saveB)
saveB.MouseButton1Click:Connect(function() if writefile then writefile(FILE_NAME, HttpService:JSONEncode({r=CurrentTheme.Bg.R, g=CurrentTheme.Bg.G, b=CurrentTheme.Bg.B, t=CurrentTheme.Trans})) end end)
local destB = Instance.new("TextButton", tabSet); destB.Size = UDim2.new(1,-5,0,35); destB.Text = "DESTROY GUI"; destB.BackgroundColor3 = Color3.new(0.6,0,0); destB.TextColor3 = Color3.new(1,1,1); destB.MouseButton1Click:Connect(function() sg:Destroy() end)

-- --- DRAG & TOGGLE ---
local drag, dStart, sPos; local lastC = 0; local open = false
icon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = icon.Position
        if tick() - lastC < 0.35 then
            drag = false; open = not open
            if open then main.Visible = true; main:TweenSize(UDim2.new(0,540,0,360), "Out", "Back", 0.4)
            else main:TweenSize(UDim2.new(0,0,0,0), "In", "Quad", 0.3, true, function() main.Visible = false end) end
        end
        lastC = tick()
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dStart
        icon.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

-- Init
tabMods.Visible = true; updateUI()
if isfile and isfile(FILE_NAME) then
    local d = HttpService:JSONDecode(readfile(FILE_NAME))
    CurrentTheme.Bg = Color3.new(d.r, d.g, d.b); CurrentTheme.Trans = d.t or 0.1; updateUI()
end
