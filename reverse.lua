-- XQRTO REVERSE GUI SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local RECORD_INTERVAL = 0.03
local MAX_RECORD = 300
local recording = {}
local isRecording = false
local isReversing = false
local conn

-- GUI
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,250,0,150)
main.Position = UDim2.new(0.5,-125,0.5,-75)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true

-- TITLE BAR
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-30,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "XQRTO REVERSE"
title.Font = Enum.Font.Code
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0,255,180)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,30,1,0)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.Code
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(90,20,20)
closeBtn.TextColor3 = Color3.new(1,1,1)

closeBtn.MouseButton1Click:Connect(function()
	if conn then conn:Disconnect() conn = nil end
	gui:Destroy()
end)

-- DRAGGING
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
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

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Buttons
local saveBtn = Instance.new("TextButton", main)
saveBtn.Size = UDim2.new(0,100,0,40)
saveBtn.Position = UDim2.new(0,10,0,50)
saveBtn.Text = "SAVE"
saveBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
saveBtn.TextColor3 = Color3.new(1,1,1)

local reverseBtn = Instance.new("TextButton", main)
reverseBtn.Size = UDim2.new(0,100,0,40)
reverseBtn.Position = UDim2.new(0,130,0,50)
reverseBtn.Text = "REVERSE"
reverseBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
reverseBtn.TextColor3 = Color3.new(1,1,1)

local stopBtn = Instance.new("TextButton", main)
stopBtn.Size = UDim2.new(0,220,0,40)
stopBtn.Position = UDim2.new(0,10,0,100)
stopBtn.Text = "STOP"
stopBtn.BackgroundColor3 = Color3.fromRGB(180,30,30)
stopBtn.TextColor3 = Color3.new(1,1,1)

-- FUNCTIONS
local function startRecording()
	recording = {}
	isRecording = true
	isReversing = false
	if conn then conn:Disconnect() conn = nil end

	conn = RunService.RenderStepped:Connect(function(dt)
		if not isRecording then return end
		local char = LP.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local hrp = char.HumanoidRootPart
			table.insert(recording, {CFrame = hrp.CFrame})
			if #recording > MAX_RECORD then
				table.remove(recording,1)
			end
		end
	end)
end

local function reverseMovement()
	if #recording == 0 then return end
	isRecording = false
	isReversing = true
	if conn then conn:Disconnect() conn = nil end

	conn = RunService.RenderStepped:Connect(function(dt)
		if #recording == 0 then
			isReversing = false
			conn:Disconnect()
			conn = nil
			return
		end
		local char = LP.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local hrp = char.HumanoidRootPart
			local last = table.remove(recording)
			hrp.CFrame = last.CFrame
		end
	end)
end

local function stop()
	isRecording = false
	isReversing = false
	if conn then conn:Disconnect() conn = nil end
end

-- BUTTON EVENTS
saveBtn.MouseButton1Click:Connect(startRecording)
reverseBtn.MouseButton1Click:Connect(reverseMovement)
stopBtn.MouseButton1Click:Connect(stop)
