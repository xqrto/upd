local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------------
-------------------- SETTINGS & VARS --------------------
---------------------------------------------------------

local keybinds = {
    ToggleFreecam = Enum.KeyCode.F4,
    OpenMenu = Enum.KeyCode.F8,
    TeleportChar = Enum.KeyCode.F5,
    Forward = Enum.KeyCode.W,
    Backward = Enum.KeyCode.S,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.E,
    Down = Enum.KeyCode.Q
}

local freecamSpeed = 1.6
local mouseSensitivity = 0.15
local freecamActive = false
local menuMode = false
local rotation = Vector2.new()
local frozenHRP = nil

---------------------------------------------------------
-------------------- GUI SETUP --------------------------
---------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Freecam_Final_System"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Tab Navigation
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 35)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local btnTab1 = Instance.new("TextButton")
btnTab1.Size = UDim2.new(0.5, 0, 1, 0)
btnTab1.Text = "PLAYERS"
btnTab1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnTab1.TextColor3 = Color3.new(1, 1, 1)
btnTab1.Parent = tabFrame

local btnTab2 = Instance.new("TextButton")
btnTab2.Size = UDim2.new(0.5, 0, 1, 0)
btnTab2.Position = UDim2.new(0.5, 0, 0, 0)
btnTab2.Text = "SETTINGS"
btnTab2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnTab2.TextColor3 = Color3.new(0.7, 0.7, 0.7)
btnTab2.Parent = tabFrame

-- Pages
local pagePlayers = Instance.new("ScrollingFrame")
pagePlayers.Size = UDim2.new(1, -20, 1, -50)
pagePlayers.Position = UDim2.new(0, 10, 0, 40)
pagePlayers.BackgroundTransparency = 1
pagePlayers.Visible = true
pagePlayers.ScrollBarThickness = 2
pagePlayers.Parent = mainFrame

local pageSettings = Instance.new("Frame")
pageSettings.Size = UDim2.new(1, -20, 1, -50)
pageSettings.Position = UDim2.new(0, 10, 0, 40)
pageSettings.BackgroundTransparency = 1
pageSettings.Visible = false
pageSettings.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = pagePlayers

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding = UDim.new(0, 8)
settingsLayout.Parent = pageSettings

---------------------------------------------------------
-------------------- CORE FUNCTIONS ---------------------
---------------------------------------------------------

local function toggleFreecam(state)
    freecamActive = state
    menuMode = false
    if state then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            frozenHRP = char.HumanoidRootPart
            frozenHRP.Anchored = true
        end
        Camera.CameraType = Enum.CameraType.Scriptable
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = false
    else
        if frozenHRP then frozenHRP.Anchored = false end
        Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end
end

local function teleportBody()
    if not freecamActive then return end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = Camera.CFrame
        toggleFreecam(false) -- Beendet Freecam automatisch nach TP
    end
end

---------------------------------------------------------
-------------------- SETTINGS (TAB 2) -------------------
---------------------------------------------------------

-- Speed Control UI
local speedControlFrame = Instance.new("Frame")
speedControlFrame.Size = UDim2.new(1, 0, 0, 40)
speedControlFrame.BackgroundTransparency = 1
speedControlFrame.Parent = pageSettings

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 1, 0)
speedLabel.Text = "Speed: " .. string.format("%.1f", freecamSpeed)
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = speedControlFrame

local sMinus = Instance.new("TextButton")
sMinus.Size = UDim2.new(0, 35, 0, 30)
sMinus.Position = UDim2.new(0.5, 0, 0.1, 0)
sMinus.Text = "-"
sMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sMinus.TextColor3 = Color3.new(1,1,1)
sMinus.Parent = speedControlFrame

local sPlus = Instance.new("TextButton")
sPlus.Size = UDim2.new(0, 35, 0, 30)
sPlus.Position = UDim2.new(0.7, 5, 0.1, 0)
sPlus.Text = "+"
sPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sPlus.TextColor3 = Color3.new(1,1,1)
sPlus.Parent = speedControlFrame

