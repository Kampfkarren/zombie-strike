return {
	Name = "getitem",
	Description = "Gives the player an item.",
	Group = "Admin",
	Args = {
		{
			Type = "itemName",
			Name = "item",
			Description = "Item to give",
		},

		{
			Type = "integer",
			Name = "level",
			Description = "Level of item",
		},

		{
			Type = "rarity",
			Name = "rarity",
			Description = "Rarity of item",
		},
	},
}
