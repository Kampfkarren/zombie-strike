local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TargetDummies = Workspace.TargetDummies

local SPIN_RATE = 0.5

local targetDummyForces = {}

ReplicatedStorage.Remotes.DamageNumber.OnClientEvent:connect(function(humanoid)
	if humanoid:IsDescendantOf(TargetDummies) then
		targetDummyForces[humanoid.Parent] = 1
	end
end)

local function spin(part, force)
	part.CFrame = part.CFrame * CFrame.Angles(0, force * SPIN_RATE, 0)
end

RunService.Heartbeat:connect(function(delta)
	for target, force in pairs(targetDummyForces) do
		local newForce = math.max(0, force - delta)
		targetDummyForces[target] = newForce

		spin(target.PrimaryPart, newForce)
		spin(target.Head, newForce)
		spin(target.Arm, newForce)
	end
end)
