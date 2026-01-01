local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--================ CLEANUP ================
local function cleanup()
    local g = LP.PlayerGui:FindFirstChild("xrHUB")
    if g then g:Destroy() end
    Camera.CameraType = Enum.CameraType.Custom
end
cleanup()

--================ GUI ================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "xrHUB"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
local mainWidth, mainHeight = 440, 500
local titleHeight = 35

-- Positionierung: Jetzt ca. 1cm (50 Pixel) vom rechten Rand entfernt
local rightOffset = -mainWidth - 250
local posHidden = UDim2.new(1, rightOffset, 1, -titleHeight - 10)
local posVisible = UDim2.new(1, rightOffset, 1, -mainHeight - 10)

main.Size = UDim2.new(0, mainWidth, 0, mainHeight)
main.Position = posHidden
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Active = true
main.Draggable = false 
main.ClipsDescendants = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, titleHeight)
title.Text = "    xr HUB V28 - LITE"
title.Font = Enum.Font.Code
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title)

--================ ANIMATION LOGIC ================
local isOut = false
local lastLeaveTime = 0
local leaveDelay = 3 

local function tweenGui(targetPos)
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

main.MouseEnter:Connect(function()
    isOut = true
    lastLeaveTime = tick()
    tweenGui(posVisible)
end)

main.MouseLeave:Connect(function()
    isOut = false
    lastLeaveTime = tick()
end)

RunService.Heartbeat:Connect(function()
    if not isOut and (tick() - lastLeaveTime) >= leaveDelay then
        if main.Position ~= posHidden then
            tweenGui(posHidden)
        end
    end
end)

--================ TABS & CONTENT (Rest des Scripts) ================
local tabs = Instance.new("Frame", main)
tabs.Size = UDim2.new(1,0,0,30)
tabs.Position = UDim2.new(0,0,0,35)
tabs.BackgroundTransparency = 1

local function tabBtn(txt,x)
    local b = Instance.new("TextButton", tabs)
    b.Size = UDim2.new(0.5,0,1,0)
    b.Position = UDim2.new(x,0,0,0)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local tabSingle = tabBtn("SINGLE", 0)
local tabTools = tabBtn("TOOLS", 0.5)

local contentSingle = Instance.new("Frame", main)
contentSingle.Size = UDim2.new(1,-20,1,-80)
contentSingle.Position = UDim2.new(0,10,0,75)
contentSingle.BackgroundTransparency = 1

local contentTools = contentSingle:Clone()
contentTools.Parent = main
contentTools.Visible = false

local selectedPlayer

--================ DROPDOWN ================
local function createDropdown(parent, onSelect)
    local search = Instance.new("TextBox", parent)
    search.Size = UDim2.new(1,0,0,30)
    search.PlaceholderText = "Spieler suchen..."
    search.BackgroundColor3 = Color3.fromRGB(25,25,25)
    search.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", search)

    local drop = Instance.new("TextButton", parent)
    drop.Size = UDim2.new(1,0,0,35)
    drop.Position = UDim2.new(0,0,0,35)
    drop.Text = "Spieler wählen"
    drop.BackgroundColor3 = Color3.fromRGB(40,40,40)
    drop.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", drop)

    local list = Instance.new("ScrollingFrame", parent)
    list.Size = UDim2.new(1,0,0,130)
    list.Position = UDim2.new(0,0,0,75)
    list.Visible = false
    list.ScrollBarThickness = 4
    list.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UIListLayout", list)

    local function refresh()
        for _,v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and (search.Text == "" or p.Name:lower():find(search.Text:lower())) then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.new(1,-10,0,30)
                b.Text = p.Name
                b.BackgroundColor3 = Color3.fromRGB(50,50,50)
                b.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", b)
                b.MouseButton1Click:Connect(function()
                    onSelect(p)
                    drop.Text = "Target: "..p.Name
                    list.Visible = false
                end)
            end
        end
    end
    drop.MouseButton1Click:Connect(function() list.Visible = not list.Visible if list.Visible then refresh() end end)
    search:GetPropertyChangedSignal("Text"):Connect(function() refresh() list.Visible = true end)
    return refresh
end

createDropdown(contentSingle, function(p) selectedPlayer = p end)

