local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Raycast = require(ReplicatedStorage.Core.Raycast)

local WarningRange = ReplicatedStorage.WarningRange

return function(center, range, dontMoveDown)
	local part = WarningRange:Clone()
	part.Size = Vector3.new(0.25, range * 2, range * 2)

	if not dontMoveDown then
		local characters = {}

		for _, player in pairs(Players:GetPlayers()) do
			table.insert(characters, player.Character)
		end

		local _, position = Raycast(
			center,
			Vector3.new(0, -1000, 0),
			characters
		)

		center = position
	end

	part.CFrame = CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2)
	part.Parent = Workspace.Effects

	return part
end
