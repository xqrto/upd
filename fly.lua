local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variablen für Charakter-Referenzen
local character, humanoid, hrp
local function updateCharacterReferences(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end

if player.Character then updateCharacterReferences(player.Character) end
player.CharacterAdded:Connect(updateCharacterReferences)

-- Fly Settings
local flying = false
local orbitMode = false -- Wenn an, dreht sich der Charakter mit der Kamera
local flySpeed = 50
local bv, bg -- Physikalische Instanzen für stabiles Fliegen

-- GUI Erstellung (ResetOnSpawn = false ist der Schlüssel)
local gui = Instance.new("ScreenGui")
gui.Name = "AdvancedFlyGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function createButton(text, pos, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 85, 0, 30)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame
    return btn
end

local flyBtn = createButton("Fly: OFF", UDim2.new(0, 10, 0, 10), UDim2.new(0, 180, 0, 35))
local orbitBtn = createButton("Orbit: OFF", UDim2.new(0, 10, 0, 50), UDim2.new(0, 180, 0, 30))
local speedUp = createButton("Speed +", UDim2.new(0, 10, 0, 90))
local speedDown = createButton("Speed -", UDim2.new(0, 105, 0, 90))

-- Hilfsfunktion: Flug-Physik bereinigen
local function stopFlying()
    flying = false
    flyBtn.Text = "Fly: OFF"
    flyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    if humanoid then humanoid.PlatformStand = false end
end

-- Fly Toggle
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        flying = true
        flyBtn.Text = "Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Erstelle Physik-Helfer für flüssige Bewegung
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
    end
end)

-- Orbit Toggle (Drehung an/aus)
orbitBtn.MouseButton1Click:Connect(function()
    orbitMode = not orbitMode
    orbitBtn.Text = orbitMode and "Orbit: ON" or "Orbit: OFF"
    orbitBtn.BackgroundColor3 = orbitMode and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(45, 45, 45)
end)

-- Speed Controls
speedUp.MouseButton1Click:Connect(function() flySpeed = flySpeed + 20 end)
speedDown.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 20) end)

-- Haupt-Loop für Bewegung
RunService.RenderStepped:Connect(function()
    if flying and hrp and bv and bg then
        humanoid.PlatformStand = true
        
        local moveDir = Vector3.new(0,0,0)
        local camCF = camera.CFrame
        
        -- Inputs abfragen
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        -- Geschwindigkeit anwenden
        bv.Velocity = moveDir.Unit * flySpeed
        if moveDir.Magnitude == 0 then bv.Velocity = Vector3.new(0,0,0) end
        
        -- Rotation (Orbit Modus)
        if orbitMode then
            bg.CFrame = camCF
        else
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z))
        end
    end
end)

-- Fix: Wenn Spieler stirbt, Fly ausschalten
player.CharacterRemoving:Connect(function()
    stopFlying()
end)
