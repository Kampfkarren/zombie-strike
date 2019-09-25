return {
	Name = "setlevel",
	Description = "Sets the player level.",
	Group = "Admin",
	Args = {
		{
			Type = "integer",
			Name = "level",
			Description = "Level to set",
		},

		{
			Type = "player",
			Name = "player",
			Description = "Player to set level",
			Optional = true,
		},
	},
}
