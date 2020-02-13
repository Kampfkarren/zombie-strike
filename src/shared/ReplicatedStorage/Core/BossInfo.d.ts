type LootReward = {
	Common: readonly number[],
	Uncommon: readonly number[],
	Rare: readonly number[],
	Epic: readonly number[],
	Legendary: readonly number[],
}

export type BossStat = {
	Base: number,
	Scale: number,
}

export type BossInfo = {
	Name: string,
	Image: string,
	RoomName: string,
	AIAggroRange: number,
	LoadingColor: Color3,

	Loot: Partial<{
		Armor: LootReward,
		Helmet: LootReward,
	}>,

	Stats: {
		[zombieName: string]: {
			Damage: BossStat,
			MaxHealthDamage?: BossStat,
			Speed: BossStat,
		}
	}
}
