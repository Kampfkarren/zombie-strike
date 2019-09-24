local HttpService = game:GetService("HttpService")

return function()
	local MockPlayer = {}

	MockPlayer.Version = 1

	MockPlayer.Level = 1
	MockPlayer.XP = 0
	MockPlayer.Gold = 100

	MockPlayer.Weapon = {
		Type = "Pistol",
		Level = 1,
		Rarity = 1,
		Name = "Average Pistol",

		Damage = 20,
		FireRate = 500,
		CritChance = 8,
		Magazine = 9,

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.Armor = {
		Type = "Armor",
		Level = 1,
		Rarity = 1,
		Name = "Armor",

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.Helmet = {
		Type = "Helmet",
		Level = 1,
		Rarity = 1,
		Name = "Helmet",

		Model = 1,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}

	MockPlayer.EquippedWeapon = 4
	MockPlayer.EquippedArmor = 2
	MockPlayer.EquippedHelmet = 3

	MockPlayer.EquippedHealthPack = 1
	MockPlayer.EquippedGrenade = 1

	MockPlayer.Inventory = {
		MockPlayer.Weapon,
		MockPlayer.Armor,
		MockPlayer.Helmet,

		{
			Type = "Pistol",
			Level = 1,
			Rarity = 1,
			Name = "Average Pistol",

			Damage = 123456,
			FireRate = 500,
			CritChance = 8,
			Magazine = 9,

			Model = 1,
			UUID = HttpService:GenerateGUID(false):gsub("-", ""),
		}
	}

	MockPlayer.Settings = {}

	return MockPlayer
end
