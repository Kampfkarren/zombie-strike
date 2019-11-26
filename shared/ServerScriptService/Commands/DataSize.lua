return {
	Name = "datasize",
	Description = "Checks the size of the player's data.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to check data size of",
			Optional = true,
		},
	},
}
