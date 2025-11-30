local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function startWalkFling(char)
    local Root = char:WaitForChild("HumanoidRootPart")
    local Humanoid = char:WaitForChild("Humanoid")
    
    -- Godmode setup
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    Humanoid.BreakJointsOnDeath = false
    
    -- Keep health maxed
    game:GetService("RunService").Stepped:Connect(function()
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
    end)
    
    walkflinging = true
    Root.CanCollide = false
    Humanoid:ChangeState(11)
    
    spawn(function()
        while walkflinging and Root and Root.Parent do
            RunService.Heartbeat:Wait()
            local vel = Root.Velocity
            Root.Velocity = vel * 99999999 + Vector3.new(0, 99999999, 0)
            RunService.RenderStepped:Wait()
            Root.Velocity = vel
            RunService.Stepped:Wait()
            Root.Velocity = vel + Vector3.new(0, 0.1, 0)
        end
    end)
end

if LocalPlayer.Character then
    startWalkFling(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(startWalkFling)
