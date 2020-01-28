-- Humanoid.Died doesn't work...for some reason
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local events = {}

local function OnDied(humanoid)
	assert(typeof(humanoid) == "Instance", "OnDied called without Instance")
	assert(humanoid:IsA("Humanoid"), "OnDied called with " .. humanoid.ClassName .. ", not Humanoid")

	if events[humanoid] then
		return events[humanoid]
	end

	local event = Instance.new("BindableEvent")
	local fired = false

	local function fire()
		if fired then return end
		fired = true
		event:Fire()
	end

	humanoid.Died:connect(fire)

	FastSpawn(function()
		while humanoid.Health > 0 do
			humanoid.HealthChanged:wait()
		end

		if not fired then
			fire()
		end
	end)

	events[humanoid] = event.Event
	return event.Event
end

return OnDied
