local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local remoteName = ReplicatedStorage.RE:WaitForChild("1RPNam1eTex1t")
local remoteColor = ReplicatedStorage.RE:WaitForChild("1RPNam1eColo1r")

-- Variablen
local nameConnection = nil
local bioConnection = nil
local nameEffect = "None"
local bioEffect = "None"
local effectSpeed = 1
local customColors = {}

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrookRPGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Haupt-Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 700)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -350)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 255)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 BROOK RP CHANGER (by xqrto)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
minimizeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Content Frame mit ScrollingFrame
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, -20, 1, -55)
contentScroll.Position = UDim2.new(0, 10, 0, 50)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 6
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 950)
contentScroll.Parent = mainFrame

-- Name Input
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Name:"
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 13
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = contentScroll

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, 0, 0, 40)
nameBox.Position = UDim2.new(0, 0, 0, 25)
nameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
nameBox.BorderSizePixel = 0
nameBox.Text = ""
nameBox.PlaceholderText = "Name"
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 15
nameBox.ClearTextOnFocus = false
nameBox.Parent = contentScroll

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 8)
nameCorner.Parent = nameBox

-- Bio Input
local bioLabel = Instance.new("TextLabel")
bioLabel.Size = UDim2.new(1, 0, 0, 20)
bioLabel.Position = UDim2.new(0, 0, 0, 75)
bioLabel.BackgroundTransparency = 1
bioLabel.Text = "Bio:"
bioLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
bioLabel.Font = Enum.Font.GothamBold
bioLabel.TextSize = 13
bioLabel.TextXAlignment = Enum.TextXAlignment.Left
bioLabel.Parent = contentScroll

local bioBox = Instance.new("TextBox")
bioBox.Size = UDim2.new(1, 0, 0, 40)
bioBox.Position = UDim2.new(0, 0, 0, 100)
bioBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
bioBox.BorderSizePixel = 0
bioBox.Text = ""
bioBox.PlaceholderText = "Bio"
bioBox.TextColor3 = Color3.fromRGB(255, 255, 255)
bioBox.Font = Enum.Font.Gotham
bioBox.TextSize = 15
bioBox.ClearTextOnFocus = false
bioBox.Parent = contentScroll

local bioCorner = Instance.new("UICorner")
bioCorner.CornerRadius = UDim.new(0, 8)
bioCorner.Parent = bioBox

-- Set Button
local setButton = Instance.new("TextButton")
setButton.Size = UDim2.new(1, 0, 0, 45)
setButton.Position = UDim2.new(0, 0, 0, 150)
setButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
setButton.BorderSizePixel = 0
setButton.Text = "✓ Name & Bio setzen"
setButton.TextColor3 = Color3.fromRGB(255, 255, 255)
setButton.Font = Enum.Font.GothamBold
setButton.TextSize = 16
setButton.Parent = contentScroll

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 8)
setCorner.Parent = setButton

-- NAME EFFEKTE
local nameEffectLabel = Instance.new("TextLabel")
nameEffectLabel.Size = UDim2.new(1, 0, 0, 25)
nameEffectLabel.Position = UDim2.new(0, 0, 0, 210)
nameEffectLabel.BackgroundTransparency = 1
nameEffectLabel.Text = "⚡ Name Effekte"
nameEffectLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
nameEffectLabel.Font = Enum.Font.GothamBold
nameEffectLabel.TextSize = 16
nameEffectLabel.TextXAlignment = Enum.TextXAlignment.Left
nameEffectLabel.Parent = contentScroll

local nameEffects = {
    {name = "Wave", color = Color3.fromRGB(0, 191, 255), icon = "🌊"},
    {name = "Stroke", color = Color3.fromRGB(138, 43, 226), icon = "✨"},
    {name = "Fade", color = Color3.fromRGB(255, 105, 180), icon = "💫"},
    {name = "Stop", color = Color3.fromRGB(200, 50, 50), icon = "⏹️"}
}

