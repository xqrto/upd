local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Tool erstellen
local tool = Instance.new("Tool")
tool.Name = "TeleportTool"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = player.Backpack

-- Unsichtbarer Handle (optional)
local handle = Instance.new("Part")
handle.Size = Vector3.new(1,1,1)
handle.Transparency = 1
handle.Anchored = false
handle.CanCollide = false
handle.Name = "Handle"
handle.Parent = tool

-- Funktion: Teleport
local function teleport(hitPosition, hitPart)
	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local targetPosition = hitPosition

	-- Wenn ein Part getroffen wurde → oben drauf teleportieren
	if hitPart and hitPart:IsA("BasePart") then
		targetPosition = hitPart.Position 
			+ Vector3.new(0, hitPart.Size.Y / 2 + 3, 0)
	end

	humanoidRootPart.CFrame = CFrame.new(targetPosition)
end

-- Klick-Event
tool.Activated:Connect(function()
	if mouse and mouse.Hit then
		teleport(mouse.Hit.Position, mouse.Target)
	end
end)
