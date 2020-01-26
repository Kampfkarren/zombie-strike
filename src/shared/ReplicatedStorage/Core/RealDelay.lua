local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

return function(amount, callback)
	assert(typeof(amount) == "number", "amount must be a number")

	FastSpawn(function()
		local total = 0

		while total < amount do
			total = total + RunService.Heartbeat:wait()
		end

		callback()
	end)
end
