local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttachmentsConstants = require(ReplicatedStorage.Core.AttachmentsConstants)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)

local Config = {}

local Bases = {}

Bases.Pistol = {
	Type = "Gun",
	Size = "Light",

	Recoil = 25,
	Range = 500,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 1,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.15,
}

Bases.Rifle = {
	Type = "Gun",
	Size = "Medium",

	Recoil = 10,
	Range = 700,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 1.8,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.18,
}

Bases.Shotgun = {
	Type = "Gun",
	Size = "Shotgun",

	Recoil = 30,
	Range = 150,
	Spread = 8,
	Zoom = 10,
	ReloadTime = 1.3,
	FireMode = "Auto",
	Dropoff = 3,
	Reticle = "Shotgun",
	ScaleBuff = 1.15,
}

Bases.SMG = {
	Type = "Gun",
	Size = "Light",

	Recoil = 12,
	Range = 500,
	ShotSize = 1,
	Spread = 3,
	Zoom = 20,
	ReloadTime = 1,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1.15,
}

Bases.Sniper = {
	Type = "Gun",
	Size = "Heavy",

	Recoil = 30,
	Range = 1300,
	ShotSize = 1,
	Spread = 0,
	Zoom = 35,
	ReloadTime = 1.8,
	FireMode = "Auto",
	Dropoff = 5,
	ScaleBuff = 0.95,
}

Bases.Crystal = {
	Type = "Gun",
	Size = "Light",

	Recoil = 30,
	Range = 1300,
	ShotSize = 1,
	Spread = 2,
	Zoom = 20,
	ReloadTime = 0,
	FireMode = "Auto",
	Dropoff = 3,
	ScaleBuff = 1,
}

function Config.GetShotgunShotSize(level)
	return math.floor(5 * (1.01 ^ (level - 1)))
end

function Config.GetConfig(_, item)
	local weaponData = item:WaitForChild("WeaponData")
	local itemType = weaponData:WaitForChild("Type").Value

	local config = GunScaling.BaseStats(
		itemType,
		weaponData:WaitForChild("Level").Value,
		weaponData:WaitForChild("Rarity").Value
	)

	for baseKey, baseValue in pairs(Bases[itemType]) do
		config[baseKey] = baseValue
	end

	for _, dataValue in pairs(weaponData:GetChildren()) do
		local name = dataValue.Name
		if name ~= "Type" then
			config[name] = dataValue.Value
		end
	end

	if config.Size == "Shotgun" then
		config.ShotSize = Config.GetShotgunShotSize(config.Level)
	end

	local attachment = item:FindFirstChild("GunAttachment")
	if attachment then
		if attachment.ItemType.Value == "Magazine" then
			config.Magazine = math.ceil(config.Magazine * (1 + AttachmentsConstants.Magazine[attachment.Rarity.Value] / 100))
		elseif attachment.ItemType.Value == "Laser" then
			config.CritChance = config.CritChance * (1 + AttachmentsConstants.LaserSightCritChance[attachment.Rarity.Value] / 100)
			config.Recoil = config.Recoil * (1 + AttachmentsConstants.LaserSightRecoil[attachment.Rarity.Value] / 100)
		elseif attachment.ItemType.Value == "Silencer" then
			config.Damage = math.ceil(config.Damage * (1 + AttachmentsConstants.SilencerDamage[attachment.Rarity.Value] / 100))
		end
	end

	return config
end

return Config
