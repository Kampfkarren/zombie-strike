local HttpService = game:GetService("HttpService")

return function()
	local MockPlayer = {}

	MockPlayer.Version = 5

	-- ASSUMPTION: We will never have more than 9 difficulties in a campaign
	MockPlayer.LastKnownDifficulty = 11

	MockPlayer.LegendaryBonus = false
	MockPlayer.DungeonsPlayed = 0
	MockPlayer.Level = 1
	MockPlayer.XP = 0
	MockPlayer.Gold = 0

	MockPlayer.Weapon = {
		Type = "Pistol",
		Level = 1,
		Rarity = 1,

		Bonus = 0,
		Upgrades = 0,

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.Armor = {
		Type = "Armor",
		Level = 1,
		Rarity = 1,

		Upgrades = 0,

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.Helmet = {
		Type = "Helmet",
		Level = 1,
		Rarity = 1,

		Upgrades = 0,

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.EquippedWeapon = 1
	MockPlayer.EquippedArmor = 2
	MockPlayer.EquippedHelmet = 3

	MockPlayer.EquippedHealthPack = 1
	MockPlayer.EquippedGrenade = 1

	MockPlayer.Inventory = {
		MockPlayer.Weapon,
		MockPlayer.Armor,
		MockPlayer.Helmet,
	}

	MockPlayer.Cosmetics = {
		Owned = {},
		Equipped = {},
		LastSeen = 0,
	}

	MockPlayer.Settings = {}
	MockPlayer.XPExpires = 0

	return MockPlayer
end
