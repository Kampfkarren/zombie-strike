local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local REWARD_GOLD = {
	Type = "Gold",
	Amount = 1500,
}

local REWARD_PET_COINS = {
	Type = "PetCoins",
	Amount = 1000,
}

local REWARD_VOUCHER = {
	Type = "Voucher",
	Amount = 1,
}

local CODES = {
	zombie = REWARD_VOUCHER,
	transrights = REWARD_VOUCHER,
	strike = REWARD_GOLD,
	evil = REWARD_GOLD,
	goblin = REWARD_GOLD,
	prize = REWARD_GOLD,
	loot = REWARD_GOLD,
	cool = REWARD_GOLD,
	arena = REWARD_GOLD,
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
	elseif codeInfo.Type == "Voucher" then
		local _, vouchersStore = Data.GetPlayerData(player, "Vouchers")
		vouchersStore:Increment(codeInfo.Amount)
	end

	SendCode:FireClient(player, codeInfo)
end)
