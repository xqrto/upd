-- Klassische Telekinese
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Tool erstellen
local function createTelekinesisTool()
    local tool = Instance.new("Tool")
    tool.Name = "Telekinesis"
    tool.RequiresHandle = true
    tool.CanBeDropped = true
    tool.Parent = LocalPlayer.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(2,2,2)
    handle.Anchored = false
    handle.CanCollide = false
    handle.Massless = true
    handle.Parent = tool

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://17367347515"
    mesh.TextureId = "rbxassetid://17367347543"
    mesh.Scale = Vector3.new(4,4,4)
    mesh.Parent = handle

    return tool
end

local tool = createTelekinesisTool()
local heldObject = nil

-- Block unter Maus auswählen
local function getBlockUnderMouse(mouse)
    local target = mouse.Target
    if target and target:IsA("BasePart") and not target.Anchored then
        return target
    end
    return nil
end

-- Linke Maustaste: aufnehmen oder werfen
tool.Equipped:Connect(function(mouse)
    mouse.Button1Down:Connect(function()
        if heldObject then
            -- Werfen in Blickrichtung
            heldObject.Anchored = false
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = (mouse.Hit.Position - heldObject.Position).Unit * 150
            bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVel.Parent = heldObject
            game:GetService("Debris"):AddItem(bodyVel,1)
            heldObject = nil
        else
            -- Aufnehmen
            local target = getBlockUnderMouse(mouse)
            if target then
                heldObject = target
                heldObject.Anchored = true
            end
        end
    end)
end)

-- Block folgt Mausposition
RunService.RenderStepped:Connect(function()
    if heldObject then
        local mouse = LocalPlayer:GetMouse()
        heldObject.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, heldObject.Size.Y/2,0))
    end
end)
