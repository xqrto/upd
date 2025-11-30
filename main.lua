-- COMPLETE SCRIPT: ScriptHub + Settings (RGB Colorpickers) + Avatar Panel + Theme Save/Load
-- Hinweis: Dieses Script versucht zuerst, writefile() zu nutzen (für Exploit-Umgebungen).
-- Wenn writefile nicht vorhanden ist, speichert es das Theme in PlayerGui als StringValue (Sitzungs-Storage).

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Notification helper
local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "X-ScriptHub",
        Text = message,
        Duration = 4
    })
end

-- Show initial hint after 5s
task.delay(5, function()
    notify("Press (ALT) to open the Menu")
end)

-- function to execute remote script (kept from your original)
local function executeScriptFromURL(url)
    local success, scriptCode = pcall(function()
        return game:HttpGet(url)
    end)
    if success and scriptCode then
        local func, err = loadstring(scriptCode)
        if func then
            func()
        else
            notify("Cant inject the script: " .. tostring(err))
        end
    else
        notify("Cant load the script: " .. tostring(url))
    end
end


-- --- Create GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XQRTO_ScriptHub"
    screenGui.Parent = PlayerGui
    screenGui.Enabled = false -- start hidden

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30) -- Höhe 30px, volle Breite
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "X-ScriptHub"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Parent = titleBar

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    titleBar.Active = true
    titleBar.Draggable = true


    -- Main window
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 420)
    mainFrame.Position = UDim2.new(0.25, 0, 0.18, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.Draggable = false
    mainFrame.ClipsDescendants = true
    mainFrame.Name = "MainFrame"

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Optional light shadow using ImageLabel (works without extra assets too)
    local shadowLabel = Instance.new("ImageLabel")
    shadowLabel.Name = "Shadow"
    shadowLabel.Size = UDim2.new(1, 12, 1, 24)
    shadowLabel.Position = UDim2.new(0, -6, 0, -12)
    shadowLabel.BackgroundTransparency = 1
    shadowLabel.Image = ""
    shadowLabel.Parent = mainFrame
    shadowLabel.ZIndex = 0

    -- Tab buttons holder
    local tabNames = {"xqrto", "Mods", "Items", "extras", "Settings"}
    local tabs = {}
    local tabButtonsParent = Instance.new("Frame")
    tabButtonsParent.Size = UDim2.new(1, 0, 0, 34)
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

    -- Create tab frames
    local function createTabFrame(yOffset)
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, -20, 1, -80)
        frame.Position = UDim2.new(0, 10, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 8
        frame.Visible = false
        frame.Parent = mainFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = frame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)

        return frame
    end

    local tabFrames = {
        createTabFrame(44), -- xqrto
        createTabFrame(44), -- Mods
        createTabFrame(44), -- Items
        createTabFrame(44), -- extras
        createTabFrame(44), -- Settings
    }

    -- Activate tab function
    local function activateTab(index)
        for i, frame in ipairs(tabFrames) do
            frame.Visible = (i == index)
        end
        -- optional visual active state for buttons
        for i, btn in ipairs(tabs) do
            if i == index then
                btn.BackgroundColor3 = Color3.fromRGB(85, 85, 95)
            else
                btn.BackgroundColor3 = Theme.Buttons or Color3.fromRGB(50,50,55)
            end
        end
    end

    -- default activate first tab after Theme is defined (Theme will be created later)
    -- We'll call activateTab(1) after theme setup

    for i, btn in ipairs(tabs) do
        btn.MouseButton1Click:Connect(function()
            activateTab(i)
        end)
    end

    -- Button creation helper
    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 46)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        btn.AutoButtonColor = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 18
        btn.Text = text
        btn.Parent = parent

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 8)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Theme.Buttons or Color3.fromRGB(50, 50, 55)
        end)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- ===== Buttons for tabs (example lists) =====
    local scriptButtons = {
        {name = "AimBot", url = "https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
        {name = "AimBot-old", url = "https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
        {name = "Gun-Mods", url = "https://raw.githubusercontent.com/xqrto/upd/main/gunm.lua"},
        {name = "NoClip", url = "https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
        {name = "FreeCam", url = "https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
        {name = "Fly", url = "https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
        {name = "Tracer", url = "https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"},
        {name = "-", url = "https://raw.githubusercontent.com/xqrto/upd/main/.lua"},
    }

    local ItemButtons = {
        {name = "Telikinesis", url = "https://raw.githubusercontent.com/xqrto/upd/main/telikinesis.lua"},
    }

    local CcosmeticButtons = {
        {name = "fling", url = "https://raw.githubusercontent.com/xqrto/upd/main/fling.lua"},
    }

    -- Populate tabs with buttons
    for _, btnInfo in ipairs(scriptButtons) do
        createButton(tabFrames[1], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    for _, btnInfo in ipairs(scriptButtons) do
        createButton(tabFrames[2], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    for _, btnInfo in ipairs(ItemButtons) do
        createButton(tabFrames[3], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    for _, btnInfo in ipairs(CcosmeticButtons) do
        createButton(tabFrames[4], btnInfo.name, function()
            screenGui.Enabled = false
            executeScriptFromURL(btnInfo.url)
        end)
    end

    -- ========== THEME & COLORPICKER IMPLEMENTATION ==========
    -- Default Theme
    Theme = {
        Background = mainFrame.BackgroundColor3,
        Text = Color3.fromRGB(235, 235, 240),
        Buttons = Color3.fromRGB(50, 50, 55),
        Accent = Color3.fromRGB(100, 100, 255)
    }

    -- Save / Load helpers
    local function tryWriteFile(path, content)
        local ok, err = pcall(function()
            if writefile then
                writefile(path, content)
            else
                error("no writefile")
            end
        end)
        return ok, err
    end

    local function tryReadFile(path)
        local ok, content = pcall(function()
            if readfile then
                return readfile(path)
            else
                error("no readfile")
            end
        end)
        if ok then return content end
        return nil
    end

    local STORAGE_NAME = "xqrto_theme.json"

    local function saveTheme()
        local data = HttpService:JSONEncode({
            Background = {Theme.Background.R, Theme.Background.G, Theme.Background.B},
            Text = {Theme.Text.R, Theme.Text.G, Theme.Text.B},
            Buttons = {Theme.Buttons.R, Theme.Buttons.G, Theme.Buttons.B},
            Accent = {Theme.Accent.R, Theme.Accent.G, Theme.Accent.B}
        })
        -- try writefile
        local ok = false
        ok = tryWriteFile(STORAGE_NAME, data)
        if ok then
            notify("Saved.")
            return
        end
        -- fallback: store in PlayerGui as StringValue
        local sv = PlayerGui:FindFirstChild("XQRTO_ThemeData")
        if not sv then
            sv = Instance.new("StringValue")
            sv.Name = "XQRTO_ThemeData"
            sv.Parent = PlayerGui
        end
        sv.Value = data
        notify("Theme saved local.")
    end

    local function loadTheme()
        local raw = tryReadFile(STORAGE_NAME)
        if not raw then
            -- fallback to StringValue in PlayerGui
            local sv = PlayerGui:FindFirstChild("XQRTO_ThemeData")
            if sv and sv.Value and sv.Value ~= "" then
                raw = sv.Value
            end
        end
        if not raw then
            notify("o theme found.")
            return
        end

        local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or type(decoded) ~= "table" then
            notify("Cant load theme.")
            return
        end

        local function fromArray(a) return Color3.new(a[1], a[2], a[3]) end
        -- note: saved as 0..1 values
        if decoded.Background then Theme.Background = fromArray(decoded.Background) end
        if decoded.Text then Theme.Text = fromArray(decoded.Text) end
        if decoded.Buttons then Theme.Buttons = fromArray(decoded.Buttons) end
        if decoded.Accent then Theme.Accent = fromArray(decoded.Accent) end

        applyTheme()
        notify("Theme loadet.")
    end

    -- Apply theme to UI
    function applyTheme()
        -- main background
        mainFrame.BackgroundColor3 = Theme.Background

        -- tab buttons
        for _, btn in ipairs(tabs) do
            btn.BackgroundColor3 = Theme.Buttons
            btn.TextColor3 = Theme.Text
        end

        -- content buttons and labels
        for _, frame in ipairs(tabFrames) do
            for _, child in ipairs(frame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Theme.Buttons
                    child.TextColor3 = Theme.Text
                elseif child:IsA("TextLabel") then
                    child.TextColor3 = Theme.Text
                elseif child:IsA("Frame") then
                    -- optional: nested styling
                end
            end
        end

        -- avatar holder (if exists)
        local av = mainFrame:FindFirstChild("AvatarHolder")
        if av then
            av.BackgroundColor3 = Theme.Background:lerp(Color3.fromRGB(20,20,25), 0.15)
            local nameLabel = av:FindFirstChild("NameLabel")
            if nameLabel then nameLabel.TextColor3 = Theme.Text end
        end
    end

    -- Utility: convert Color3 to 0..1 array
    local function colorToArray(c)
        return {c.R, c.G, c.B}
    end

    -- ========== RGB Color Picker Component ==========
    local function createRGBPicker(parent, title, defaultColor, onChange)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 120)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.Position = UDim2.new(0, 0, 0, 0)
        container.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        container.Parent = frame
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -12, 0, 20)
        titleLabel.Position = UDim2.new(0, 6, 0, 6)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Text = title
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextColor3 = Theme.Text
        titleLabel.Parent = container

        -- preview box
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 48, 0, 32)
        preview.Position = UDim2.new(1, -56, 0, 6)
        preview.BackgroundColor3 = defaultColor
        preview.Parent = container
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

        local sliders = {}

        local function makeSlider(name, index, startValue)
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1, -12, 0, 22)
            slider.Position = UDim2.new(0, 6, 0, 34 + (index * 28))
            slider.BackgroundTransparency = 1
            slider.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 26, 1, 0)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.Text = name
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextColor3 = Theme.Text
            label.BackgroundTransparency = 1
            label.Parent = slider

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -40, 0, 8)
            bar.Position = UDim2.new(0, 34, 0.5, -4)
            bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
            bar.Parent = slider
            Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(startValue/255, 1)
            fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 36, 1, 0)
            valueLabel.Position = UDim2.new(1, -36, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(startValue)
            valueLabel.TextColor3 = Theme.Text
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 14
            valueLabel.Parent = slider

            sliders[name] = {
                bar = bar,
                fill = fill,
                valueLabel = valueLabel,
                value = startValue
            }
        end

        local r = math.floor(defaultColor.R * 255)
        local g = math.floor(defaultColor.G * 255)
        local b = math.floor(defaultColor.B * 255)

        makeSlider("R", 0, r)
        makeSlider("G", 1, g)
        makeSlider("B", 2, b)

        local dragging = nil

        -- Update preview and call callback
        local function updateFromSliders()
            local col = Color3.fromRGB(sliders.R.value, sliders.G.value, sliders.B.value)
            preview.BackgroundColor3 = col
            if onChange then
                pcall(onChange, col)
            end
        end

        -- Mouse interactions
        for name, s in pairs(sliders) do
            s.bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = s
                end
            end)
            s.bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = nil
                end
            end)
        end

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = nil
            end
        end)

        RunService.RenderStepped:Connect(function()
            if dragging then
                local bar = dragging.bar
                local mouse = UserInputService:GetMouseLocation()
                -- Convert from screen coordinates to bar local coordinates
                local absPos = bar.AbsolutePosition
                local absSize = bar.AbsoluteSize
                local x = mouse.X - absPos.X
                local pos = math.clamp(x / absSize.X, 0, 1)
                dragging.value = math.floor(pos * 255)
                dragging.fill.Size = UDim2.fromScale(pos, 1)
                dragging.valueLabel.Text = tostring(dragging.value)
                updateFromSliders()
            end
        end)

        -- initial update
        sliders.R.fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
        sliders.G.fill.BackgroundColor3 = Color3.fromRGB(0,255,0)
        sliders.B.fill.BackgroundColor3 = Color3.fromRGB(0,0,255)
        updateFromSliders()

        return frame
    end

    -- ========== SETTINGS TAB CONTENT ==========
    local settingsFrame = tabFrames[5]

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "Settings / Theme"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Theme.Text
    title.Parent = settingsFrame

    -- Color pickers
    createRGBPicker(settingsFrame, "BackGround", Theme.Background, function(c)
        Theme.Background = c
        applyTheme()
    end)

    createRGBPicker(settingsFrame, "Text", Theme.Text, function(c)
        Theme.Text = c
        applyTheme()
    end)

    createRGBPicker(settingsFrame, "Button", Theme.Buttons, function(c)
        Theme.Buttons = c
        applyTheme()
    end)

    -- Accent picker
    createRGBPicker(settingsFrame, "Akzent", Theme.Accent, function(c)
        Theme.Accent = c
        applyTheme()
    end)

    -- Save / Load Buttons container
    local saveLoadFrame = Instance.new("Frame")
    saveLoadFrame.Size = UDim2.new(1, -10, 0, 52)
    saveLoadFrame.BackgroundTransparency = 1
    saveLoadFrame.Parent = settingsFrame

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
    saveBtn.Position = UDim2.new(0, 5, 0, 6)
    saveBtn.BackgroundColor3 = Theme.Buttons
    saveBtn.TextColor3 = Theme.Text
    saveBtn.Text = "Save Theme"
    saveBtn.Font = Enum.Font.GothamSemibold
    saveBtn.TextSize = 16
    saveBtn.Parent = saveLoadFrame
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    saveBtn.MouseButton1Click:Connect(saveTheme)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.48, 0, 1, 0)
    loadBtn.Position = UDim2.new(0.52, -5, 0, 6)
    loadBtn.BackgroundColor3 = Theme.Buttons
    loadBtn.TextColor3 = Theme.Text
    loadBtn.Text = "Load Theme"
    loadBtn.Font = Enum.Font.GothamSemibold
    loadBtn.TextSize = 16
    loadBtn.Parent = saveLoadFrame
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 8)
    loadBtn.MouseButton1Click:Connect(loadTheme)

    -- Quick presets
    local presetsFrame = Instance.new("Frame")
    presetsFrame.Size = UDim2.new(1, -10, 0, 36)
    presetsFrame.BackgroundTransparency = 1
    presetsFrame.Parent = settingsFrame

    local preset1 = Instance.new("TextButton")
    preset1.Size = UDim2.new(0.32, 0, 1, 0)
    preset1.Position = UDim2.new(0, 5, 0, 6)
    preset1.Text = "Dark"
    preset1.Font = Enum.Font.Gotham
    preset1.TextSize = 14
    preset1.BackgroundColor3 = Theme.Buttons
    preset1.TextColor3 = Theme.Text
    preset1.Parent = presetsFrame
    Instance.new("UICorner", preset1).CornerRadius = UDim.new(0,6)
    preset1.MouseButton1Click:Connect(function()
        Theme.Background = Color3.fromRGB(30,30,35)
        Theme.Text = Color3.fromRGB(235,235,240)
        Theme.Buttons = Color3.fromRGB(50,50,55)
        Theme.Accent = Color3.fromRGB(100,100,255)
        applyTheme()
    end)

    local preset2 = Instance.new("TextButton")
    preset2.Size = UDim2.new(0.32, 0, 1, 0)
    preset2.Position = UDim2.new(0.34, 0, 0, 6)
    preset2.Text = "Light"
    preset2.Font = Enum.Font.Gotham
    preset2.TextSize = 14
    preset2.BackgroundColor3 = Theme.Buttons
    preset2.TextColor3 = Theme.Text
    preset2.Parent = presetsFrame
    Instance.new("UICorner", preset2).CornerRadius = UDim.new(0,6)
    preset2.MouseButton1Click:Connect(function()
        Theme.Background = Color3.fromRGB(240,240,245)
        Theme.Text = Color3.fromRGB(20,20,25)
        Theme.Buttons = Color3.fromRGB(220,220,225)
        Theme.Accent = Color3.fromRGB(80,120,255)
        applyTheme()
    end)

    local preset3 = Instance.new("TextButton")
    preset3.Size = UDim2.new(0.32, 0, 1, 0)
    preset3.Position = UDim2.new(0.68, 0, 0, 6)
    preset3.Text = "Purple"
    preset3.Font = Enum.Font.Gotham
    preset3.TextSize = 14
    preset3.BackgroundColor3 = Theme.Buttons
    preset3.TextColor3 = Theme.Text
    preset3.Parent = presetsFrame
    Instance.new("UICorner", preset3).CornerRadius = UDim.new(0,6)
    preset3.MouseButton1Click:Connect(function()
        Theme.Background = Color3.fromRGB(28, 24, 40)
        Theme.Text = Color3.fromRGB(240,240,250)
        Theme.Buttons = Color3.fromRGB(45, 40, 55)
        Theme.Accent = Color3.fromRGB(180/255,100/255,255/255)
        applyTheme()
    end)

    -- ========== AVATAR PANEL (unter dem GUI, angehängt) ==========
    local avatarHolder = Instance.new("Frame")
    avatarHolder.Name = "AvatarHolder"
    avatarHolder.Size = UDim2.new(1, 0, 0, 78)
    avatarHolder.Position = UDim2.new(0, 0, 1, -78) -- attached at bottom of mainFrame
    avatarHolder.BackgroundColor3 = Color3.fromRGB(25,25,30)
    avatarHolder.BorderSizePixel = 0
    avatarHolder.Parent = mainFrame

    local avatarCorner = Instance.new("UICorner", avatarHolder)
    avatarCorner.CornerRadius = UDim.new(0, 12)

    -- Avatar image
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 60, 0, 60)
    avatarImg.Position = UDim2.new(0, 12, 0, 9)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Parent = avatarHolder
    local successThumb, thumbUrl = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if successThumb and thumbUrl then
        avatarImg.Image = thumbUrl
    else
        avatarImg.Image = ""
    end
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 30)

    -- player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -90, 0, 28)
    nameLabel.Position = UDim2.new(0, 82, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = LocalPlayer.Name or "Player"
    nameLabel.TextColor3 = Theme.Text
    nameLabel.Parent = avatarHolder

    -- small subtext (e.g., Local Player)
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, -90, 0, 20)
    subLabel.Position = UDim2.new(0, 82, 0, 36)
    subLabel.BackgroundTransparency = 1
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 14
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextColor3 = Theme.Text
    subLabel.Text = "local player"
    subLabel.Parent = avatarHolder

    -- Ensure the avatarHolder moves with mainFrame when dragged: because it's a child, Position is relative - we anchored it to bottom already.

    -- Finalize: apply theme and activate first tab
    applyTheme()
    activateTab(1)

    return screenGui
