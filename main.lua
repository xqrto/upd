local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Funktion zum Anzeigen einer Nachricht
local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "Info",
        Text = message,
        Duration = 5
    })
end

-- Nach 5 Sekunden Notification anzeigen
task.delay(5, function()
    notify("Press (ALT) to open the Menu")
end)

-- Funktion zum Laden und Ausführen eines Scripts vom URL
local function executeScriptFromURL(url)
    local success, scriptCode = pcall(function()
        return game:HttpGet(url)
    end)
    if success and scriptCode then
        local func, err = loadstring(scriptCode)
        if func then
            func()
        else
            notify("Fehler beim Ausführen des Scripts: " .. err)
        end
    else
        notify("Fehler beim Laden des Scripts von: " .. url)
    end
end

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XQRTO_ScriptHub"
    screenGui.Parent = PlayerGui
    screenGui.Enabled = false -- Anfangs versteckt

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true

    -- Tabs-Buttons
    local tabNames = {"xqrtp", "Mods", "Items", "extras"}
    local tabs = {}
    local tabButtonsParent = Instance.new("Frame")
    tabButtonsParent.Size = UDim2.new(1, 0, 0, 30)
    tabButtonsParent.Position = UDim2.new(0, 0, 0, 0)
    tabButtonsParent.BackgroundTransparency = 1
    tabButtonsParent.Parent = mainFrame

    local function createTabButton(name, index)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #tabNames, 0, 1, 0)
        btn.Position = UDim2.new((index - 1) / #tabNames, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.AutoButtonColor = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = tabButtonsParent
        return btn
    end

    for i, name in ipairs(tabNames) do
        tabs[i] = createTabButton(name, i)
    end

    -- Bereiche für jeden Tab
    local function createTabFrame(yOffset)
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, -20, 1, -40)
        frame.Position = UDim2.new(0, 10, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 8
        frame.Visible = false
        frame.Parent = mainFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = frame

        -- CanvasSize automatisch anpassen
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)

        return frame
    end

    local tabFrames = {
        createTabFrame(50), -- Scripts
        createTabFrame(50), -- Mods
        createTabFrame(50), -- Items
        createTabFrame(50), -- Cosmetics
    }

    -- Funktion zum Wechseln der Tabs
    local function activateTab(index)
        for i, frame in ipairs(tabFrames) do
            frame.Visible = (i == index)
        end
    end

    -- Starte mit "Scripts" aktiv
    activateTab(1)

    -- Buttons für Tabs
    for i, btn in ipairs(tabs) do
        btn.MouseButton1Click:Connect(function()
            activateTab(i)
        end)
    end

    -- Funktion zum Erstellen der Buttons in jedem Tab
    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.AutoButtonColor = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 20
        btn.Text = text
        btn.Parent = parent

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        end)

        btn.MouseButton1Click:Connect(callback)
    end

    -- Definition der Button-Listen
    local scriptButtons = {
        {name = "AimBot", url = "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
        {name = "AimBot-old", url = "https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
        {name = "Gun-Mods", url = "https://raw.githubusercontent.com/xqrto/upd/main/gunm.lua"},
        {name = "NoClip", url = "https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
        {name = "FreeCam", url = "https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
        {name = "Fly", url = "https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
        {name = "Tracer", url = "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
    }

    local ItemButtons = {
        {name = "Nothing", url = "https://raw.githubusercontent.com/xqrto/upd/main/.lua"},
        -- weitere Items hier
    }

    local CcosmeticButtons = {
        {name = "fling", url = "https://raw.githubusercontent.com/xqrto/upd/main/fling.lua"},
        -- weitere Cosmeticals hier
    }

    -- Buttons für "Scripts" Tab
    for _, btnInfo in ipairs(scriptButtons) do
        createButton(tabFrames[1], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    -- Buttons für "Mods" Tab (ebenfalls mit scriptButtons oder eigenen Listen)
    for _, btnInfo in ipairs(scriptButtons) do
        createButton(tabFrames[2], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    -- Buttons für "Items" Tab
    for _, btnInfo in ipairs(ItemButtons) do
        createButton(tabFrames[3], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    -- Buttons für "Cosmetics" Tab
    for _, btnInfo in ipairs(CcosmeticButtons) do
        createButton(tabFrames[4], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    return screenGui
end

local myGUI = createGUI()

local function toggleGUI()
    myGUI.Enabled = not myGUI.Enabled
end

-- Hotkey Alt zum Umschalten
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        toggleGUI()
    end
end)
