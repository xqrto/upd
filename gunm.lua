-- Scope + Flashlight GUI mit dynamischem FOV
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GunMods (xqrto)"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.7,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "GunMods"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- Minimize / Reopen
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,25,0,25)
minimize.Position = UDim2.new(1,-30,0,5)
minimize.BackgroundColor3 = Color3.fromRGB(180,0,0)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Text = "_"
minimize.Parent = frame

local reopenCircle = Instance.new("Frame")
reopenCircle.Size = UDim2.new(0, 40, 0, 40)
reopenCircle.Position = UDim2.new(0.7,0,0.5,0)
reopenCircle.BackgroundColor3 = Color3.fromRGB(0,0,0)
reopenCircle.Visible = false
reopenCircle.Active = true
reopenCircle.Draggable = true
reopenCircle.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = reopenCircle

local labelG = Instance.new("TextLabel")
labelG.Size = UDim2.new(1,0,1,0)
labelG.BackgroundTransparency = 1
labelG.Text = "G"
labelG.Font = Enum.Font.SourceSansBold
labelG.TextColor3 = Color3.new(1,1,1)
labelG.TextScaled = true
labelG.Parent = reopenCircle

minimize.MouseButton1Click:Connect(function()
	frame.Visible = false
	reopenCircle.Visible = true
end)

local lastClick = 0
reopenCircle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local t = tick()
		if t - lastClick < 0.25 then
			frame.Visible = true
			reopenCircle.Visible = false
		end
		lastClick = t
	end
end)

-- ===== Buttons =====
local flashBtn = Instance.new("TextButton")
flashBtn.Size = UDim2.new(0,200,0,30)
flashBtn.Position = UDim2.new(0,10,0,50)
flashBtn.Text = "Flashlight: OFF"
flashBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
flashBtn.TextColor3 = Color3.new(1,1,1)
flashBtn.Parent = frame

local scopeBtn = Instance.new("TextButton")
scopeBtn.Size = UDim2.new(0,200,0,30)
scopeBtn.Position = UDim2.new(0,10,0,90)
scopeBtn.Text = "Scope: OFF"
scopeBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
scopeBtn.TextColor3 = Color3.new(1,1,1)
scopeBtn.Parent = frame

-- ===== States =====
local flashlightEnabled = false
local scopeEnabled = false
local zoomFOV = 40
local originalFOV = Camera.FieldOfView -- Dynamisch speichern

flashBtn.MouseButton1Click:Connect(function()
	flashlightEnabled = not flashlightEnabled
	flashBtn.Text = "Flashlight: "..(flashlightEnabled and "ON" or "OFF")
end)

scopeBtn.MouseButton1Click:Connect(function()
	scopeEnabled = not scopeEnabled
	scopeBtn.Text = "Scope: "..(scopeEnabled and "ON" or "OFF")
end)

-- ===== Flashlight setup =====
local flashPart = Instance.new("Part")
flashPart.Size = Vector3.new(0.2,0.2,0.2)
flashPart.Anchored = true
flashPart.CanCollide = false
flashPart.Transparency = 1
flashPart.Parent = Workspace

local flashLight = Instance.new("SpotLight")
flashLight.Brightness = 2
flashLight.Angle = 50
flashLight.Range = 60
flashLight.Face = Enum.NormalId.Front
flashLight.Parent = flashPart

-- ===== Helper: get tool =====
local function getTool()
	local char = player.Character
	if not char then return nil end
	for _,t in pairs(char:GetChildren()) do
		if t:IsA("Tool") then return t end
	end
	return nil
end

-- ===== Update loop =====
RunService.RenderStepped:Connect(function()
	originalFOV = Camera.FieldOfView -- immer dynamisch speichern
	local tool = getTool()
	if tool then
		local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
		if handle then
			local mouseHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

			-- Flashlight
			if flashlightEnabled and mouseHeld then
				flashPart.CFrame = CFrame.new(handle.Position, handle.Position + Camera.CFrame.LookVector*10)
				flashLight.Enabled = true
			else
				flashLight.Enabled = false
			end

			-- Scope Zoom
			if scopeEnabled and mouseHeld then
				Camera.FieldOfView = zoomFOV
			else
				Camera.FieldOfView = originalFOV
			end
		else
			flashLight.Enabled = false
			Camera.FieldOfView = originalFOV
		end
	else
		flashLight.Enabled = false
		Camera.FieldOfView = originalFOV
	end
end)
