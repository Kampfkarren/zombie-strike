local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local defaultAnimations = {
	[Enum.HumanoidStateType.Climbing] = script.Animations.climb.ClimbAnim,
	[Enum.HumanoidStateType.FallingDown] = script.Animations.fall.FallAnim,
}

-- TODO: Have the Zombie class instantiate animations
local function hookZombie(zombie)
	if zombie:FindFirstChild("NoAnimations") ~= nil then return end

	local animations = {}
	local humanoid = zombie:WaitForChild("Humanoid")

	for key, value in pairs(defaultAnimations) do
		animations[key] = humanoid:LoadAnimation(value)
	end

	local zombieAnimations = zombie:WaitForChild("Animations")

	local idle = humanoid:LoadAnimation(zombieAnimations:WaitForChild("idle").Animation1)
	local run = humanoid:LoadAnimation(zombieAnimations:WaitForChild("run").RunAnim)
	local walk = humanoid:LoadAnimation(zombieAnimations:WaitForChild("walk").WalkAnim)

	walk:AdjustSpeed(0.2)

	local lastAnimation

	zombie.Humanoid.StateChanged:connect(function(_, new)
		if animations[new] then
			lastAnimation = new
			animations[new]:Play()
		end
	end)

	zombie.Humanoid.Running:connect(function(speed)
		RunService.Heartbeat:wait()
		if speed <= 1 then
			if lastAnimation ~= idle then
				idle:Play()
				lastAnimation = idle
			end
		elseif speed <= 6 then
			if lastAnimation ~= walk then
				walk:Play()
				lastAnimation = walk
			end
		else
			if lastAnimation ~= run then
				run:Play()
				lastAnimation = run
			end
		end
	end)
end

CollectionService:GetInstanceAddedSignal("Zombie"):connect(hookZombie)
for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
	hookZombie(zombie)
end
