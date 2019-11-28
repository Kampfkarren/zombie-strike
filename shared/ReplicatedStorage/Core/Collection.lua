local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

return function(name, callback)
	for _, thing in pairs(CollectionService:GetTagged(name)) do
		FastSpawn(function()
			callback(thing)
		end)
	end

	CollectionService:GetInstanceAddedSignal(name):connect(callback)
end
