local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local defaultAnimations = {
	[Enum.HumanoidStateType.Climbing] = script.Animations.climb.ClimbAnim,
	[Enum.HumanoidStateType.FallingDown] = script.Animations.fall.FallAnim,
}

local function hookZombie(zombie)
	if zombie:FindFirstChild("NoAnimations") ~= nil then return end

	local animations = {}
	local humanoid = zombie:WaitForChild("Humanoid")

	for key, value in pairs(defaultAnimations) do
		animations[key] = humanoid:LoadAnimation(value)
	end

	local zombieAnimations = zombie:WaitForChild("Animations")

	local idle = humanoid:LoadAnimation(
		zombieAnimations
			:WaitForChild("idle")
			:WaitForChild("Animation1")
	)

	local run = humanoid:LoadAnimation(
		zombieAnimations
			:WaitForChild("run")
			:WaitForChild("RunAnim")
	)

	local walk = humanoid:LoadAnimation(
		zombieAnimations
			:WaitForChild("walk")
			:WaitForChild("WalkAnim")
	)

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
