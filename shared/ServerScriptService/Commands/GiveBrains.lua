return {
	Name = "givebrains",
	Description = "Gives the player brains.",
	Group = "Admin",
	Args = {
		{
			Type = "integer",
			Name = "brains",
			Description = "Brains to give",
		},

		{
			Type = "player",
			Name = "player",
			Description = "Player to set level",
			Optional = true,
		},
	},
}
