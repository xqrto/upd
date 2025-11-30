local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Skripte
local scripts = {
    {name = "AimBot", url = "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
    {name = "AimBot-old", url = "https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
    {name = "NoClip", url = "https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
    {name = "FreeCam", url = "https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
    {name = "Fly", url = "https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
    {name = "Tracer", url = "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
}

local ownerNames = {
    ["f7007l"]=true,
    ["Ipnuuball1"]=true
}

local function getRainbowColor()
    return Color3.fromHSV(tick()%1,1,1)
end

local function createOwnerEffects(character)
    local head = character:WaitForChild("Head")

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

        RunService.RenderStepped:Connect(function()
            text.TextColor3 = getRainbowColor()
        end)
    end
end

local function checkPlayer(player)
    if ownerNames[player.Name] then
        if player.Character then
            createOwnerEffects(player.Character)
        end
        player.CharacterAdded:Connect(createOwnerEffects)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    checkPlayer(p)
end
Players.PlayerAdded:Connect(checkPlayer)

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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "XQRTO Script Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Parent = frame

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

local function loadScript(url)
    local success, response = pcall(function() 
        return game:HttpGet(url) 
    end)

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

scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)
