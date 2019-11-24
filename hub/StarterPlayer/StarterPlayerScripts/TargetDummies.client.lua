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

RunService.Heartbeat:connect(function(delta)
	for target, force in pairs(targetDummyForces) do
		local newForce = math.max(0, force - delta)
		targetDummyForces[target] = newForce

		target.PrimaryPart.CFrame = target.PrimaryPart.CFrame * CFrame.Angles(0, newForce * SPIN_RATE, 0)
	end
end)
