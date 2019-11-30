local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local DEFAULT_GOLD = 10000

local CODES = {
	evil = DEFAULT_GOLD,
	goblin = DEFAULT_GOLD,
	zombie = DEFAULT_GOLD,
}

local SendCode = ReplicatedStorage.Remotes.SendCode

SendCode.OnServerEvent:connect(function(player, code)
	if type(code) ~= "string" then
		warn("CodeHandler: code is not a string")
		return
	end

	code = code:lower()

	if CODES[code] == nil then
		SendCode:FireClient(player, "i")
		return
	end

	local codesUsed, codesUsedStore = Data.GetPlayerData(player, "CodesUsed")

	if table.find(codesUsed, code) ~= nil then
		SendCode:FireClient(player, "c")
		return
	end

	table.insert(codesUsed, code)
	codesUsedStore:Set(codesUsed)

	local _, goldStore = Data.GetPlayerData(player, "Gold")
	goldStore:Increment(CODES[code])

	SendCode:FireClient(player, CODES[code])
end)
