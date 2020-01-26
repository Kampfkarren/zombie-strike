local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(context, gold, player)
	local player = player or context.Executor
	DataStore2("Gold", player):Increment(gold)
end
