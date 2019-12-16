local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local QualityDictionary = require(ReplicatedStorage.Core.QualityDictionary)
local t = require(ReplicatedStorage.Vendor.t)

local Loot = {}

local gunMap = {
	"Type",
	"Level",
	"Rarity",
	"Bonus",
	"Model",
	"Upgrades",
	"Favorited",
	"UUID",
}

local armorMap = {
	"Type",
	"Level",
	"Rarity",
	"Model",
	"Upgrades",
	"Favorited",
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
		Favorited = t.boolean,

		Model = t.number,
		UUID = t.string,
	}),

	t.strictInterface({
		Level = t.number,
		Rarity = t.numberConstrained(1, #Loot.Rarities),
		Type = t.union(
			t.literal("Armor"),
			t.literal("Helmet")
		),

		Upgrades = t.number,
		Favorited = t.boolean,

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

function Loot.DeserializeTableWithBase(loot)
	local loot = Loot.DeserializeTable(loot)

	for _, item in pairs(loot) do
		if item.Type ~= "Helmet" and item.Type ~= "Armor" then
			for key, value in pairs(GunScaling.BaseStats(item.Type, item.Level, item.Rarity)) do
				if item[key] == nil then
					item[key] = value
				end
			end
		end
	end

	return loot
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

function Loot.GetLootName(loot)
	if Loot.IsEquipment(loot) then
		return EquipmentUtil.FromIndex(loot.Type, loot.Index).Name
	end

	local model = ReplicatedStorage.Items[loot.Type .. loot.Model]
	local qualityName = ""

	if Loot.IsWeapon(loot) then
		for _, quality in ipairs(QualityDictionary) do
			if loot.Bonus <= quality[1] then
				qualityName = quality[2] .. " "
				break
			end
		end

		assert(qualityName ~= "")
	end

	return qualityName .. model.ItemName.Value
end

function Loot.IsWearable(loot)
	return loot.Type == "Armor" or loot.Type == "Helmet"
end

function Loot.IsWeapon(loot)
	return not Loot.IsWearable(loot) and not Loot.IsEquipment(loot)
end

function Loot.IsEquipment(loot)
	return loot.Type == "Grenade" or loot.Type == "HealthPack"
end

return Loot
