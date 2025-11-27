-- Free Fly LocalScript mit persistentem GUI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Fly Settings
local flying = false
local flySpeed = 50

-- GUI erstellen, persistent
local gui = Instance.new("ScreenGui")
gui.Name = "FlyGUI"
gui.ResetOnSpawn = false -- ! Wichtig, damit GUI nach Tod bleibt
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0,20,0,20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Buttons
local function createButton(text,pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,80,0,30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Parent = frame
    return btn
end

local flyBtn = createButton("Fly On/Off", UDim2.new(0,10,0,10))
flyBtn.Size = UDim2.new(0,180,0,30)
flyBtn.TextSize = 20
local speedUp = createButton("Speed +", UDim2.new(0,10,0,50))
local speedDown = createButton("Speed -", UDim2.new(0,100,0,50))

-- Fly toggle
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    humanoid.PlatformStand = flying
end)

-- Speed buttons
speedUp.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 10
end)

speedDown.MouseButton1Click:Connect(function()
    flySpeed = math.max(10, flySpeed - 10)
end)

-- Fly Movement
local function getMovementVector()
    local cam = workspace.CurrentCamera
    local moveDir = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
    if moveDir.Magnitude > 0 then
        return moveDir.Unit * flySpeed
    else
        return Vector3.new(0,0,0)
    end
end

RunService.RenderStepped:Connect(function()
    if flying then
        if hrp then
            hrp.Velocity = getMovementVector()
        end
    end
end)
