local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Memoize = require(ReplicatedStorage.Core.Memoize)

return Memoize(function(arenaLevel)
	return {
		MinLevel = arenaLevel,
		Style = {
			Name = "LV. " .. arenaLevel,
			Color = Color3.new(0.3, 0.3, 0.3),
		},
	}
end)
