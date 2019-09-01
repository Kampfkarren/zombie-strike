local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local defaultAnimations = {
	[Enum.HumanoidStateType.Climbing] = script.Animations.climb.ClimbAnim,
	[Enum.HumanoidStateType.FallingDown] = script.Animations.fall.FallAnim,
}

-- TODO: Have the Zombie class instantiate animations
local function hookZombie(zombie)
	local animations = {}
	local humanoid = zombie:WaitForChild("Humanoid")

	for key, value in pairs(defaultAnimations) do
		animations[key] = humanoid:LoadAnimation(value)
	end

	local idle = humanoid:LoadAnimation(script.Animations.idle.Animation1)
	local run = humanoid:LoadAnimation(script.Animations.run.RunAnim)
	local walk = humanoid:LoadAnimation(script.Animations.walk.WalkAnim)

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