sPlus.MouseButton1Click:Connect(function()
    freecamSpeed = math.min(freecamSpeed + 0.2, 15)
    speedLabel.Text = "Speed: " .. string.format("%.1f", freecamSpeed)
end)

sMinus.MouseButton1Click:Connect(function()
    freecamSpeed = math.max(freecamSpeed - 0.2, 0.2)
    speedLabel.Text = "Speed: " .. string.format("%.1f", freecamSpeed)
end)

-- Keybind Buttons
local function createBindButton(name, keyIndex)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name .. ": " .. keybinds[keyIndex].Name
    btn.Parent = pageSettings
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        btn.Text = "Wait for Key..."
        local conn
        conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keybinds[keyIndex] = input.KeyCode
                btn.Text = name .. ": " .. input.KeyCode.Name
                conn:Disconnect()
            end
        end)
    end)
end

createBindButton("Toggle Cam", "ToggleFreecam")
createBindButton("Mouse Unlock", "OpenMenu")
createBindButton("TP Character", "TeleportChar")

---------------------------------------------------------
-------------------- PLAYER LIST (TAB 1) ----------------
---------------------------------------------------------

local function updatePlayerList()
    for _, c in pairs(pagePlayers:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(1, 0, 0, 30)
        pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pBtn.Text = p.DisplayName
        pBtn.TextColor3 = Color3.new(1, 1, 1)
        pBtn.Parent = pagePlayers
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

        pBtn.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 10)
            end
        end)
    end
    pagePlayers.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

---------------------------------------------------------
-------------------- NAVIGATION & INPUT -----------------
---------------------------------------------------------

btnTab1.MouseButton1Click:Connect(function()
    pagePlayers.Visible, pageSettings.Visible = true, false
    btnTab1.BackgroundColor3, btnTab2.BackgroundColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(30,30,30)
end)

btnTab2.MouseButton1Click:Connect(function()
    pagePlayers.Visible, pageSettings.Visible = false, true
    btnTab1.BackgroundColor3, btnTab2.BackgroundColor3 = Color3.fromRGB(30,30,30), Color3.fromRGB(40,40,40)
end)

RunService.RenderStepped:Connect(function()
    if freecamActive and not menuMode then
        local delta = UIS:GetMouseDelta()
        rotation = rotation + Vector2.new(-delta.Y, -delta.X) * mouseSensitivity
        local rotCF = CFrame.Angles(0, math.rad(rotation.Y), 0) * CFrame.Angles(math.rad(rotation.X), 0, 0)
        
        local move = Vector3.new()
        if UIS:IsKeyDown(keybinds.Forward) then move += rotCF.LookVector end
        if UIS:IsKeyDown(keybinds.Backward) then move -= rotCF.LookVector end
        if UIS:IsKeyDown(keybinds.Left) then move -= rotCF.RightVector end
        if UIS:IsKeyDown(keybinds.Right) then move += rotCF.RightVector end
        if UIS:IsKeyDown(keybinds.Up) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(keybinds.Down) then move -= Vector3.new(0, 1, 0) end
        
        Camera.CFrame = CFrame.new(Camera.CFrame.Position + move * freecamSpeed) * rotCF
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp and input.KeyCode ~= keybinds.OpenMenu then return end
    if input.KeyCode == keybinds.ToggleFreecam then
        toggleFreecam(not freecamActive)
    elseif input.KeyCode == keybinds.OpenMenu and freecamActive then
        menuMode = not menuMode
        UIS.MouseBehavior = menuMode and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = menuMode
    elseif input.KeyCode == keybinds.TeleportChar and freecamActive then
        teleportBody()
    end
end)

---------------------------------------------------------
-------------------- CLOSE & CIRCLE ---------------------
---------------------------------------------------------

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.new(0.6, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)

local circle = Instance.new("Frame")
circle.Size = UDim2.new(0, 45, 0, 45)
circle.Position = UDim2.new(0.8, 0, 0.8, 0)
circle.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
circle.Visible = false
circle.Draggable, circle.Active = true, true
circle.Parent = gui
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible, circle.Visible = false, true
end)

circle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainFrame.Visible, circle.Visible = true, false
    end
end)