for i, effect in ipairs(nameEffects) do
    local col = (i - 1) % 2
    
    local effectBtn = Instance.new("TextButton")
    effectBtn.Name = "Name" .. effect.name .. "Button"
    effectBtn.Size = UDim2.new(0.48, 0, 0, 45)
    effectBtn.Position = UDim2.new(col * 0.52, 0, 0, 240 + math.floor((i-1)/2) * 55)
    effectBtn.BackgroundColor3 = effect.color
    effectBtn.BorderSizePixel = 0
    effectBtn.Text = effect.icon .. " " .. effect.name
    effectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    effectBtn.Font = Enum.Font.GothamBold
    effectBtn.TextSize = 14
    effectBtn.Parent = contentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = effectBtn
end

-- BIO EFFEKTE
local bioEffectLabel = Instance.new("TextLabel")
bioEffectLabel.Size = UDim2.new(1, 0, 0, 25)
bioEffectLabel.Position = UDim2.new(0, 0, 0, 360)
bioEffectLabel.BackgroundTransparency = 1
bioEffectLabel.Text = "💬 Bio effets"
bioEffectLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
bioEffectLabel.Font = Enum.Font.GothamBold
bioEffectLabel.TextSize = 16
bioEffectLabel.TextXAlignment = Enum.TextXAlignment.Left
bioEffectLabel.Parent = contentScroll

local bioEffects = {
    {name = "Wave", color = Color3.fromRGB(0, 191, 255), icon = "🌊"},
    {name = "Stroke", color = Color3.fromRGB(138, 43, 226), icon = "✨"},
    {name = "Fade", color = Color3.fromRGB(255, 105, 180), icon = "💫"},
    {name = "Stop", color = Color3.fromRGB(200, 50, 50), icon = "⏹️"}
}

for i, effect in ipairs(bioEffects) do
    local col = (i - 1) % 2
    
    local effectBtn = Instance.new("TextButton")
    effectBtn.Name = "Bio" .. effect.name .. "Button"
    effectBtn.Size = UDim2.new(0.48, 0, 0, 45)
    effectBtn.Position = UDim2.new(col * 0.52, 0, 0, 390 + math.floor((i-1)/2) * 55)
    effectBtn.BackgroundColor3 = effect.color
    effectBtn.BorderSizePixel = 0
    effectBtn.Text = effect.icon .. " " .. effect.name
    effectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    effectBtn.Font = Enum.Font.GothamBold
    effectBtn.TextSize = 14
    effectBtn.Parent = contentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = effectBtn
end

-- CUSTOM COLORS SECTION
local colorsLabel = Instance.new("TextLabel")
colorsLabel.Size = UDim2.new(1, 0, 0, 25)
colorsLabel.Position = UDim2.new(0, 0, 0, 510)
colorsLabel.BackgroundTransparency = 1
colorsLabel.Text = "🎨 Custom colors"
colorsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
colorsLabel.Font = Enum.Font.GothamBold
colorsLabel.TextSize = 16
colorsLabel.TextXAlignment = Enum.TextXAlignment.Left
colorsLabel.Parent = contentScroll

local addColorBtn = Instance.new("TextButton")
addColorBtn.Name = "AddColorBtn"
addColorBtn.Size = UDim2.new(1, 0, 0, 40)
addColorBtn.Position = UDim2.new(0, 0, 0, 540)
addColorBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
addColorBtn.BorderSizePixel = 0
addColorBtn.Text = "+ Farbe hinzufügen"
addColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addColorBtn.Font = Enum.Font.GothamBold
addColorBtn.TextSize = 14
addColorBtn.Parent = contentScroll

local addColorCorner = Instance.new("UICorner")
addColorCorner.CornerRadius = UDim.new(0, 8)
addColorCorner.Parent = addColorBtn

-- Color List ScrollFrame
local colorListFrame = Instance.new("ScrollingFrame")
colorListFrame.Name = "ColorListFrame"
colorListFrame.Size = UDim2.new(1, 0, 0, 120)
colorListFrame.Position = UDim2.new(0, 0, 0, 590)
colorListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
colorListFrame.BorderSizePixel = 0
colorListFrame.ScrollBarThickness = 4
colorListFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
colorListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
colorListFrame.Parent = contentScroll

local colorListCorner = Instance.new("UICorner")
colorListCorner.CornerRadius = UDim.new(0, 8)
colorListCorner.Parent = colorListFrame

