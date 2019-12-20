local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Collection = require(ReplicatedStorage.Core.Collection)
local Color3Lerp = require(ReplicatedStorage.Core.Color3Lerp)

local COLORS = {
	Color3.new(0, 1, 0.5),
	Color3.fromHSV(350 / 360, 0.3, 0.8),
	Color3.fromRGB(84, 158, 255),
}
local RATE = 0.5

local auroraGuns = {}

local function isMobile()
	return not UserInputService.MouseEnabled
		and not UserInputService.GamepadEnabled
		and not UserInputService.KeyboardEnabled
end

RunService.Heartbeat:connect(function(delta)
	for gun, info in pairs(auroraGuns) do
		if not gun:IsDescendantOf(game) then
			auroraGuns[gun] = nil
			return
		end

		local index, progress = unpack(info)
		progress = math.min(1, progress + delta * RATE)

		local nextColor = (index % #COLORS) + 1

		local start, goal = COLORS[index], COLORS[nextColor]
		gun.Color = Color3Lerp(start, goal, math.sin(progress * math.pi))
		if progress >= 1 then
			index = nextColor
			progress = 0
		end

		auroraGuns[gun] = { index, progress }
	end
end)

Collection("AuroraGun", function(gun)
	if gun:IsDescendantOf(ReplicatedStorage) then
		return
	end

	local primaryPart = gun.PrimaryPart
	while primaryPart == nil do
		gun:GetPropertyChangedSignal("PrimaryPart"):wait()
		primaryPart = gun.PrimaryPart
	end

	if isMobile() then
		primaryPart.Material = Enum.Material.Ice
	end

	auroraGuns[primaryPart] = { math.random(1, 3), math.random() }
end)
