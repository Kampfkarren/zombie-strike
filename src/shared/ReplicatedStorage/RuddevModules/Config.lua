local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunScaling = require(ReplicatedStorage.Core.GunScaling)

local Config = {}

function Config.GetConfig(_, item)
	local weaponData = item:WaitForChild("WeaponData")
	local itemType = weaponData:WaitForChild("Type").Value

	local attachment = item:FindFirstChild("GunAttachment")

	local config = GunScaling.StatsFor({
		Type = itemType,
		Level = weaponData:WaitForChild("Level").Value,
		Rarity = weaponData:WaitForChild("Rarity").Value,

		Attachment = attachment and {
			Type = attachment.ItemType.Value,
			Rarity = attachment.Rarity.Value,
		},
	})

	for _, dataValue in pairs(weaponData:GetChildren()) do
		local name = dataValue.Name
		if name ~= "Type" then
			config[name] = dataValue.Value
		end
	end

	config.GunType = itemType

	return config
end

return Config
