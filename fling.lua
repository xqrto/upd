local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local walkflinging = false
local flingConnection

-- === GUI Variablen ===
local guiOpen = true
local lastClick = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- --- Haupt GUI ---
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = screenGui
mainFrame.Active = true

-- An/Aus Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.7, 0, 1, 0)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.Text = "Walk Fling: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
toggleButton.Parent = mainFrame

-- X Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.3, 0, 1, 0)
closeBtn.Position = UDim2.new(0.7, 0, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
closeBtn.Parent = mainFrame

-- --- V-Kreis GUI (minimized) ---
local vCircle = Instance.new("TextButton")
vCircle.Size = UDim2.new(0, 50, 0, 50)
vCircle.Position = mainFrame.Position
vCircle.AnchorPoint = Vector2.new(0.5, 0.5)
vCircle.Text = "V"
vCircle.TextColor3 = Color3.fromRGB(255,255,255)
vCircle.BackgroundColor3 = Color3.fromRGB(255,0,0)
vCircle.Visible = false
vCircle.BorderSizePixel = 0
vCircle.Parent = screenGui
vCircle.Active = true
vCircle.ClipsDescendants = true

-- Regenbogen Effekt für V-Kreis
spawn(function()
    local hue = 0
    while true do
        if vCircle.Visible then
            hue = (hue + 1) % 360
            vCircle.BackgroundColor3 = Color3.fromHSV(hue/360,1,1)
        end
        RunService.RenderStepped:Wait()
    end
end)

-- === Dragging für beide GUIs ===
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos, dragInput

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(vCircle)

-- === Button Funktionen ===
toggleButton.MouseButton1Click:Connect(function()
    walkflinging = not walkflinging
    if walkflinging then
        toggleButton.Text = "Walk Fling: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
        if LocalPlayer.Character then
            startWalkFling(LocalPlayer.Character)
        end
    else
        toggleButton.Text = "Walk Fling: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    vCircle.Visible = true
end)

vCircle.MouseButton1Click:Connect(function()
    if tick() - lastClick < 0.3 then
        -- Doppel-Klick öffnet GUI
        mainFrame.Visible = true
        vCircle.Visible = false
    end
    lastClick = tick()
end)

-- === Walk Fling Logic (unverändert) ===
function startWalkFling(char)
    local Root = char:WaitForChild("HumanoidRootPart")
    local Humanoid = char:WaitForChild("Humanoid")

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
    Humanoid.BreakJointsOnDeath = false

    flingConnection = RunService.Stepped:Connect(function()
        if walkflinging then
            Humanoid.Health = math.huge
            Humanoid.MaxHealth = math.huge
        end
    end)

    Root.CanCollide = false
    Humanoid:ChangeState(11)

    spawn(function()
        while walkflinging and Root and Root.Parent do
            RunService.Heartbeat:Wait()
            local vel = Root.Velocity
            Root.Velocity = vel * 99999999 + Vector3.new(0,99999999,0)
            RunService.RenderStepped:Wait()
            Root.Velocity = vel
            RunService.Stepped:Wait()
            Root.Velocity = vel + Vector3.new(0,0.1,0)
        end
    end)
end

-- Charakterwechsel
LocalPlayer.CharacterAdded:Connect(function(char)
    if walkflinging then
        startWalkFling(char)
    end
end)

-- Falls Charakter schon da ist
if LocalPlayer.Character then
    startWalkFling(LocalPlayer.Character)
end