local colorListLayout = Instance.new("UIListLayout")
colorListLayout.Padding = UDim.new(0, 5)
colorListLayout.FillDirection = Enum.FillDirection.Vertical
colorListLayout.Parent = colorListFrame

-- Speed Control
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, -5, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 720)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 1.0x"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 13
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentScroll

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.48, 0, 0, 25)
speedSlider.Position = UDim2.new(0.52, 0, 0, 720)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = contentScroll

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = speedSlider

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = speedFill

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 20, 0, 20)
speedKnob.Position = UDim2.new(0.5, -10, 0.5, -10)
speedKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedSlider

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = speedKnob

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 755)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Bereit ✓"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = contentScroll

-- Color Picker Frame (versteckt)
local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Name = "ColorPickerFrame"
colorPickerFrame.Size = UDim2.new(0, 300, 0, 350)
colorPickerFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
colorPickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
colorPickerFrame.BorderSizePixel = 0
colorPickerFrame.Visible = false
colorPickerFrame.ZIndex = 10
colorPickerFrame.Parent = screenGui

local pickerCorner = Instance.new("UICorner")
pickerCorner.CornerRadius = UDim.new(0, 12)
pickerCorner.Parent = colorPickerFrame

local pickerStroke = Instance.new("UIStroke")
pickerStroke.Color = Color3.fromRGB(100, 100, 255)
pickerStroke.Thickness = 2
pickerStroke.Parent = colorPickerFrame

local pickerTitle = Instance.new("TextLabel")
pickerTitle.Size = UDim2.new(1, -20, 0, 40)
pickerTitle.Position = UDim2.new(0, 10, 0, 10)
pickerTitle.BackgroundTransparency = 1
pickerTitle.Text = "🎨 Farbe wählen"
pickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
pickerTitle.Font = Enum.Font.GothamBold
pickerTitle.TextSize = 18
pickerTitle.Parent = colorPickerFrame

-- RGB Sliders
local selectedColor = Color3.fromRGB(255, 0, 0)

local function createSlider(name, yPos, startValue)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 25)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ":"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorPickerFrame
    
    local slider = Instance.new("Frame")
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(0, 180, 0, 25)
    slider.Position = UDim2.new(0, 60, 0, yPos)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    slider.BorderSizePixel = 0
    slider.Parent = colorPickerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(startValue / 255, 0, 1, 0)
    fill.BackgroundColor3 = name == "R" and Color3.fromRGB(255, 0, 0) or name == "G" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 40, 0, 25)
    valueLabel.Position = UDim2.new(0, 245, 0, yPos)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(startValue)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.Parent = colorPickerFrame
    
    return slider, fill, valueLabel
end

local rSlider, rFill, rValue = createSlider("R", 60, 255)
local gSlider, gFill, gValue = createSlider("G", 95, 0)
local bSlider, bFill, bValue = createSlider("B", 130, 0)

-- Color Preview
local colorPreview = Instance.new("Frame")
colorPreview.Name = "ColorPreview"
colorPreview.Size = UDim2.new(1, -20, 0, 80)
colorPreview.Position = UDim2.new(0, 10, 0, 170)
colorPreview.BackgroundColor3 = selectedColor
colorPreview.BorderSizePixel = 0
colorPreview.Parent = colorPickerFrame

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 8)
previewCorner.Parent = colorPreview

-- Buttons
local saveColorBtn = Instance.new("TextButton")
saveColorBtn.Size = UDim2.new(0.48, 0, 0, 45)
saveColorBtn.Position = UDim2.new(0, 10, 1, -55)
saveColorBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
saveColorBtn.BorderSizePixel = 0
saveColorBtn.Text = "✓ Speichern"
saveColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveColorBtn.Font = Enum.Font.GothamBold
saveColorBtn.TextSize = 14
saveColorBtn.Parent = colorPickerFrame

local saveBtnCorner = Instance.new("UICorner")
saveBtnCorner.CornerRadius = UDim.new(0, 8)
saveBtnCorner.Parent = saveColorBtn

