return {
	Name = "rerollquests",
	Description = "Rerolls the player's quests.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to reroll",
			Optional = true,
		},
	},
}
