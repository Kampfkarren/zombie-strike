local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Promise = require(ReplicatedStorage.Core.Promise)
local ZombiePassDictionary = require(ReplicatedStorage.Core.ZombiePassDictionary)

local ZombiePassRewards = {}

local POSSESSIONS = {
	Emote = "Sprays",
	Font = "Fonts",
	Title = "Titles",
}

ZombiePassRewards.GetLootForLevel = function(level, premium)
	local rewards = {}

	local passLevel = ZombiePassDictionary[level]
	if not passLevel then
		return {}
	end

	for _, freeLoot in ipairs(passLevel.FreeLoot) do
		table.insert(rewards, freeLoot)
	end

	if premium then
		for _, paidLoot in ipairs(passLevel.PaidLoot) do
			table.insert(rewards, paidLoot)
		end
	end

	return rewards
end

local function grantReward(player, reward)
	local possessionKey = POSSESSIONS[reward.Type]

	if possessionKey then
		return Data.GetPlayerDataAsync(player, possessionKey):andThen(function(data, dataStore)
			table.insert(data.Owned, reward.Index)
			data.Equipped = reward.Index
			dataStore:Set(data)

			ReplicatedStorage.Remotes["Update" .. possessionKey]:FireClient(player, data.Equipped, data.Owned)
		end)
	elseif reward.Type == "Skin" then
		local item = reward.Skin

		return Data.GetPlayerDataAsync(player, "Cosmetics"):andThen(function(cosmetics, cosmeticsStore)
			if item.Type == "LowTier" or item.Type == "HighTier" then
				table.insert(cosmetics.Owned, item.Index + 1)
				table.insert(cosmetics.Owned, item.Index + 2)
			else
				table.insert(cosmetics.Owned, item.Index)
			end

			cosmeticsStore:Set(cosmetics)
			ReplicatedStorage.Remotes.UpdateCosmetics:FireClient(player, cosmetics.Owned, cosmetics.Equipped)
		end)
	elseif reward.Type == "Brains" then
		return Data.GetPlayerDataAsync(player, "Brains"):andThen(function(_, brainsStore)
			brainsStore:Increment(reward.Brains)
		end)
	elseif reward.Type == "PetCoins" then
		return Data.GetPlayerDataAsync(player, "PetCoins"):andThen(function(_, petCoinsStore)
			petCoinsStore:Increment(reward.PetCoins)
		end)
	elseif reward.Type == "XP" then
		-- These are resolved in the mission
		return Promise.resolve()
	else
		warn("unknown reward type: " .. reward.Type)
		return Promise.resolve()
	end
end

ZombiePassRewards.GrantRewards = function(player, levels)
	local promises = {}

	for _, level in ipairs(levels) do
		for _, reward in pairs(ZombiePassRewards.GetLootForLevel(
			level,
			Data.GetPlayerData(player, "ZombiePass").Premium)
		) do
			table.insert(promises, grantReward(player, reward))
		end
	end

	return Promise.all(promises)
end

return ZombiePassRewards
