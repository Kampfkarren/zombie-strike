local Players = game:GetService("Players")

local DEFAULT_SPEED = 16

Players.PlayerAdded:connect(function(player)
	local speedMultiplier = Instance.new("NumberValue")
	speedMultiplier.Name = "SpeedMultiplier"
	speedMultiplier.Value = 1

	speedMultiplier.Changed:connect(function(multiplier)
		local character = player.Character
		if character then
			character.Humanoid.WalkSpeed = DEFAULT_SPEED * multiplier
		end
	end)

	player.CharacterAdded:connect(function(character)
		character.Humanoid.WalkSpeed = DEFAULT_SPEED * speedMultiplier.Value
	end)

	speedMultiplier.Parent = player
end)
