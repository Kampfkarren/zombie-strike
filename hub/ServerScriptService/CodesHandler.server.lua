local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local REWARD_GOLD = {
	Type = "Gold",
	Amount = 10000,
}

local REWARD_PET_COINS = {
	Type = "PetCoins",
	Amount = 1000,
}

local CODES = {
	evil = REWARD_GOLD,
	goblin = REWARD_GOLD,
	zombie = REWARD_GOLD,
	million = REWARD_GOLD,
	prize = REWARD_GOLD,
	strike = REWARD_GOLD,
	loot = REWARD_GOLD,
	cool = REWARD_GOLD,
	rainway = REWARD_GOLD,
	tanqr = REWARD_GOLD,
	transrights = REWARD_GOLD,
	arena = REWARD_GOLD,
	xmas = REWARD_GOLD,
	cowboy = REWARD_GOLD,
	pet = REWARD_PET_COINS,
}

local SendCode = ReplicatedStorage.Remotes.SendCode

SendCode.OnServerEvent:connect(function(player, code)
	if type(code) ~= "string" then
		warn("CodeHandler: code is not a string")
		return
	end

	code = code:lower()
	local codeInfo = CODES[code]

	if codeInfo == nil then
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

	if codeInfo.Type == "Gold" then
		local _, goldStore = Data.GetPlayerData(player, "Gold")
		goldStore:Increment(codeInfo.Amount)
	elseif codeInfo.Type == "PetCoins" then
		local _, petCoinsStore = Data.GetPlayerData(player, "PetCoins")
		petCoinsStore:Increment(codeInfo.Amount)
	end

	SendCode:FireClient(player, codeInfo)
end)