local cancelColorBtn = Instance.new("TextButton")
cancelColorBtn.Size = UDim2.new(0.48, 0, 0, 45)
cancelColorBtn.Position = UDim2.new(0.52, 0, 1, -55)
cancelColorBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cancelColorBtn.BorderSizePixel = 0
cancelColorBtn.Text = "✕ Abbrechen"
cancelColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelColorBtn.Font = Enum.Font.GothamBold
cancelColorBtn.TextSize = 14
cancelColorBtn.Parent = colorPickerFrame

local cancelBtnCorner = Instance.new("UICorner")
cancelBtnCorner.CornerRadius = UDim.new(0, 8)
cancelBtnCorner.Parent = cancelColorBtn

-- Functions
local function updateColorPreview()
    local r = tonumber(rValue.Text) or 255
    local g = tonumber(gValue.Text) or 0
    local b = tonumber(bValue.Text) or 0
    selectedColor = Color3.fromRGB(r, g, b)
    colorPreview.BackgroundColor3 = selectedColor
end

local function updateColorList()
    for _, child in ipairs(colorListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for i, color in ipairs(customColors) do
        local colorItem = Instance.new("Frame")
        colorItem.Size = UDim2.new(1, -10, 0, 35)
        colorItem.BackgroundColor3 = color
        colorItem.BorderSizePixel = 0
        colorItem.Parent = colorListFrame
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = colorItem
        
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 30, 0, 30)
        removeBtn.Position = UDim2.new(1, -32.5, 0.5, -15)
        removeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        removeBtn.BorderSizePixel = 0
        removeBtn.Text = "✕"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.Font = Enum.Font.GothamBold
        removeBtn.TextSize = 14
        removeBtn.Parent = colorItem
        
        local removeBtnCorner = Instance.new("UICorner")
        removeBtnCorner.CornerRadius = UDim.new(0, 6)
        removeBtnCorner.Parent = removeBtn
        
        removeBtn.MouseButton1Click:Connect(function()
            table.remove(customColors, i)
            updateColorList()
        end)
    end
    
    colorListFrame.CanvasSize = UDim2.new(0, 0, 0, #customColors * 40)
end

-- Wave Effect (smooth endless fade)
local function waveEffect(isName)
    local offset = 0
    local colors = #customColors > 0 and customColors or {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 127, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(148, 0, 211)
    }
    
    return RunService.Heartbeat:Connect(function()
        offset = offset + (0.02 * effectSpeed)
        local progress = (offset % #colors)
        local index = math.floor(progress) + 1
        local nextIndex = (index % #colors) + 1
        local blend = progress - math.floor(progress)
        
        local color = colors[index]:Lerp(colors[nextIndex], blend)
        
        if isName then
            remoteColor:FireServer("PickingRPNameColor", color)
        else
            remoteColor:FireServer("PickingRPBioColor", color)
        end
    end)
end

-- Stroke Effect
local function strokeEffect(isName)
    local colors = #customColors > 0 and customColors or {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(148, 0, 211)
    }
    local index = 1
    local progress = 0
    
    return RunService.Heartbeat:Connect(function()
        progress = progress + (0.02 * effectSpeed)
        
        if progress >= 1 then
            progress = 0
            index = index % #colors + 1
        end
        
        local nextIndex = index % #colors + 1
        local color = colors[index]:Lerp(colors[nextIndex], progress)
        
        if isName then
            remoteColor:FireServer("PickingRPNameColor", color)
        else
            remoteColor:FireServer("PickingRPBioColor", color)
        end
    end)
end

-- Fade Effect
local function fadeEffect(isName)
    local hue = 0
    return RunService.Heartbeat:Connect(function()
        hue = hue + (0.003 * effectSpeed)
        local color = Color3.fromHSV(hue % 1, 0.8, 1)
        
        if isName then
            remoteColor:FireServer("PickingRPNameColor", color)
        else
            remoteColor:FireServer("PickingRPBioColor", color)
        end
    end)
end

-- Event Handlers
setButton.MouseButton1Click:Connect(function()
    local name = nameBox.Text
    local bio = bioBox.Text
    
    if name ~= "" then
        remoteName:FireServer("RolePlayName", name)
    end
    if bio ~= "" then
        remoteName:FireServer("RolePlayBio", bio)
    end
    
    statusLabel.Text = "✓ Name & Bio gesetzt!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    wait(2)
    statusLabel.Text = "Status: Bereit ✓"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- Name Effects
contentScroll.NameWaveButton.MouseButton1Click:Connect(function()
    if nameConnection then nameConnection:Disconnect() end
    nameEffect = "Wave"
    nameConnection = waveEffect(true)
    statusLabel.Text = "🌊 Name Wave aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
end)

contentScroll.NameStrokeButton.MouseButton1Click:Connect(function()
    if nameConnection then nameConnection:Disconnect() end
    nameEffect = "Stroke"
    nameConnection = strokeEffect(true)
    statusLabel.Text = "✨ Name Stroke aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
end)

contentScroll.NameFadeButton.MouseButton1Click:Connect(function()
    if nameConnection then nameConnection:Disconnect() end
    nameEffect = "Fade"
    nameConnection = fadeEffect(true)
    statusLabel.Text = "💫 Name Fade aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
end)

contentScroll.NameStopButton.MouseButton1Click:Connect(function()
    if nameConnection then nameConnection:Disconnect() end
    nameEffect = "None"
    statusLabel.Text = "⏹️ Name gestoppt"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

-- Bio Effects
contentScroll.BioWaveButton.MouseButton1Click:Connect(function()
    if bioConnection then bioConnection:Disconnect() end
    bioEffect = "Wave"
    bioConnection = waveEffect(false)
    statusLabel.Text = "🌊 Bio Wave aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
end)

contentScroll.BioStrokeButton.MouseButton1Click:Connect(function()
    if bioConnection then bioConnection:Disconnect() end
    bioEffect = "Stroke"
    bioConnection = strokeEffect(false)
    statusLabel.Text = "✨ Bio Stroke aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
end)

contentScroll.BioFadeButton.MouseButton1Click:Connect(function()
    if bioConnection then bioConnection:Disconnect() end
    bioEffect = "Fade"
    bioConnection = fadeEffect(false)
    statusLabel.Text = "💫 Bio Fade aktiv!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
end)

contentScroll.BioStopButton.MouseButton1Click:Connect(function()
    if bioConnection then bioConnection:Disconnect() end
    bioEffect = "None"
    statusLabel.Text = "⏹️ Bio gestoppt"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

-- Color Picker
addColorBtn.MouseButton1Click:Connect(function()
    colorPickerFrame.Visible = true
    mainFrame.Visible = false
end)

saveColorBtn.MouseButton1Click:Connect(function()
    table.insert(customColors, selectedColor)
    updateColorList()
    colorPickerFrame.Visible = false
    mainFrame.Visible = true
end)

cancelColorBtn.MouseButton1Click:Connect(function()
    colorPickerFrame.Visible = false
    mainFrame.Visible = true
end)

-- RGB Sliders
local function setupSlider(slider, fill, valueLabel, component)
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = slider.AbsolutePosition.X
            local sliderSize = slider.AbsoluteSize.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = math.floor(relativePos * 255)
            
            fill.Size = UDim2.new(relativePos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            updateColorPreview()
        end
    end)
end

setupSlider(rSlider, rFill, rValue, "R")
setupSlider(gSlider, gFill, gValue, "G")
setupSlider(bSlider, bFill, bValue, "B")

-- Speed Slider
local draggingSlider = false

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position.X
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        
        local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        effectSpeed = 0.1 + (relativePos * 2.9)
        
        speedFill.Size = UDim2.new(relativePos, 0, 1, 0)
        speedKnob.Position = UDim2.new(relativePos, -10, 0.5, -10)
        speedLabel.Text = string.format("Speed: %.1fx", effectSpeed)
    end
end)

-- Minimize/Close
local isMinimized = false
local originalSize = mainFrame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 500, 0, 45)
        }):Play()
        contentScroll.Visible = false
        minimizeBtn.Text = "□"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = originalSize
        }):Play()
        contentScroll.Visible = true
        minimizeBtn.Text = "─"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if nameConnection then nameConnection:Disconnect() end
    if bioConnection then bioConnection:Disconnect() end
    screenGui:Destroy()
end)

-- Drag
local dragging, dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("🔥 Brook RP GUI V3 geladen! 🔥")