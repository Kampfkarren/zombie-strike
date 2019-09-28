local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Vendor.t)

local Loot = {}

local gunMap = {
	"Type",
	"Level",
	"Name",
	"Rarity",
	"Bonus",
	"Model",
	"Upgrades",
	"UUID",
}

local armorMap = {
	"Type",
	"Level",
	"Name",
	"Rarity",
	"Model",
	"Upgrades",
	"UUID",
}

Loot.Rarities = {
	{
		Name = "Common",
		Color = Color3.fromRGB(219, 219, 219),
	},

	{
		Name = "Uncommon",
		Color = Color3.fromRGB(0, 189, 50),
	},

	{
		Name = "Rare",
		Color = Color3.fromRGB(3, 52, 143),
	},

	{
		Name = "Epic",
		Color = Color3.fromRGB(162, 155, 254),
	},

	{
		Name = "Legendary",
		Color = Color3.fromRGB(253, 150, 68),
	},
}

local serializeStruct = t.union(
	t.strictInterface({
		Level = t.number,
		Name = t.string,
		Rarity = t.numberConstrained(1, #Loot.Rarities),
		Type = t.union(
			t.literal("Pistol"),
			t.literal("Rifle"),
			t.literal("SMG"),
			t.literal("Shotgun"),
			t.literal("Sniper")
		),

		Bonus = t.number,
		Upgrades = t.number,

		Model = t.number,
		UUID = t.string,
	}),

	t.strictInterface({
		Level = t.number,
		Name = t.string,
		Rarity = t.numberConstrained(1, #Loot.Rarities),
		Type = t.union(
			t.literal("Armor"),
			t.literal("Helmet")
		),

		Upgrades = t.number,

		Model = t.number,
		UUID = t.string,
	})
)

function Loot.Deserialize(data)
	local loot = {}
	local map = gunMap

	if data[1] == "Armor" or data[1] == "Helmet" then
		map = armorMap
	end

	for index, key in pairs(map) do
		loot[key] = data[index]
	end

	assert(serializeStruct(loot))
	return loot
end

function Loot.DeserializeTable(loot)
	local deserialized = {}
	for index, loot in pairs(loot) do
		deserialized[index] = Loot.Deserialize(loot)
	end
	return deserialized
end

function Loot.Serialize(data)
	assert(serializeStruct(data))

	local loot = {}
	local map = gunMap

	if data.Type == "Armor" or data.Type == "Helmet" then
		map = armorMap
	end

	for index, key in pairs(map) do
		loot[index] = data[key]
	end

	return loot
end

function Loot.SerializeTable(loot)
	local serialized = {}
	for index, loot in pairs(loot) do
		serialized[index] = Loot.Serialize(loot)
	end
	return serialized
end

return Loot
