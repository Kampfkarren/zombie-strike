type Loot = {
	Type: "Skin",
	Skin: {
		Instance: Instance,
	},
	Index: number,
} | {
	Type: "Emote",
	Emote: Instance,
	Index: number,
}

declare const ZombiePassDictionary: {
	FreeLoot: Loot[],
	PaidLoot: Loot[],
}[]

export = ZombiePassDictionary
