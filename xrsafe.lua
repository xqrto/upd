local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

--================ CLEANUP ================
local function cleanup()
    local g = LP.PlayerGui:FindFirstChild("xrSafety")
    if g then g:Destroy() end
end
cleanup()

--================ GUI MAIN ================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "xrSafety"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 350)
main.Position = UDim2.new(0.05, 0, 0.4, 0) -- Positioniert auf der linken Seite
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "   xr SAFETY MODULE"
title.Font = Enum.Font.Code
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title)

--================ WARNING LABEL (ENGLISH) ================
local warning = Instance.new("TextLabel", main)
warning.Size = UDim2.new(0.9, 0, 0, 60)
warning.Position = UDim2.new(0.05, 0, 0, 45)
warning.Text = "ATTENTION: If ANTI-SIT is ENABLED,\nVehicle TP will NOT work correctly!\nKeep it OFF while using vehicles."
warning.TextColor3 = Color3.fromRGB(255, 100, 100)
warning.TextScaled = true
warning.BackgroundTransparency = 1
warning.Font = Enum.Font.SourceSansBold

--================ STATE ================
local antiSit, antiFling, voidEnabled = false, false, false
local VOID_Y, SPAWN_POS, MAX_SPEED = -5, Vector3.new(-61, 5, 26), 120
local lastSafeCFrame = nil

local function mkBtn(parent, txt, y, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

--================ BUTTONS ================
local sitBtn = mkBtn(main, "ANTI SIT: OFF", 115, function(b)
    antiSit = not antiSit
    b.Text = "ANTI SIT: " .. (antiSit and "ON" or "OFF")
    b.BackgroundColor3 = antiSit and Color3.fromRGB(60, 40, 40) or Color3.fromRGB(45, 45, 45)
    if not antiSit then
        LP.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end
end)

local flingBtn = mkBtn(main, "ANTI FLING: OFF", 165, function(b)
    antiFling = not antiFling
    b.Text = "ANTI FLING: " .. (antiFling and "ON" or "OFF")
    b.BackgroundColor3 = antiFling and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(45, 45, 45)
end)

local voidBtn = mkBtn(main, "VOID CHECK: OFF", 215, function(b)
    voidEnabled = not voidEnabled
    b.Text = "VOID CHECK: " .. (voidEnabled and "ON" or "OFF")
    b.BackgroundColor3 = voidEnabled and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(45, 45, 45)
end)

local respawnBtn = mkBtn(main, "FORCE RE-SPAWN", 275, function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(SPAWN_POS)
    end
end)
respawnBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)

--================ HEARTBEAT LOOP ================
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    -- ANTI SIT
    if antiSit then
        if hum.Sit then hum.Sit = false end
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    else
        -- Only enable if not manually disabled by other scripts
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end
    
    -- ANTI FLING & VOID
    if hrp.Position.Y > 5 then lastSafeCFrame = hrp.CFrame end
    
    if antiFling and hrp.AssemblyLinearVelocity.Magnitude > MAX_SPEED and lastSafeCFrame then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = lastSafeCFrame
    end
    
    if voidEnabled and hrp.Position.Y < VOID_Y then
        hrp.CFrame = CFrame.new(SPAWN_POS)
    end
end)

-- Close Button
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 2)
close.Text = "X"
close.TextColor3 = Color3.new(1, 0, 0)
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(cleanup)
