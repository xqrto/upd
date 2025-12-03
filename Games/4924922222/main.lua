local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("DeinScreenGuiName") -- Ersetze mit deinem ScreenGui Namen

local scrollingFrame = gui:WaitForChild("ScrollingFrame") -- Dein ScrollFrame
local buttonTemplate = gui:WaitForChild("ButtonTemplate") -- Ein vorgefertigter Button (kann unsichtbar sein)

-- Beispiel-Liste mit Namen und Links (URLs)
local buttonsData = {
    {name = "Button 1", link = "https://deineurl1.com/code.lua"},
    {name = "Button 2", link = "https://deineurl2.com/code.lua"},
    {name = "Button 3", link = "https://deineurl3.com/code.lua"},
}

-- Funktion, um Buttons zu erstellen
local function createButton(data)
    local newButton = buttonTemplate:Clone()
    newButton.Name = data.name
    newButton.Text = data.name
    newButton.Parent = scrollingFrame
    newButton.Visible = true
    
    -- Animation: Fade in
    newButton.BackgroundTransparency = 1
    newButton.TextTransparency = 1
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = tweenService:Create(newButton, tweenInfo, {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    tween:Play()

    -- Klick-Event
    newButton.MouseButton1Click:Connect(function()
        local codeUrl = data.link
        local code = game:HttpGet(codeUrl)
        local func, err = loadstring(code)
        if func then
            pcall(func)
        else
            warn("Fehler beim Laden des Codes: " .. err)
        end
    end)
end

-- Vorhandene Buttons löschen
for _, btn in pairs(scrollingFrame:GetChildren()) do
    if btn:IsA("TextButton") then
        btn:Destroy()
    end
end

-- Neue Buttons erstellen
for _, data in ipairs(buttonsData) do
    createButton(data)
end
