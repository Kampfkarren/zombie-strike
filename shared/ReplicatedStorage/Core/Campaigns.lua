local Easy = {
	Name = "Easy",
	Color = Color3.fromRGB(76, 209, 55),
}

local Medium = {
	Name = "Medium",
	Color = Color3.fromRGB(251, 197, 49),
}

local Hard = {
	Name = "Hard",
	Color = Color3.fromRGB(232, 65, 24),
}

return {
	{
		Name = "Campaign A",
		Image = "rbxassetid://2278464",
		Difficulties = {
			{
				MinLevel = 1,
				Style = Easy,
				XP = 600,
			},

			{
				MinLevel = 6,
				Style = Medium,
				XP = 1300,
			},

			{
				MinLevel = 12,
				Style = Hard,
				XP = 3000,
			},
		},
	},

	{
		Name = "Campaign B",
		Image = "rbxassetid://43469952",
		Difficulties = {
			{
				MinLevel = 5,
				Style = Easy,
				XP = 600,
			},

			{
				MinLevel = 6,
				Style = Medium,
				XP = 1300,
			},

			{
				MinLevel = 12,
				Style = Hard,
				XP = 3000,
			},
		},
	},
}
