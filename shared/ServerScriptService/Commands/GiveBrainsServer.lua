local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(context, brains, player)
	local player = player or context.Executor
	DataStore2("Brains", player):Increment(brains)
end
