local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CosmeticsDictionary = require(ReplicatedStorage.Core.CosmeticsDictionary)
local CosmeticsStore = require(ReplicatedStorage.Core.CosmeticsStore)
local Data = require(ReplicatedStorage.Core.Data)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local t = require(ReplicatedStorage.Vendor.t)

local dateStamp

if RunService:IsClient() then
	dateStamp = ReplicatedStorage.Remotes.GetServerDateStamp:InvokeServer()
end

local cosmeticType = t.array(t.union(
	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Face"),
		Instance = t.instanceIsA("Decal"),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Particle"),
		Instance = t.instanceIsA("Folder"),
		Image = t.instanceIsA("Decal"),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		Instance = t.instanceIsA("Folder"),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Armor"),
		Instance = t.union(t.instanceIsA("Folder")),
		ParentType = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		DontSellMe = t.optional(t.boolean),
	}),

	t.strictInterface({
		Index = t.number,
		Name = t.string,
		Type = t.literal("Helmet"),
		Instance = t.union(
			t.instanceIsA("Accessory"),
			t.instanceIsA("Folder"),
			t.instanceIsA("BasePart")
		),
		ParentType = t.union(
			t.literal("LowTier"),
			t.literal("HighTier")
		),
		DontSellMe = t.optional(t.boolean),
	})
))

local Cosmetics = {}

Cosmetics.Cosmetics = CosmeticsDictionary

for index, item in ipairs(Cosmetics.Cosmetics) do
	local itemType = item.Instance:FindFirstChild("ItemType")
	item.Index = index

	if itemType
		and (itemType.Value == "BundleSimple"
		or itemType.Value == "BundleComplex")
	then
		table.insert(Cosmetics.Cosmetics, index + 1, {
			Name = item.Name,
			Type = "Armor",
			Instance = item.Instance.Contents.Armor,
			ParentType = item.Type,
		})

		table.insert(Cosmetics.Cosmetics, index + 1, {
			Name = item.Name,
			Type = "Helmet",
			Instance = item.Instance.Contents.Helmet,
			ParentType = item.Type,
		})
	end
end

Cosmetics.Costs = {
	Mythic = {
		Cost = 3599,
	},

	Legendary = {
		Cost = 2199,
	},
}

Cosmetics.Distribution = {
	HighTier = {
		Count = 1,
		Cost = 4400,
	},

	LowTier = {
		Count = 2,
		Cost = 1800,
	},

	Face = {
		Count = 2,
		Cost = 250,
	},

	Particle = {
		Count = 2,
		Cost = 900,
	},
}

local function generateGun(player, rarity, rng, exclude)
	local model

	if rarity == 5 then
		model = 5
	else
		model = 1
	end

	return {
		Type = GunScaling.RandomType(rng, exclude),
		Rarity = rarity,
		Level = player == Players.LocalPlayer
			and player:WaitForChild("PlayerData"):WaitForChild("Level").Value
			or Data.GetPlayerData(player, "Level"),

		Bonus = rng:NextInteger(5, 10),
		Upgrades = 0,
		Favorited = false,

		Model = model,
		UUID = "COSMETIC_WEAPON_" .. rng:NextNumber(), -- Replaced with a real UUID on purchase
	}
end

function Cosmetics.CostOf(itemType)
	return (Cosmetics.Costs[itemType] or Cosmetics.Distribution[itemType]).Cost
end

function Cosmetics.GetStoreItems(player)
	player = player or Players.LocalPlayer
	--assert(player ~= nil, "GetStoreItems was not passed with a player")

	local stamp

	if RunService:IsServer() then
		local date = os.date("!*t")
		stamp = date.year + date.yday
	else
		stamp = dateStamp
	end

	local rng = Random.new(stamp)
	local collated = {}

	for _, cosmetic in ipairs(Cosmetics.Cosmetics) do
		if Cosmetics.Distribution[cosmetic.Type] and not cosmetic.DontSellMe then
			if collated[cosmetic.Type] then
				table.insert(collated[cosmetic.Type], cosmetic)
			else
				collated[cosmetic.Type] = { cosmetic }
			end
		end
	end

	local contents = {}

	for key, passes in pairs(Cosmetics.Distribution) do
		local products = {}

		for _ = 1, passes.Count do
			table.insert(products, table.remove(collated[key], rng:NextInteger(1, #collated[key])))
		end

		contents[key] = products
	end

	-- Apply explicit store patch
	local storePatch = CosmeticsStore[stamp]
	if storePatch then
		for key, stuff in pairs(storePatch) do
			local patchedContents = {}
			for _, item in ipairs(CosmeticsDictionary) do
				if item.Type == key then
					local needed = table.find(stuff, item.Name)
					if needed then
						patchedContents[needed] = item
					end
				end
			end
			assert(#patchedContents == #contents[key])
			contents[key] = patchedContents
		end
	end

	-- Purchasable weapons
	local playerRng = Random.new(stamp + player.UserId)

	contents.Mythic = { generateGun(player, 6, playerRng) }

	local legendaryOne = generateGun(player, 5, playerRng)
	local legendaryTwo = generateGun(player, 5, playerRng, legendaryOne.Type)
	contents.Legendary = { legendaryOne, legendaryTwo }

	return contents
end

assert(cosmeticType(Cosmetics.Cosmetics))

return Cosmetics
