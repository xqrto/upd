 -- COMPLETE SCRIPT: ScriptHub + Settings + Avatar + Lua Executor
-- Hinweis: versucht writefile(), fallback PlayerGui StringValue für Theme

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

task.delay(5, function() notify("Press (ALT) to open the Menu") end)

-- Execute remote script
local function executeScriptFromURL(url)
    local success, scriptCode = pcall(function() return game:HttpGet(url) end)
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

-- GUI Creation
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XQRTO_ScriptHub"
    screenGui.Parent = PlayerGui
    screenGui.Enabled = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 420)
    mainFrame.Position = UDim2.new(0.25, 0, 0.18, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0,12)
    mainCorner.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50,50,55)
    titleBar.Position = UDim2.new(0,0,0,0)
    titleBar.Parent = mainFrame
    titleBar.Active = true
    titleBar.Draggable = true

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-10,1,0)
    titleLabel.Position = UDim2.new(0,5,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "X-ScriptHub"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Parent = titleBar

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0,12)
    titleCorner.Parent = titleBar

    -- Tabs
    local tabNames = {"xqrto","Mods","Items","Extras","Settings"}
    local tabs = {}
    local tabButtonsParent = Instance.new("Frame")
    tabButtonsParent.Size = UDim2.new(1,0,0,34)
    tabButtonsParent.BackgroundTransparency = 1
    tabButtonsParent.Parent = mainFrame

    local function createTabButton(name,index)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/#tabNames,0,1,0)
        btn.Position = UDim2.new((index-1)/#tabNames,0,0,0)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = tabButtonsParent
        return btn
    end

    for i,name in ipairs(tabNames) do tabs[i] = createTabButton(name,i) end

    local function createTabFrame(yOffset)
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1,-20,1,-80)
        frame.Position = UDim2.new(0,10,0,yOffset)
        frame.BackgroundTransparency = 1
        frame.ScrollBarThickness = 8
        frame.Visible = false
        frame.Parent = mainFrame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,8)
        layout.Parent = frame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+12)
        end)

        return frame
    end

    local tabFrames = {createTabFrame(44), createTabFrame(44), createTabFrame(44), createTabFrame(44), createTabFrame(44)}

    local function activateTab(index)
        for i,frame in ipairs(tabFrames) do frame.Visible = (i==index) end
        for i,btn in ipairs(tabs) do
            btn.BackgroundColor3 = (i==index) and Color3.fromRGB(85,85,95) or Color3.fromRGB(50,50,55)
        end
    end

    for i,btn in ipairs(tabs) do
        btn.MouseButton1Click:Connect(function() activateTab(i) end)
    end

    -----------------------
    -- TAB 1: Lua Executor
    -----------------------
    do
        local parent = tabFrames[1]
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,0,0,28)
        title.BackgroundTransparency = 1
        title.Text = "Lua Executor"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 20
        title.TextColor3 = Color3.fromRGB(235,235,240)
        title.Parent = parent

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1,-10,0,260)
        box.Position = UDim2.new(0,5,0,34)
        box.BackgroundColor3 = Color3.fromRGB(40,40,45)
        box.TextColor3 = Color3.fromRGB(235,235,240)
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Font = Enum.Font.Code
        box.TextSize = 16
        box.MultiLine = true
        box.Text = "-- write lua code here"
        box.Parent = parent
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,8)

        local runBtn = Instance.new("TextButton")
        runBtn.Size = UDim2.new(1,-10,0,46)
        runBtn.Position = UDim2.new(0,5,0,300)
        runBtn.BackgroundColor3 = Color3.fromRGB(50,50,55)
        runBtn.TextColor3 = Color3.fromRGB(235,235,240)
        runBtn.Font = Enum.Font.GothamBold
        runBtn.TextSize = 18
        runBtn.Text = "RUN"
        runBtn.Parent = parent
        Instance.new("UICorner",runBtn).CornerRadius=UDim.new(0,8)

        runBtn.MouseButton1Click:Connect(function()
            local code = box.Text
            if code=="" then return notify("No code to execute.") end
            local fn,err = loadstring(code)
            if not fn then return notify("Error: "..tostring(err)) end
            screenGui.Enabled=false
            task.spawn(function()
                local ok,res = pcall(fn)
                if not ok then notify("Runtime error: "..tostring(res)) end
            end)
        end)
    end

    -----------------------
    -- TAB 2-4: Scripts (unverändert)
    -----------------------
    local scriptButtons = {
        {name="AimBot",url="https://raw.githubusercontent.com/xqrto/upd/main/fefrwdeu.lua"},
        {name="AimBot-old",url="https://raw.githubusercontent.com/xqrto/upd/main/Aimbotvone.lua"},
        {name="Gun-Mods",url="https://raw.githubusercontent.com/xqrto/upd/main/gunm.lua"},
        {name="NoClip",url="https://raw.githubusercontent.com/xqrto/upd/main/noclip.lua"},
        {name="FreeCam",url="https://raw.githubusercontent.com/xqrto/upd/main/freecam.lua"},
        {name="Fly",url="https://raw.githubusercontent.com/xqrto/upd/main/fly.lua"},
        {name="Tracer",url="https://raw.githubusercontent.com/xqrto/upd/main/tracer.lua"}
    }
    local ItemButtons = {
        {name="Telikinesis",url="https://raw.githubusercontent.com/xqrto/upd/main/telikinesis.lua"}
    }
    local CcosmeticButtons = {
        {name="fling",url="https://raw.githubusercontent.com/xqrto/upd/main/fling.lua"}
    }

    local function createButton(parent,text,callback)
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,46)
        btn.BackgroundColor3=Color3.fromRGB(50,50,55)
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.Font=Enum.Font.Gotham
        btn.TextSize=18
        btn.Text=text
        btn.Parent=parent
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(70,70,80) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3=Color3.fromRGB(50,50,55) end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    for _,b in ipairs(scriptButtons) do createButton(tabFrames[2],b.name,function() screenGui.Enabled=false; executeScriptFromURL(b.url) end) end
    for _,b in ipairs(ItemButtons) do createButton(tabFrames[3],b.name,function() screenGui.Enabled=false; executeScriptFromURL(b.url) end) end
    for _,b in ipairs(CcosmeticButtons) do createButton(tabFrames[4],b.name,function() screenGui.Enabled=false; executeScriptFromURL(b.url) end) end

    -----------------------
    -- TAB 5: SETTINGS + RGB + SAVE/LOAD + Presets
    -----------------------
    local settingsFrame = tabFrames[5]

    local Theme = {
        Background=mainFrame.BackgroundColor3,
        Text=Color3.fromRGB(235,235,240),
        Buttons=Color3.fromRGB(50,50,55),
        Accent=Color3.fromRGB(100,100,255)
    }

    local function applyTheme()
        mainFrame.BackgroundColor3=Theme.Background
        for _,btn in ipairs(tabs) do btn.BackgroundColor3=Theme.Buttons; btn.TextColor3=Theme.Text end
        for _,frame in ipairs(tabFrames) do
            for _,c in ipairs(frame:GetChildren()) do
                if c:IsA("TextButton") then c.BackgroundColor3=Theme.Buttons; c.TextColor3=Theme.Text
                elseif c:IsA("TextLabel") then c.TextColor3=Theme.Text end
            end
        end
    end

    local STORAGE_NAME="xqrto_theme.json"
    local function tryWriteFile(path,content) local ok,err=pcall(function() if writefile then writefile(path,content) else error("no writefile") end end) return ok,err end
    local function tryReadFile(path) local ok,content=pcall(function() if readfile then return readfile(path) else error("no readfile") end end) if ok then return content end return nil end

    local function saveTheme()
        local data=HttpService:JSONEncode({
            Background={Theme.Background.R,Theme.Background.G,Theme.Background.B},
            Text={Theme.Text.R,Theme.Text.G,Theme.Text.B},
            Buttons={Theme.Buttons.R,Theme.Buttons.G,Theme.Buttons.B},
            Accent={Theme.Accent.R,Theme.Accent.G,Theme.Accent.B}
        })
        local ok=tryWriteFile(STORAGE_NAME,data)
        if ok then notify("Theme saved.") return end
        local sv=PlayerGui:FindFirstChild("XQRTO_ThemeData")
        if not sv then sv=Instance.new("StringValue"); sv.Name="XQRTO_ThemeData"; sv.Parent=PlayerGui end
        sv.Value=data
        notify("Theme saved locally.")
    end

    local function loadTheme()
        local raw=tryReadFile(STORAGE_NAME)
        if not raw then local sv=PlayerGui:FindFirstChild("XQRTO_ThemeData"); if sv then raw=sv.Value end end
        if not raw then return notify("No theme found.") end
        local ok,decoded=pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or type(decoded)~="table" then return notify("Cant load theme.") end
        local function fromArray(a) return Color3.new(a[1],a[2],a[3]) end
        if decoded.Background then Theme.Background=fromArray(decoded.Background) end
        if decoded.Text then Theme.Text=fromArray(decoded.Text) end
        if decoded.Buttons then Theme.Buttons=fromArray(decoded.Buttons) end
        if decoded.Accent then Theme.Accent=fromArray(decoded.Accent) end
        applyTheme()
        notify("Theme loaded.")
    end

    -- RGB Picker helper (funktioniert wie im Original)
    local function createRGBPicker(parent,title,defaultColor,onChange)
        local frame=Instance.new("Frame")
        frame.Size=UDim2.new(1,-10,0,120)
        frame.BackgroundTransparency=1
        frame.Parent=parent

        local container=Instance.new("Frame")
        container.Size=UDim2.new(1,0,1,0)
        container.BackgroundColor3=Color3.fromRGB(40,40,45)
        container.Parent=frame
        container.BorderSizePixel=0
        Instance.new("UICorner",container).CornerRadius=UDim.new(0,8)

        local titleLabel=Instance.new("TextLabel")
        titleLabel.Size=UDim2.new(1,-12,0,20)
        titleLabel.Position=UDim2.new(0,6,0,6)
        titleLabel.BackgroundTransparency=1
        titleLabel.TextXAlignment=Enum.TextXAlignment.Left
        titleLabel.Text=title
        titleLabel.TextSize=16
        titleLabel.Font=Enum.Font.GothamSemibold
        titleLabel.TextColor3=Theme.Text
        titleLabel.Parent=container

        local preview=Instance.new("Frame")
        preview.Size=UDim2.new(0,48,0,32)
        preview.Position=UDim2.new(1,-56,0,6)
        preview.BackgroundColor3=defaultColor
        preview.Parent=container
        Instance.new("UICorner",preview).CornerRadius=UDim.new(0,6)

        local sliders={}
        local function makeSlider(name,index,startValue)
            local slider=Instance.new("Frame")
            slider.Size=UDim2.new(1,-12,0,22)
            slider.Position=UDim2.new(0,6,0,34+(index*28))
            slider.BackgroundTransparency=1
            slider.Parent=container

            local label=Instance.new("TextLabel")
            label.Size=UDim2.new(0,26,1,0)
            label.Position=UDim2.new(0,0,0,0)
            label.Text=name
            label.Font=Enum.Font.Gotham
            label.TextSize=14
            label.TextColor3=Theme.Text
            label.BackgroundTransparency=1
            label.Parent=slider

            local bar=Instance.new("Frame")
            bar.Size=UDim2.new(1,-40,0,8)
            bar.Position=UDim2.new(0,34,0.5,-4)
            bar.BackgroundColor3=Color3.fromRGB(70,70,70)
            bar.Parent=slider
            Instance.new("UICorner",bar).CornerRadius=UDim.new(0,8)

            local fill=Instance.new("Frame")
            fill.Size=UDim2.fromScale(startValue/255,1)
            fill.BackgroundColor3=(name=="R" and Color3.fromRGB(255,0,0) or name=="G" and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255))
            fill.Parent=bar
            Instance.new("UICorner",fill).CornerRadius=UDim.new(0,8)

            local valueLabel=Instance.new("TextLabel")
            valueLabel.Size=UDim2.new(0,36,1,0)
            valueLabel.Position=UDim2.new(1,-36,0,0)
            valueLabel.BackgroundTransparency=1
            valueLabel.Text=tostring(startValue)
            valueLabel.TextColor3=Theme.Text
            valueLabel.Font=Enum.Font.Gotham
            valueLabel.TextSize=14
            valueLabel.Parent=slider

            sliders[name]={bar=bar,fill=fill,valueLabel=valueLabel,value=startValue}
        end

        local r,g,b=math.floor(defaultColor.R*255),math.floor(defaultColor.G*255),math.floor(defaultColor.B*255)
        makeSlider("R",0,r)
        makeSlider("G",1,g)
        makeSlider("B",2,b)

        local dragging=nil
        local UIS=UserInputService
        for name,slider in pairs(sliders) do
            slider.fill.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=name end
            end)
        end

        UIS.InputChanged:Connect(function(input)
            if dragging then
                local slider=sliders[dragging]
                local bar=slider.bar
                local mouseX = math.clamp(UIS:GetMouseLocation().X-bar.AbsolutePosition.X,0,bar.AbsoluteSize.X)
                local val=math.floor(mouseX/bar.AbsoluteSize.X*255)
                slider.value=val
                slider.fill.Size=UDim2.fromScale(val/255,1)
                slider.valueLabel.Text=tostring(val)
                local r,g,b=sliders.R.value,sliders.G.value,sliders.B.value
                preview.BackgroundColor3=Color3.fromRGB(r,g,b)
                onChange(Color3.fromRGB(r,g,b))
            end
        end)

        UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end end)
    end

    -- Example RGB picker for Theme.Background
    createRGBPicker(settingsFrame,"Background Color",Theme.Background,function(c) Theme.Background=c; applyTheme() end)
    createRGBPicker(settingsFrame,"Text Color",Theme.Text,function(c) Theme.Text=c; applyTheme() end)
    createRGBPicker(settingsFrame,"Button Color",Theme.Buttons,function(c) Theme.Buttons=c; applyTheme() end)
    createRGBPicker(settingsFrame,"Accent Color",Theme.Accent,function(c) Theme.Accent=c; applyTheme() end)

    local saveBtn=Instance.new("TextButton")
    saveBtn.Size=UDim2.new(0.48,0,0,36)
    saveBtn.Position=UDim2.new(0,5,1,-46)
    saveBtn.Text="SAVE"
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextSize=16
    saveBtn.TextColor3=Color3.fromRGB(235,235,240)
    saveBtn.BackgroundColor3=Color3.fromRGB(50,50,55)
    saveBtn.Parent=settingsFrame
    Instance.new("UICorner",saveBtn).CornerRadius=UDim.new(0,6)
    saveBtn.MouseButton1Click:Connect(saveTheme)

    local loadBtn=Instance.new("TextButton")
    loadBtn.Size=UDim2.new(0.48,0,0,36)
    loadBtn.Position=UDim2.new(0.52,0,1,-46)
    loadBtn.Text="LOAD"
    loadBtn.Font=Enum.Font.GothamBold
    loadBtn.TextSize=16
    loadBtn.TextColor3=Color3.fromRGB(235,235,240)
    loadBtn.BackgroundColor3=Color3.fromRGB(50,50,55)
    loadBtn.Parent=settingsFrame
    Instance.new("UICorner",loadBtn).CornerRadius=UDim.new(0,6)
    loadBtn.MouseButton1Click:Connect(loadTheme)

    applyTheme()
    activateTab(1)
    return screenGui
end

local myGUI = createGUI()

-- Toggle GUI with Alt
local function toggleGUI()
    myGUI.Enabled = not myGUI.Enabled
end

UserInputService.InputBegan:Connect(function(input,gameProcessed)
    if gameProcessed then return end
    if input.KeyCode==Enum.KeyCode.LeftAlt or input.KeyCode==Enum.KeyCode.RightAlt then toggleGUI() end
end)

