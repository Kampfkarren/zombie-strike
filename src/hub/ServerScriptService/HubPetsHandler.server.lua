local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)

local OpenEgg = ReplicatedStorage.Remotes.OpenEgg
local UpdatePetCoins = ReplicatedStorage.Remotes.UpdatePetCoins

local rng = Random.new()

Players.PlayerAdded:connect(function(player)
	local coins, coinsStore = Data.GetPlayerData(player, "PetCoins")

	local function updateCoins(coins)
		UpdatePetCoins:FireClient(player, coins)
	end

	updateCoins(coins)
	coinsStore:OnUpdate(updateCoins)
end)

OpenEgg.OnServerEvent:connect(function(player)
	local coins, coinsStore = Data.GetPlayerData(player, "PetCoins")

	if coins < PetsDictionary.EggCost then
		warn("OpenEgg: not enough pet coins")
		return
	end

	local space = InventorySpace(player):awaitValue()

	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")
	local equippedPet, equippedPetStore = Data.GetPlayerData(player, "EquippedPet")

	if space <= #inventory then
		warn("OpenEgg: inventory full")
		return
	end

	local model = rng:NextInteger(1, #PetsDictionary.Pets)

	local rarityRoll = rng:NextInteger(1, 100)
	local rarity

	local sum = 0

	for rarityIndex = #PetsDictionary.Rarities, 1, -1 do
		local thisRarity = PetsDictionary.Rarities[rarityIndex]
		if rarityRoll <= sum + thisRarity.DropRate then
			rarity = rarityIndex
			break
		else
			sum = sum + thisRarity.DropRate
		end
	end

	if rarity == nil then
		warn("OpenEgg: chances must not add to 100! sum = " .. sum)
		rarity = 1
	end

	table.insert(inventory, {
		Rarity = rarity,
		Type = "Pet",

		Favorited = false,

		Model = model,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	})

	inventoryStore:Set(inventory)

	if equippedPet == nil then
		equippedPetStore:Set(#inventory)
	end

	OpenEgg:FireClient(player, model, rarity)
	coinsStore:Increment(-PetsDictionary.EggCost)
end)
