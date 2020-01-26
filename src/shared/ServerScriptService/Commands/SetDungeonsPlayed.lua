return {
	Name = "setdungeonsplayed",
	Description = "Sets the dungeons played.",
	Group = "Admin",
	Aliases = { "setdp" },
	Args = {
		{
			Type = "integer",
			Name = "dungeons",
			Description = "Amount of dungeons to set",
		},

		{
			Type = "player",
			Name = "player",
			Description = "Player to set level",
			Optional = true,
		},
	},
}
