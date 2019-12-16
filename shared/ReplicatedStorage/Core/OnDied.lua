-- Humanoid.Died doesn't work...for some reason
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Memoize = require(ReplicatedStorage.Core.Memoize)

return Memoize(function(humanoid)
	assert(typeof(humanoid) == "Instance", "OnDied called without Instance")
	assert(humanoid:IsA("Humanoid"), "OnDied called with " .. humanoid.ClassName .. ", not Humanoid")

	local event = Instance.new("BindableEvent")

	FastSpawn(function()
		while humanoid.Health > 0 do
			humanoid.HealthChanged:wait()
		end

		event:Fire()
	end)

	return event.Event
end)
