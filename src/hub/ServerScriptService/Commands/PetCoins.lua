return {
	Name = "givepetcoins",
	Description = "Gives the player pet coins.",
	Group = "Admin",
	Args = {
		{
			Type = "integer",
			Name = "coins",
			Description = "Coins to give",
		},

		{
			Type = "player",
			Name = "player",
			Description = "Player to set level",
			Optional = true,
		},
	},
}