--================ LOGIC =================
local function ensureCouch()
    local char = LP.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local couch = char:FindFirstChild("Couch") or LP.Backpack:FindFirstChild("Couch")
    if couch then hum:EquipTool(couch) else
        local oldCamCF = Camera.CFrame
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = oldCamCF
        local oldCF = hrp.CFrame
        hrp.CFrame = CFrame.new(-82.6, 27, -129.9)
        task.wait(1)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.2)
        hrp.CFrame = oldCF
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function vehicleAction(target)
    if not target or not target.Character then return end
    local char = LP.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or not tHRP then return end
    local VEHICLES_FOLDER = workspace:FindFirstChild("Vehicles")
    if not VEHICLES_FOLDER then return end
    local targetCarName = (LP.Name .. "CAR"):upper()
    local myCar = nil
    for _, v in pairs(VEHICLES_FOLDER:GetChildren()) do
        if v:IsA("Model") and v.Name:upper() == targetCarName then myCar = v break end
    end
    if not myCar then return end
    local seat = nil
    for _, obj in pairs(myCar:GetDescendants()) do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then seat = obj break end
    end
    if seat then
        local oldCF = hrp.CFrame
        char:PivotTo(seat.CFrame + Vector3.new(0, 2, 0))
        task.wait(0.1)
        seat:Sit(hum)
        task.wait(0.2)
        myCar:PivotTo(tHRP.CFrame * CFrame.new(0, 5, 0))
        task.wait(0.5)
        hum.Sit = false 
        task.wait(0.1)
        hrp.CFrame = oldCF
    end
end

local function orbitUntilSit(tHRP, tHum, myHRP)
    local start = tick()
    local myChar = myHRP.Parent
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if myHum then myHum.PlatformStand = true end
    for _, part in pairs(myChar:GetDescendants()) do 
        if part:IsA("BasePart") then part.CanCollide = false end 
    end
    while tick() - start < 10 do
        if tHum.Sit then 
            if myHum then myHum.PlatformStand = false end
            return true 
        end
        local speed = 14
        local radius = 0.6
        local heightOffset = -3.4
        local prediction = tHRP.Velocity * 0.15 
        local targetPos = tHRP.Position + prediction
        local angle = tick() * speed
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        myHRP.CFrame = CFrame.new(Vector3.new(targetPos.X + x, targetPos.Y + heightOffset, targetPos.Z + z))
        tHRP.Velocity = Vector3.new(0, 0, 0)
        tHRP.RotVelocity = Vector3.new(0, 0, 0)
        RunService.Heartbeat:Wait()
    end
    if myHum then myHum.PlatformStand = false end
    return false
end

local function singleAction(mode, target)
    if not target or not target.Character then return end
    local myChar = LP.Character
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local tHum = target.Character:FindFirstChild("Humanoid")
    if not myHRP or not tHRP or not tHum then return end
    local oldCamCF = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = oldCamCF
    ensureCouch()
    local startCF = myHRP.CFrame
    orbitUntilSit(tHRP, tHum, myHRP)
    if mode == "Bring" then
        myHRP.CFrame = startCF
        task.wait(0.5)
        myChar.Humanoid:UnequipTools()
    elseif mode == "Kill" then
        myHRP.CFrame = CFrame.new(192195, 0, -19304)
        task.wait(0.5)
        myChar.Humanoid:UnequipTools()
        task.wait(0.5)
        myHRP.CFrame = startCF
    end
    Camera.CameraType = Enum.CameraType.Custom
end

--================ BUTTON HELPER ================
local function mkBtn(parent,txt,y,cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,35)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
    return b
end

--================ BUTTONS ================
mkBtn(contentSingle,"BRING",220,function() singleAction("Bring", selectedPlayer) end)
mkBtn(contentSingle,"KILL",260,function() singleAction("Kill", selectedPlayer) end)
mkBtn(contentSingle,"TP TO PLAYER",300,function() 
    if selectedPlayer and selectedPlayer.Character then
        local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then
            ensureCouch()
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -2)
        end
    end
end)

local vehBtn = mkBtn(contentSingle,"VEHICLE TP",340,function() vehicleAction(selectedPlayer) end)
vehBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 30)

local debugBtn = mkBtn(contentSingle,"GET COUCH (DEBUG)",385,function() ensureCouch() end)
debugBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)

mkBtn(contentTools,"Give Bring Tool",50,function() 
    local t = Instance.new("Tool", LP.Backpack)
    t.Name = "Bring Tool"
    t.RequiresHandle = false
    t.Activated:Connect(function()
        local p = Players:GetPlayerFromCharacter(LP:GetMouse().Target.Parent)
        if p then singleAction("Bring", p) end
    end)
end)
mkBtn(contentTools,"Give Kill Tool",100,function() 
    local t = Instance.new("Tool", LP.Backpack)
    t.Name = "Kill Tool"
    t.RequiresHandle = false
    t.Activated:Connect(function()
        local p = Players:GetPlayerFromCharacter(LP:GetMouse().Target.Parent)
        if p then singleAction("Kill", p) end
    end)
end)

tabSingle.MouseButton1Click:Connect(function() contentSingle.Visible = true; contentTools.Visible = false end)
tabTools.MouseButton1Click:Connect(function() contentSingle.Visible = false; contentTools.Visible = true end)

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30); close.Position = UDim2.new(1,-35,0,2); close.Text = "X"; close.TextColor3 = Color3.new(1,0,0); close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(cleanup)
