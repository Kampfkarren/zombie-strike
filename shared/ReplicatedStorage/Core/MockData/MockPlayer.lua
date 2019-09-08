local HttpService = game:GetService("HttpService")

return function()
	local MockPlayer = {}

	MockPlayer.Level = 1
	MockPlayer.XP = 0
	MockPlayer.Gold = 100

	MockPlayer.Weapon = {
		Type = "Rifle",
		Level = 1,
		Rarity = 1,
		Name = "Average Pistol",

		Damage = 20,
		FireRate = 5,
		CritChance = 0.08,
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

	MockPlayer.EquippedWeapon = 1
	MockPlayer.EquippedArmor = 2
	MockPlayer.EquippedHelmet = 3

	MockPlayer.EquippedHealthPack = 1

	MockPlayer.Inventory = {
		MockPlayer.Weapon,
		MockPlayer.Armor,
		MockPlayer.Helmet,
	}

	return MockPlayer
end
