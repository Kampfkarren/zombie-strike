-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")
local Debris			= game:GetService("Debris")

-- constants

local EFFECTS	= Workspace:WaitForChild("Effects")

-- functions

return function(humanoid, pos, normal)
	local armor	= humanoid:FindFirstChild("Armor")

	local hole	= script.HumanoidHit:Clone()
		hole.CFrame	= CFrame.new(pos, pos + normal)
		hole.Parent	= EFFECTS


	if armor and armor.Value > 0 then
		hole.ArmorEmitter:Emit(4)
		hole.SparkEmitter:Emit(10)
	else
		hole.HitEmitter:Emit(4)
		hole.DamageEmitter:Emit(10)
	end

	Debris:AddItem(hole, 5)
end