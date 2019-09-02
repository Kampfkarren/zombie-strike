local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MockPlayer = {}

MockPlayer.Level = 1
MockPlayer.XP = 0

MockPlayer.Weapon = {
	Stats = {
		Type = "Pistol",
		CritChance = 0.08,
		Damage = 20,
		FireRate = 5,
		Magazine = 9,
	},

	Model = ReplicatedStorage.Items.Pistol,
}

return MockPlayer
