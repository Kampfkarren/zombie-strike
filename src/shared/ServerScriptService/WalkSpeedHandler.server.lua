local Players = game:GetService("Players")

Players.PlayerAdded:connect(function(player)
	local speedMultiplier = Instance.new("NumberValue")
	speedMultiplier.Name = "SpeedMultiplier"
	speedMultiplier.Value = 1
	speedMultiplier.Parent = player
end)
