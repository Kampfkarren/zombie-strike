local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(context, player)
	player = player or context.Executor

	DataStore2("Quests", player):Set({
		Day = 0,
		Quests = {},
	})

	player:Kick("hope you get cool ones dude")
end
