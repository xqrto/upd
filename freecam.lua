--// FULL FREECAM SYSTEM WITH MOUSELOOK + KEYBINDS + HIDE GUI + REOPEN CIRCLE
--// By ChatGPT

---------------------------------------------------------
-------------------- SETTINGS ---------------------------
---------------------------------------------------------

local keybinds = {
	ToggleFreecam = Enum.KeyCode.F4,
	Teleport = Enum.KeyCode.F5,
	Forward = Enum.KeyCode.W,
	Backward = Enum.KeyCode.S,
	Left = Enum.KeyCode.A,
	Right = Enum.KeyCode.D,
	Up = Enum.KeyCode.E,
	Down = Enum.KeyCode.Q
}

local freecamSpeed = 1.6
local mouseSensitivity = 0.15


---------------------------------------------------------
-------------------- SERVICES ---------------------------
---------------------------------------------------------

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = player:GetMouse()


---------------------------------------------------------
-------------------- GUI SETUP --------------------------
---------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "FreecamGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 280)
frame.Position = UDim2.new(0.72, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "FREECAM PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BackgroundTransparency = 1
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0, 30)
status.Text = "Freecam: OFF"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.Parent = frame


---------------------------------------------------------
-------------------- KEYBIND BUTTONS ---------------------
---------------------------------------------------------

local bindLabels = {}
local order = {"ToggleFreecam", "Teleport"}
local y = 70

for _, name in ipairs(order) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 26)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = name .. ": " .. keybinds[name].Name
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = frame
	bindLabels[name] = btn

	y += 30

	btn.MouseButton1Click:Connect(function()
		btn.Text = name .. ": ..."
		local connection
		connection = UIS.InputBegan:Connect(function(input, gp)
			if not gp and input.KeyCode ~= Enum.KeyCode.Unknown then
				keybinds[name] = input.KeyCode
				btn.Text = name .. ": " .. input.KeyCode.Name
				connection:Disconnect()
			end
		end)
	end)
end


---------------------------------------------------------
-------------------- GUI CLOSE BUTTON --------------------
---------------------------------------------------------

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Text = "X"
closeBtn.Parent = frame

local reopenCircle = Instance.new("Frame")
reopenCircle.Size = UDim2.new(0, 42, 0, 42)
reopenCircle.Position = UDim2.new(0.75, 0, 0.6, 0)
reopenCircle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
reopenCircle.Active = true
reopenCircle.Visible = false
reopenCircle.Draggable = true
reopenCircle.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = reopenCircle

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

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	reopenCircle.Visible = true
end)


---------------------------------------------------------
-------------------- FREECAM CORE ------------------------
---------------------------------------------------------

local freecamActive = false
local rotation = Vector2.new()
local frozenHRP = nil


local function toggleFreecam(state)
	freecamActive = state

	if state then
		status.Text = "Freecam: ON"
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				frozenHRP = hrp
				hrp.Anchored = true
			end
		end

		Camera.CameraType = Enum.CameraType.Scriptable
		rotation = Vector2.new()
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		UIS.MouseIconEnabled = false

	else
		status.Text = "Freecam: OFF"
		if frozenHRP then
			frozenHRP.Anchored = false
		end

		Camera.CameraType = Enum.CameraType.Custom
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = true
	end
end


local function teleportToCam()
	if not freecamActive then return end
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = Camera.CFrame
	end
	toggleFreecam(false)
end


---------------------------------------------------------
-------------------- CAMERA MOVEMENT ---------------------
---------------------------------------------------------

RunService.RenderStepped:Connect(function()
	if freecamActive then

		-- Mausbewegung
		local delta = UIS:GetMouseDelta()
		rotation = rotation + Vector2.new(-delta.Y, -delta.X) * mouseSensitivity

		local rotCF =
			CFrame.Angles(0, math.rad(rotation.Y), 0) *
			CFrame.Angles(math.rad(rotation.X), 0, 0)

		local move = Vector3.new()

		if UIS:IsKeyDown(keybinds.Forward) then move += rotCF.LookVector end
		if UIS:IsKeyDown(keybinds.Backward) then move -= rotCF.LookVector end
		if UIS:IsKeyDown(keybinds.Left) then move -= rotCF.RightVector end
		if UIS:IsKeyDown(keybinds.Right) then move += rotCF.RightVector end
		if UIS:IsKeyDown(keybinds.Up) then move += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(keybinds.Down) then move -= Vector3.new(0,1,0) end

		Camera.CFrame = CFrame.new(Camera.CFrame.Position + move * freecamSpeed) * rotCF
	end
end)


---------------------------------------------------------
-------------------- INPUT BINDS -------------------------
---------------------------------------------------------

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == keybinds.ToggleFreecam then
		toggleFreecam(not freecamActive)
	end

	if input.KeyCode == keybinds.Teleport then
		teleportToCam()
	end
end)
