-- Humanoid.Died doesn't work...for some reason
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

return function(humanoid)
	local event = Instance.new("BindableEvent")

	FastSpawn(function()
		while humanoid.Health > 0 do
			humanoid.HealthChanged:wait()
		end

		event:Fire()
	end)

	return event.Event
end
