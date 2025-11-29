-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Settings
local tracersOn = true
local boxesOn = true
local teamCheck = true
local espData = {}

-- GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "RainbowESP_GUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 220)
Frame.Position = UDim2.new(0, 20, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Text = "Rainbow ESP"
Title.TextColor3 = Color3.new(1,1,1)

-- Buttons
local function createButton(parent, y, text)
    local btn = Instance.new("TextButton", parent)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Size = UDim2.new(0,200,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    return btn
end

local TracerToggle = createButton(Frame,50,"Tracer: ON")
local BoxToggle = createButton(Frame,90,"Box ESP: ON")
local TeamToggle = createButton(Frame,130,"Team Flag: ON")
local CloseButton = createButton(Frame,170,"GUI schließen")
CloseButton.BackgroundColor3 = Color3.fromRGB(60,0,0)

local Reopen = Instance.new("TextButton", ScreenGui)
Reopen.Size = UDim2.new(0,30,0,30)
Reopen.Position = UDim2.new(0,10,0,250)
Reopen.BackgroundColor3 = Color3.fromRGB(100,100,255)
Reopen.BorderSizePixel = 0
Reopen.Text = ""
Reopen.Visible = false
Reopen.Draggable = true

-- Button functionality
TracerToggle.MouseButton1Click:Connect(function()
    tracersOn = not tracersOn
    TracerToggle.Text = "Tracer: " .. (tracersOn and "ON" or "OFF")
end)

BoxToggle.MouseButton1Click:Connect(function()
    boxesOn = not boxesOn
    BoxToggle.Text = "Box ESP: " .. (boxesOn and "ON" or "OFF")
end)

TeamToggle.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    TeamToggle.Text = "Team Flag: " .. (teamCheck and "ON" or "OFF")
end)

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    Reopen.Visible = true
end)

Reopen.MouseButton1Click:Connect(function()
    Frame.Visible = true
    Reopen.Visible = false
end)

-- Rainbow loop (less CPU usage)
local rainbowColor = Color3.new(1,1,1)
spawn(function()
    while true do
        rainbowColor = Color3.fromHSV((tick() * 0.4) % 1, 1, 1)
        wait(0.1)
    end
end)

-- ESP creation/removal
local function createESP(plr)
    if plr == LocalPlayer or espData[plr] then return end

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 2

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 2
    box.Filled = false

    espData[plr] = {
        tracer = tracer,
        box = box
    }
end

local function removeESP(plr)
    if espData[plr] then
        espData[plr].tracer:Remove()
        espData[plr].box:Remove()
        espData[plr] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

for _,p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

-- Optimized ESP update
RunService.RenderStepped:Connect(function()
    local cameraPos = Camera.CFrame.Position
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local localScreenPos, _ = Camera:WorldToViewportPoint(localRoot.Position)

    for plr,objects in pairs(espData) do
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not root then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        -- Team check
        if teamCheck and plr.Team == LocalPlayer.Team then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        -- Distance cull (optional, improves performance)
        if (root.Position - cameraPos).Magnitude > 300 then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        -- Update Tracer
        objects.tracer.Visible = tracersOn
        if tracersOn then
            objects.tracer.Color = rainbowColor
            objects.tracer.From = Vector2.new(localScreenPos.X, localScreenPos.Y)
            objects.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        end

        -- Update Box
        objects.box.Visible = boxesOn
        if boxesOn then
            objects.box.Color = rainbowColor
            objects.box.Size = Vector2.new(50,70)
            objects.box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 50)
        end
    end
end)
