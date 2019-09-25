local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(context, level, player)
	local player = player or context.Executor
	DataStore2("Level", player):Set(level)
end