end

-- create GUI and store reference
local myGUI = createGUI()

-- Toggle function
local function toggleGUI()
    if myGUI.Enabled then
        -- Closing GUI: just fade out smoothly
        local closeTween = TweenService:Create(
            myGUI.MainFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            myGUI.Enabled = false
            -- reset size and position for next open
            myGUI.MainFrame.Size = UDim2.new(0, 520, 0, 420)
            myGUI.MainFrame.Position = UDim2.new(0.25, 0, 0.18, 0)
            myGUI.MainFrame.BackgroundTransparency = 0
        end)
    else
        -- Opening GUI
        myGUI.Enabled = true
        local frame = myGUI.MainFrame

        -- Initial small size, invisible
        frame.Size = UDim2.new(0, 350, 0, 280)
        frame.Position = UDim2.new(0.5, -175, 0.5, -140)
        frame.BackgroundTransparency = 1

        -- Fade + bounce + shake sequence
        local tween1 = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 540, 0, 440), Position = UDim2.new(0.245, 0, 0.17, 0), BackgroundTransparency = 0})
        local tween2 = TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 420), Position = UDim2.new(0.25, 0, 0.18, 0)})

        tween1:Play()
        tween1.Completed:Connect(function()
            tween2:Play()
        end)
    end
end

-- Alt hotkey toggles the GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
        toggleGUI()
    end
end)

-- END OF SCRIPT
