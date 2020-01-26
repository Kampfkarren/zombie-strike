return {
	Name = "givegold",
	Description = "Gives the player gold.",
	Group = "Admin",
	Args = {
		{
			Type = "integer",
			Name = "gold",
			Description = "Gold to give",
		},

		{
			Type = "player",
			Name = "player",
			Description = "Player to set level",
			Optional = true,
		},
	},
}
