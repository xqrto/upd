-- Robust NoClip LocalScript (Persistent & Optimized)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local noclipEnabled = false
local noclipConnection = nil

-- GUI Erstellung
local gui = Instance.new("ScreenGui")
gui.Name = "NoClipGUI_v2"
gui.ResetOnSpawn = false -- GUI bleibt nach Tod erhalten
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 130) -- Unter dem Fly GUI positioniert
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "NoClip (xqrto)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "NoClip: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 20

-- NoClip Kern-Logik
local function setNoClip()
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end

local function toggleNoClip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        toggleBtn.Text = "NoClip: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Starte die Schleife
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(setNoClip)
    else
        toggleBtn.Text = "NoClip: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        -- Beende die Schleife
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Einmalig Kollision zurücksetzen (optional, Charakter stellt es oft selbst wieder her)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Button Klick
toggleBtn.MouseButton1Click:Connect(toggleNoClip)

-- WICHTIG: Reset nach Respawn
-- Wenn der Spieler stirbt, setzen wir den Status intern zurück, 
-- damit es nicht zu Glitches kommt, aber das GUI bleibt an.
player.CharacterAdded:Connect(function()
    if noclipEnabled then
        -- Kurz warten bis Charakter geladen ist, dann NoClip wieder aktivieren
        task.wait(0.1)
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(setNoClip)
    end
end)

-- Wenn der Charakter entfernt wird (Tod)
player.CharacterRemoving:Connect(function()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end)
