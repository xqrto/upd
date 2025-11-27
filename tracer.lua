--// ====== KOMPLETTES RAINBOW ESP SYSTEM ====== //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- SETTINGS
local tracersOn = true
local boxesOn = true
local teamCheck = true

local espData = {}

----------------------------------------------------------------------
-- GUI ERSTELLEN
----------------------------------------------------------------------

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

-- TRACER BUTTON
local TracerToggle = Instance.new("TextButton", Frame)
TracerToggle.Position = UDim2.new(0,10,0,50)
TracerToggle.Size = UDim2.new(0,200,0,30)
TracerToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
TracerToggle.Text = "Tracer: ON"
TracerToggle.TextColor3 = Color3.new(1,1,1)

TracerToggle.MouseButton1Click:Connect(function()
    tracersOn = not tracersOn
    TracerToggle.Text = "Tracer: " .. (tracersOn and "ON" or "OFF")
end)

-- BOX BUTTON
local BoxToggle = Instance.new("TextButton", Frame)
BoxToggle.Position = UDim2.new(0,10,0,90)
BoxToggle.Size = UDim2.new(0,200,0,30)
BoxToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
BoxToggle.Text = "Box ESP: ON"
BoxToggle.TextColor3 = Color3.new(1,1,1)

BoxToggle.MouseButton1Click:Connect(function()
    boxesOn = not boxesOn
    BoxToggle.Text = "Box ESP: " .. (boxesOn and "ON" or "OFF")
end)

-- TEAM FLAG BUTTON
local TeamToggle = Instance.new("TextButton", Frame)
TeamToggle.Position = UDim2.new(0,10,0,130)
TeamToggle.Size = UDim2.new(0,200,0,30)
TeamToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
TeamToggle.Text = "Team Flag: ON"
TeamToggle.TextColor3 = Color3.new(1,1,1)

TeamToggle.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    TeamToggle.Text = "Team Flag: " .. (teamCheck and "ON" or "OFF")
end)

-- GUI SCHLIESSEN
local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Position = UDim2.new(0,10,0,170)
CloseButton.Size = UDim2.new(0,200,0,30)
CloseButton.BackgroundColor3 = Color3.fromRGB(60,0,0)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Text = "GUI schließen"

-- KLEINER KREIS ZUM ÖFFNEN
local Reopen = Instance.new("TextButton", ScreenGui)
Reopen.Size = UDim2.new(0,30,0,30)
Reopen.Position = UDim2.new(0,10,0,250)
Reopen.BackgroundColor3 = Color3.fromRGB(100,100,255)
Reopen.BorderSizePixel = 0
Reopen.Text = ""
Reopen.Visible = false
Reopen.Draggable = true

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    Reopen.Visible = true
end)

Reopen.MouseButton1Click:Connect(function()
    Frame.Visible = true
    Reopen.Visible = false
end)

----------------------------------------------------------------------
-- ESP SYSTEM
----------------------------------------------------------------------

local function getRainbow()
    return Color3.fromHSV((tick() * 0.4) % 1, 1, 1)
end

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

----------------------------------------------------------------------
-- UPDATE LOOP
----------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    for plr,objects in pairs(espData) do
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        -- TEAMCHECK
        if teamCheck and plr.Team == LocalPlayer.Team then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        local pos, vis = camera:WorldToViewportPoint(root.Position)
        if not vis then
            objects.tracer.Visible = false
            objects.box.Visible = false
            continue
        end

        local rainbow = getRainbow()

        -- TRACER
        if tracersOn then
            objects.tracer.Visible = true
            objects.tracer.Color = rainbow

            local foot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if foot then
                local footpos = camera:WorldToViewportPoint(foot.Position)
                objects.tracer.From = Vector2.new(footpos.X, footpos.Y)
                objects.tracer.To = Vector2.new(pos.X, pos.Y)
            end
        else
            objects.tracer.Visible = false
        end

        -- BOX
        if boxesOn then
            objects.box.Visible = true
            objects.box.Color = rainbow
            objects.box.Size = Vector2.new(50,70)
            objects.box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
        else
            objects.box.Visible = false
        end
    end
end)
