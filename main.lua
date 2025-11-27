local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Liste der Skripte mit Name und Link
local scripts = {
    {name = "AimBot", url = "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
}

-- Overlay GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "xqrto`s script hub"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0.7, 0)
frame.Position = UDim2.new(0.25, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Titel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Scripts:"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.Parent = frame

-- ScrollFrame erstellen
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scripts * 60)
scrollFrame.ScrollBarThickness = 10
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = frame

-- UIListLayout für die Buttons
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = scrollFrame

-- Funktion um ein Skript zu laden
local function loadScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success and response then
        local funcSuccess, funcErr = pcall(function()
            loadstring(response)()
        end)
        if not funcSuccess then
            warn("Fehler beim Ausführen des Skripts:", funcErr)
        end
    else
        warn("Fehler beim Laden des Skripts:", url)
    end
end

-- Buttons für jedes Skript erstellen
for i, scriptInfo in ipairs(scripts) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 22
    button.Text = scriptInfo.name
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        screenGui:Destroy()  -- GUI schließen
        loadScript(scriptInfo.url)  -- Skript laden
    end)
end
