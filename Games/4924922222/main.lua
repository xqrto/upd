local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Brookhaven-RP"
screenGui.Parent = playerGui

-- HauptFrame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0,0)
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true

-- UICorner für abgerundete Ecken
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Titelbar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "X-Api(Brookhaven-RP)"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- X Button (Schließen)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -40, 0, 2.5)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = titleBar
closeButton.AutoButtonColor = true
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimieren Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 35, 0, 35)
minimizeButton.Position = UDim2.new(1, -80, 0, 2.5)
minimizeButton.Text = "–"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = titleBar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeButton

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 350, 0, 40)
    else
        mainFrame.Size = UDim2.new(0, 350, 0, 450)
    end
end)

-- ScrollingFrame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -40)
scrollingFrame.Position = UDim2.new(0, 0, 0, 40)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Parent = mainFrame

-- Button Template
local buttonTemplate = Instance.new("TextButton")
buttonTemplate.Size = UDim2.new(1, -20, 0, 50)
buttonTemplate.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
buttonTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonTemplate.TextScaled = true
buttonTemplate.Visible = false
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = buttonTemplate
buttonTemplate.Parent = mainFrame

-- Beispiel-Daten
local buttonsData = {
    {name="FreeCam", link = "https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
    {name="Fly", link = "https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
    {name="Tracer", link = "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"}
}

-- Tween-Funktion
local function fadeInButton(button, duration)
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = tweenService:Create(button, tweenInfo, {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    tween:Play()
end

-- Button erstellen
local function createButton(data, index)
    local newButton = buttonTemplate:Clone()
    newButton.Name = data.name
    newButton.Text = data.name
    newButton.Visible = true
    newButton.Position = UDim2.new(0, 10, 0, (index-1)*60)
    newButton.Parent = scrollingFrame

    newButton.BackgroundTransparency = 1
    newButton.TextTransparency = 1
    fadeInButton(newButton, 0.5)

    newButton.MouseButton1Click:Connect(function()
        local success, code = pcall(function()
            return game:HttpGet(data.link)
        end)
        if success then
            local func, err = loadstring(game:HttpGet(data.link))()
            if func then
                pcall(func)
            else
                warn("Fehler beim Laden des Codes: " .. err)
            end
        else
            warn("Fehler beim Abrufen des Codes: " .. code)
        end
    end)
end

-- Buttons erstellen
for i, data in ipairs(buttonsData) do
    createButton(data, i)
end

-- CanvasSize anpassen
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #buttonsData * 60)

