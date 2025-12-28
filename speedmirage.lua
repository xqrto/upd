-- SUPERHERO MOVEMENT HUB v7 (CAMERA RELATIVE, RANGE+SPEED ADJUSTABLE, AFTERIMAGES)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- SETTINGS
local RANGE = 10
local BASE_SPEED = 60
local AFTERIMAGE_LIFETIME = 0.5

-- GUI
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,400,0,500)
main.Position = UDim2.new(0.5,-200,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0,10,0,0)
title.Text = "SUPERHERO HUB"
title.Font = Enum.Font.Code
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,255,180)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.Font = Enum.Font.Code
close.TextSize = 16
close.BackgroundColor3 = Color3.fromRGB(90,20,20)
close.TextColor3 = Color3.new(1,1,1)

-- CONTAINER
local container = Instance.new("Frame", main)
container.Position = UDim2.new(0,10,0,50)
container.Size = UDim2.new(1,-20,1,-60)
container.BackgroundTransparency = 1

-- Patterns Grid
local patternFrame = Instance.new("Frame", container)
patternFrame.Size = UDim2.new(1,0,0,200)
patternFrame.Position = UDim2.new(0,0,0,0)
patternFrame.BackgroundTransparency = 1

local patternLayout = Instance.new("UIGridLayout", patternFrame)
patternLayout.CellSize = UDim2.new(0,120,0,40)
patternLayout.CellPadding = UDim2.new(0,10,0,10)

-- Variables
local mode = nil
local enabled = false
local t = 0
local conn
local speed = BASE_SPEED

-- Afterimage
local function createAfterImage(hrp)
	local clone = hrp:Clone()
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 0.5
			part.Anchored = true
			part.CanCollide = false
			part.Material = Enum.Material.Neon
		end
	end
	clone.Parent = workspace
	game:GetService("Debris"):AddItem(clone, AFTERIMAGE_LIFETIME)
end

-- Stop function
local function stop()
	enabled = false
	if conn then conn:Disconnect() conn = nil end
end

-- Patterns
local patterns = {"SIDE","CIRCLE","SQUARE","TRIANGLE","PENTAGON","HEXAGON","STAR","INFINITY"}

local function start(selectedMode)
	stop()
	mode = selectedMode
	enabled = true
	t = 0

	conn = RunService.RenderStepped:Connect(function(dt)
		if not enabled then return end
		t += dt * speed
		local x, z = 0, 0

		if mode=="SIDE" then
			x = math.sin(t)*RANGE
		elseif mode=="CIRCLE" then
			x = math.cos(t)*RANGE
			z = math.sin(t)*RANGE
		elseif mode=="SQUARE" then
			local p=(t%4)
			if p<1 then x=RANGE z=(p*2-1)*RANGE
			elseif p<2 then x=(1-(p-1)*2)*RANGE z=RANGE
			elseif p<3 then x=-RANGE z=(1-(p-2)*2)*RANGE
			else x=((p-3)*2-1)*RANGE z=-RANGE end
		elseif mode=="TRIANGLE" then
			local p=(t%3)
			if p<1 then x=p*RANGE z=p*RANGE
			elseif p<2 then x=RANGE-(p-1)*RANGE*2 z=RANGE
			else x=-(p-2)*RANGE z=RANGE-(p-2)*RANGE end
		elseif mode=="PENTAGON" then
			local angle = t*math.pi*2/5
			x = math.cos(angle)*RANGE
			z = math.sin(angle)*RANGE
		elseif mode=="HEXAGON" then
			local angle = t*math.pi*2/6
			x = math.cos(angle)*RANGE
			z = math.sin(angle)*RANGE
		elseif mode=="STAR" then
			local angle = t*math.pi*4/5
			x = math.cos(angle)*RANGE
			z = math.sin(angle)*RANGE
		elseif mode=="INFINITY" then
			x = math.sin(t)*RANGE
			z = math.sin(t*2)*RANGE/2
		end

		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local cam = workspace.CurrentCamera
			local look = Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
			local right = Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
			if look.Magnitude>0 then look = look.Unit end
			if right.Magnitude>0 then right = right.Unit end
			local movePos = hrp.Position + right*x + look*z
			hrp.CFrame = CFrame.new(movePos)
			createAfterImage(hrp)
		end
	end)
end

