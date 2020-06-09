-- Gold wipe
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

DataStore2.Combine("DATA", "CodesUsed", "Gold", "Vouchers")

local CODES = {
	"strike",
	"evil",
	"goblin",
	"prize",
	"loot",
	"cool",
	"arena",
	"cowboy",
}

local VOUCHER_CODES = {
	"zombie",
	"transrights",
}

return function(player)
	local goldStore = DataStore2("Gold", player)
	goldStore:Set(0):await() -- bye bye

	local vouchers = DataStore2("Vouchers", player)
	vouchers:Increment(1, 0)

	local codesUsed = DataStore2("CodesUsed", player):Get({})
	for _, code in ipairs(CODES) do
		if table.find(codesUsed, code) then
			goldStore:Increment(1500, 0)
		end
	end

	for _, code in ipairs(VOUCHER_CODES) do
		if table.find(codesUsed, code) then
			vouchers:Increment(1, 0)
		end
	end
end
