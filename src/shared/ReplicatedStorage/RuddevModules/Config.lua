local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Perks = require(ReplicatedStorage.Core.Perks)

local Config = {}

local function deserializePerks(perks)
	if perks == "" then
		return {}
	end

	local deserialized = {}

	for _, perk in ipairs(perks:split("/")) do
		local perkId, upgrades = unpack(perk:split("."))
		table.insert(deserialized, {
			Perk = Perks.Perks[tonumber(perkId)],
			Upgrades = tonumber(upgrades),
		})
	end

	return deserialized
end

function Config.GetConfig(_, item)
	local weaponData = item:WaitForChild("WeaponData")
	local itemType = weaponData:WaitForChild("Type").Value

	local attachment = item:FindFirstChild("GunAttachment")

	local perks = deserializePerks(weaponData.Perks.Value)
	local config = GunScaling.StatsFor({
		Type = itemType,
		Level = weaponData:WaitForChild("Level").Value,
		Rarity = weaponData:WaitForChild("Rarity").Value,

		UUID = weaponData:WaitForChild("UUID").Value,

		Attachment = attachment and {
			Type = attachment.ItemType.Value,
			Rarity = attachment.Rarity.Value,
		},

		Bonus = weaponData:WaitForChild("Bonus").Value,
		Seed = weaponData:WaitForChild("Seed").Value,

		Perks = perks,
	})

	for _, dataValue in pairs(weaponData:GetChildren()) do
		local name = dataValue.Name
		if name ~= "Type" then
			config[name] = dataValue.Value
		end
	end

	config.GunType = itemType
	config.Perks = perks

	for _, perk in ipairs(perks) do
		config = perk.Perk.ModifyConfig(config, perk.Upgrades)
	end

	return config
end

return Config
