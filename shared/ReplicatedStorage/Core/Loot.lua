local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentUtil = require(ReplicatedStorage.Core.EquipmentUtil)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
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
	"Attachment", -- Should be last since it can be nil
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

Loot.Rarities = LootStyles

Loot.Attachments = {
	"Magazine",
	"Laser",
	"Silencer",
}

local attachmentType = t.union(
	t.literal("Magazine"),
	t.literal("Laser"),
	t.literal("Silencer")
)

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

		Attachment = t.optional(
			t.strictInterface({
				Type = attachmentType,
				Model = t.number,
				Rarity = t.numberConstrained(1, #Loot.Rarities),
				UUID = t.string,
			})
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
	}),

	t.interface({
		Rarity = t.numberConstrained(1, #Loot.Rarities),
		Type = attachmentType,

		Favorited = t.boolean,

		Model = t.number,
		UUID = t.string,
	}),

	t.interface({
		Rarity = t.numberConstrained(1, #PetsDictionary.Rarities),
		Type = t.literal("Pet"),

		Favorited = t.boolean,

		Model = t.numberConstrained(1, #PetsDictionary.Pets),
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
		if Loot.IsWeapon(item) then
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

	if Loot.IsWearable(data) then
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
	elseif Loot.IsPet(loot) then
		return PetsDictionary.Pets[loot.Model].Name
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
	return not Loot.IsWearable(loot)
		and not Loot.IsEquipment(loot)
		and not Loot.IsAttachment(loot)
		and not Loot.IsCosmetic(loot)
		and not Loot.IsPet(loot)
end

function Loot.IsEquipment(loot)
	return loot.Type == "Grenade" or loot.Type == "HealthPack"
end

function Loot.IsAttachment(loot)
	return table.find(Loot.Attachments, loot.Type) ~= nil
end

function Loot.IsAurora(loot)
	return Loot.IsWeapon(loot)
		and (loot.Model >= 6 and loot.Model <= 10)
end

function Loot.IsRevolver(loot)
	return loot.Type == "Pistol"
		and (loot.Model >= 11 and loot.Model <= 15)
end

function Loot.IsPet(loot)
	return loot.Type == "Pet"
end

function Loot.IsCosmetic(loot)
	return loot.Type == "Face"
		or loot.Type == "Particle"
		or loot.Type == "LowTier"
		or loot.Type == "HighTier"
		or loot.Type == "Spray"
		or loot.Type == "GunSkin"
		or loot.ParentType ~= nil
end

function Loot.RandomAttachment()
	return Loot.Attachments[math.random(#Loot.Attachments)]
end

return Loot
