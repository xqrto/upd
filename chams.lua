-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerEffects = {}
local rainbowEnabled = false
local auraActive = true
local currentHue = 0
local globalColor = Color3.fromRGB(255, 0, 0)

-- 1. CLEANUP (Alte Instanzen löschen)
for _, oldGui in ipairs(localPlayer.PlayerGui:GetChildren()) do
	if oldGui.Name == "AuraControlFinal" then oldGui:Destroy() end
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	if otherPlayer.Character then
		local oldAura = otherPlayer.Character:FindFirstChild("AuraEffect")
		if oldAura then oldAura:Destroy() end
	end
end

-- FUNKTION: AURA ERSTELLEN
local function applyEffects(player)
	if player == localPlayer then return end

	local function setupChar(char)
		if not char or not auraActive then return end
		
		-- Falls schon eine Aura existiert, löschen
		local existing = char:FindFirstChild("AuraEffect")
		if existing then existing:Destroy() end
		
		local aura = Instance.new("Highlight")
		aura.Name = "AuraEffect"
		aura.FillTransparency = 0.8
		aura.OutlineColor = globalColor
		aura.OutlineTransparency = 0
		aura.Parent = char
		
		playerEffects[player.UserId] = aura
	end

	player.CharacterAdded:Connect(setupChar)
	if player.Character then setupChar(player.Character) end
end

-- INITIALISIERUNG
for _, p in ipairs(Players:GetPlayers()) do applyEffects(p) end
Players.PlayerAdded:Connect(applyEffects)

-- ANIMATION LOOP
RunService.RenderStepped:Connect(function(dt)
	if rainbowEnabled then
		currentHue = (currentHue + dt * 0.2) % 1
		globalColor = Color3.fromHSV(currentHue, 1, 1)
	end
	
	local pulse = 0.2 + (math.sin(tick() * 5) * 0.2)
	
	for userId, aura in pairs(playerEffects) do
		if aura and aura.Parent then
			aura.OutlineColor = globalColor
			aura.OutlineTransparency = auraActive and pulse or 1
		else
			playerEffects[userId] = nil
		end
	end
end)

-- GUI SETUP
local sg = Instance.new("ScreenGui", localPlayer.PlayerGui)
sg.Name = "AuraControlFinal"
sg.ResetOnSpawn = false -- WICHTIG: GUI bleibt nach Tod

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 250, 0, 180)
main.Position = UDim2.new(0.5, -125, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.ClipsDescendants = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "  ESP-Utl (xqrto)"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- DRAG LOGIC
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
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- BUTTONS OBEN RECHTS (X und -)
local xBtn = Instance.new("TextButton", title)
xBtn.Size = UDim2.new(0, 35, 0, 35)
xBtn.Position = UDim2.new(1, -35, 0, 0)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)

local minBtn = Instance.new("TextButton", title)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -70, 0, 0)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.TextColor3 = Color3.new(1,1,1)

-- ON/OFF BUTTON
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 45)
toggleBtn.Text = "ESP: ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
toggleBtn.TextColor3 = Color3.new(1,1,1)

toggleBtn.MouseButton1Click:Connect(function()
	auraActive = not auraActive
	toggleBtn.Text = "ESP: " .. (auraActive and "ON" or "OFF")
	toggleBtn.BackgroundColor3 = auraActive and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(80, 40, 40)
	for _, aura in pairs(playerEffects) do
		aura.Enabled = auraActive
	end
end)

-- RAINBOW BUTTON
local rbBtn = Instance.new("TextButton", main)
rbBtn.Size = UDim2.new(0.8, 0, 0, 30)
rbBtn.Position = UDim2.new(0.1, 0, 0, 85)
rbBtn.Text = "Rainbow: OFF"
rbBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
rbBtn.TextColor3 = Color3.new(1,1,1)

rbBtn.MouseButton1Click:Connect(function()
	rainbowEnabled = not rainbowEnabled
	rbBtn.Text = "Rainbow: " .. (rainbowEnabled and "ON" or "OFF")
end)

-- COLOR SLIDER
local colorSlider = Instance.new("Frame", main)
colorSlider.Size = UDim2.new(0.8, 0, 0, 10)
colorSlider.Position = UDim2.new(0.1, 0, 0, 140)
local colorKnob = Instance.new("TextButton", colorSlider)
colorKnob.Size = UDim2.new(0, 15, 0, 20)
colorKnob.Position = UDim2.new(0, 0, 0.5, -10)
colorKnob.Text = ""

colorKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local moveCon, endCon
		moveCon = UserInputService.InputChanged:Connect(function(m)
			if m.UserInputType == Enum.UserInputType.MouseMovement then
				local p = math.clamp((m.Position.X - colorSlider.AbsolutePosition.X) / colorSlider.AbsoluteSize.X, 0, 1)
				colorKnob.Position = UDim2.new(p, -7, 0.5, -10)
				if not rainbowEnabled then globalColor = Color3.fromHSV(p, 1, 1) end
			end
		end)
		endCon = UserInputService.InputEnded:Connect(function(e)
			if e.UserInputType == Enum.UserInputType.MouseButton1 then moveCon:Disconnect(); endCon:Disconnect() end
		end)
	end
end)

-- MINIMIEREN LOGIK
local isMin = false
minBtn.MouseButton1Click:Connect(function()
	isMin = not isMin
	main:TweenSize(isMin and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 180), "Out", "Quad", 0.3, true)
end)

-- X-BUTTON LOGIK (Löscht alles)
xBtn.MouseButton1Click:Connect(function()
	for _, aura in pairs(playerEffects) do if aura then aura:Destroy() end end
	sg:Destroy()
end)