-- Create pattern buttons
local function makeButton(text, modeName, parent)
	local b = Instance.new("TextButton", parent)
	b.Text = text
	b.Font = Enum.Font.Code
	b.TextSize = 14
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	b.MouseButton1Click:Connect(function() start(modeName) end)
end

for _,p in pairs(patterns) do
	makeButton(p,p,patternFrame)
end

-- Controls Frame
local controlFrame = Instance.new("Frame", container)
controlFrame.Position = UDim2.new(0,0,0,210)
controlFrame.Size = UDim2.new(1,0,0,120)
controlFrame.BackgroundTransparency = 1

-- Speed controls
local speedLabel = Instance.new("TextLabel", controlFrame)
speedLabel.Size = UDim2.new(0.6,0,0,30)
speedLabel.Position = UDim2.new(0,0,0,0)
speedLabel.Text = "Speed: "..speed
speedLabel.Font = Enum.Font.Code
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local minusBtn = Instance.new("TextButton", controlFrame)
minusBtn.Size = UDim2.new(0.15,0,0,30)
minusBtn.Position = UDim2.new(0.6,0,0,0)
minusBtn.Text = "-"
minusBtn.Font = Enum.Font.Code
minusBtn.TextSize = 18
minusBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minusBtn.TextColor3 = Color3.new(1,1,1)

local plusBtn = Instance.new("TextButton", controlFrame)
plusBtn.Size = UDim2.new(0.15,0,0,30)
plusBtn.Position = UDim2.new(0.75,0,0,0)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.Code
plusBtn.TextSize = 18
plusBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
plusBtn.TextColor3 = Color3.new(1,1,1)

minusBtn.MouseButton1Click:Connect(function()
	speed = math.clamp(speed-5,10,200)
	speedLabel.Text = "Speed: "..math.floor(speed)
end)
plusBtn.MouseButton1Click:Connect(function()
	speed = math.clamp(speed+5,10,200)
	speedLabel.Text = "Speed: "..math.floor(speed)
end)

-- Range controls
local rangeLabel = Instance.new("TextLabel", controlFrame)
rangeLabel.Size = UDim2.new(0.6,0,0,30)
rangeLabel.Position = UDim2.new(0,0,0,40)
rangeLabel.Text = "Range: "..RANGE
rangeLabel.Font = Enum.Font.Code
rangeLabel.TextSize = 14
rangeLabel.TextColor3 = Color3.new(1,1,1)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left

local rangeMinus = Instance.new("TextButton", controlFrame)
rangeMinus.Size = UDim2.new(0.15,0,0,30)
rangeMinus.Position = UDim2.new(0.6,0,0,40)
rangeMinus.Text = "-"
rangeMinus.Font = Enum.Font.Code
rangeMinus.TextSize = 16
rangeMinus.BackgroundColor3 = Color3.fromRGB(80,80,80)
rangeMinus.TextColor3 = Color3.new(1,1,1)

local rangePlus = Instance.new("TextButton", controlFrame)
rangePlus.Size = UDim2.new(0.15,0,0,30)
rangePlus.Position = UDim2.new(0.75,0,0,40)
rangePlus.Text = "+"
rangePlus.Font = Enum.Font.Code
rangePlus.TextSize = 16
rangePlus.BackgroundColor3 = Color3.fromRGB(80,80,80)
rangePlus.TextColor3 = Color3.new(1,1,1)

rangeMinus.MouseButton1Click:Connect(function()
	RANGE = math.clamp(RANGE-1,1,50)
	rangeLabel.Text = "Range: "..RANGE
end)
rangePlus.MouseButton1Click:Connect(function()
	RANGE = math.clamp(RANGE+1,1,50)
	rangeLabel.Text = "Range: "..RANGE
end)

-- STOP Button
local stopBtn = Instance.new("TextButton", container)
stopBtn.Size = UDim2.new(1,0,0,40)
stopBtn.Position = UDim2.new(0,0,0,350)
stopBtn.Text = "STOP"
stopBtn.Font = Enum.Font.Code
stopBtn.TextSize = 16
stopBtn.BackgroundColor3 = Color3.fromRGB(180,30,30)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.BorderSizePixel = 0
stopBtn.MouseButton1Click:Connect(stop)

-- Close
close.MouseButton1Click:Connect(function()
	stop()
	gui:Destroy()
end)

LP.CharacterAdded:Connect(stop)
