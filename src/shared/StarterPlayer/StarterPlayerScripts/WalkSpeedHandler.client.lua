local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_SPEED = 16

local speedMultiplier = LocalPlayer:WaitForChild("SpeedMultiplier")

local localMultipliers = Instance.new("Folder")
localMultipliers.Name = "LocalMultipliers"
localMultipliers.Parent = speedMultiplier

local function getSpeedMultiplier()
	local base = speedMultiplier.Value

	for _, localMultiplier in ipairs(localMultipliers:GetChildren()) do
		base = base + localMultiplier.Value
	end

	return base
end

local function updateSpeed()
	local character = LocalPlayer.Character
	if character then
		local humanoid = character:WaitForChild("Humanoid")

		if speedMultiplier:FindFirstChild("Stunned") then
			humanoid.WalkSpeed = 0
		else
			humanoid.WalkSpeed = DEFAULT_SPEED * getSpeedMultiplier()
		end
	end
end

speedMultiplier.Changed:connect(updateSpeed)
speedMultiplier.ChildAdded:connect(updateSpeed)
speedMultiplier.ChildRemoved:connect(updateSpeed)
localMultipliers.ChildAdded:connect(updateSpeed)
localMultipliers.ChildRemoved:connect(updateSpeed)
LocalPlayer.CharacterAdded:connect(updateSpeed)

speedMultiplier.Parent = LocalPlayer
