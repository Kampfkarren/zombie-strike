local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local MAX = 260000

return function(context, player)
	local player = player or context.Executor

	local combinedStore = DataStore2("Gold", player).combinedStore
	local allData = combinedStore:Get()
	local json = HttpService:JSONEncode(allData)
	return ("%d (%.2f%%)"):format(#json, #json / MAX * 100)
end
