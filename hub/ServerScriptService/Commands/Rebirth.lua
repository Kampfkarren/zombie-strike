return {
	Name = "rebirth",
	Description = "Resets the player's inventory and level.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to rebirth",
			Optional = true,
		},
	},
}
