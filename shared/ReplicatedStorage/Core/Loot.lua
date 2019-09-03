local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local t = require(ReplicatedStorage.Vendor.t)

local Loot = {}

local map = {
	"Level",
	"Name",
	"Rarity",
	"Type",
	"Damage",
	"FireRate",
	"CritChance",
	"Magazine",
	"Model",
}

Loot.Rarities = {
	{
		Name = "Common",
		-- Color = Color3.new(1, 1, 1),
	},

	{
		Name = "Uncommon",
		Color = Color3.fromRGB(186, 220, 88),
	},

	{
		Name = "Rare",
		Color = Color3.fromRGB(6, 82, 221),
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

local serializeStruct = t.interface({
	Level = t.number,
	Name = t.string,
	Rarity = t.numberConstrained(1, #Loot.Rarities),
	Type = t.string,

	Damage = t.number,
	FireRate = t.number,
	CritChance = t.number,
	Magazine = t.number,

	Model = t.number,
})

function Loot.Deserialize(data)
	local loot = {}

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
