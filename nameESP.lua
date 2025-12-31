--// NAME ESP – GUI + DRAG + MINIMIZE + AUTO REFRESH

--================ SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--================ SETTINGS =================
local ESP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(0,255,0)
local ESP_SIZE = 14
local ESP_CACHE = {}

--================ ESP CORE =================
local function attachESP(player)
    if player == LP or ESP_CACHE[player] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0,200,0,40)
    billboard.StudsOffset = Vector3.new(0,3,0)

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = player.Name
    text.TextColor3 = ESP_COLOR
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = ESP_SIZE

    ESP_CACHE[player] = {gui=billboard,label=text}

    local function bind()
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            billboard.Parent = head
        end
    end

    bind()
    player.CharacterAdded:Connect(function()
        task.wait(1)
        bind()
    end)
end

local function removeESP(player)
    if ESP_CACHE[player] then
        ESP_CACHE[player].gui:Destroy()
        ESP_CACHE[player] = nil
    end
end

local function updateESP()
    for _,data in pairs(ESP_CACHE) do
        data.label.TextColor3 = ESP_COLOR
        data.label.TextSize = ESP_SIZE
    end
end

local function refreshESP()
    for _,p in ipairs(Players:GetPlayers()) do
        if ESP_ENABLED then
            attachESP(p)
        else
            removeESP(p)
        end
    end
end

--================ AUTO PLAYER REFRESH =================
Players.PlayerAdded:Connect(function(p)
    if ESP_ENABLED then
        task.wait(1)
        attachESP(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

-- FAILSAFE REFRESH (ALLE 5 SEK)
task.spawn(function()
    while true do
        task.wait(5)
        if ESP_ENABLED then
            refreshESP()
        end
    end
end)

--================ GUI =================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "NameESP_GUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,270,0,300)
main.Position = UDim2.new(0,20,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

--================ TITLE BAR =================
local title = Instance.new("Frame", main)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.BorderSizePixel = 0
Instance.new("UICorner", title)

local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1,-60,1,0)
titleText.Position = UDim2.new(0,10,0,0)
titleText.Text = "NAME ESP"
titleText.TextColor3 = Color3.new(1,1,1)
titleText.Font = Enum.Font.Code
titleText.TextSize = 18
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left

--================ MINIMIZE BUTTON =================
local minimized = false
local minBtn = Instance.new("TextButton", title)
minBtn.Size = UDim2.new(0,30,1,0)
minBtn.Position = UDim2.new(1,-30,0,0)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1

--================ CONTENT =================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,30)
content.Size = UDim2.new(1,0,1,-30)
content.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    minBtn.Text = minimized and "+" or "-"
    main.Size = minimized and UDim2.new(0,270,0,30) or UDim2.new(0,270,0,300)
end)

--================ DRAG (TITLE ONLY) =================
do
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--================ TOGGLE BUTTON =================
local toggle = Instance.new("TextButton", content)
toggle.Size = UDim2.new(1,-20,0,35)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "ESP : OFF"
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggle)

toggle.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    toggle.Text = ESP_ENABLED and "ESP : ON" or "ESP : OFF"
    toggle.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0,120,0) or Color3.fromRGB(120,0,0)
    refreshESP()
end)

--================ SLIDER =================
local function slider(text,y,min,max,value,callback)
    local label = Instance.new("TextLabel", content)
    label.Position = UDim2.new(0,10,0,y)
    label.Size = UDim2.new(1,-20,0,20)
    label.Text = text..": "..math.floor(value)
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code

    local bar = Instance.new("Frame", content)
    bar.Position = UDim2.new(0,10,0,y+22)
    bar.Size = UDim2.new(1,-20,0,6)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local pct = math.clamp(
                    (LP:GetMouse().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                    0,1
                )
                fill.Size = UDim2.new(pct,0,1,0)
                local val = min + (max-min)*pct
                label.Text = text..": "..math.floor(val)
                callback(val)
            end)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    conn:Disconnect()
                end
            end)
        end
    end)
end

--================ SLIDERS =================
slider("Text Size",60,10,30,ESP_SIZE,function(v)
    ESP_SIZE = math.floor(v)
    updateESP()
end)

slider("Red",110,0,255,ESP_COLOR.R*255,function(v)
    ESP_COLOR = Color3.fromRGB(v,ESP_COLOR.G*255,ESP_COLOR.B*255)
    updateESP()
end)

slider("Green",160,0,255,ESP_COLOR.G*255,function(v)
    ESP_COLOR = Color3.fromRGB(ESP_COLOR.R*255,v,ESP_COLOR.B*255)
    updateESP()
end)

slider("Blue",210,0,255,ESP_COLOR.B*255,function(v)
    ESP_COLOR = Color3.fromRGB(ESP_COLOR.R*255,ESP_COLOR.G*255,v)
    updateESP()
end)
