import { LootReward } from "types/Gamemode"

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

	Loot: LootReward,

	Stats: {
		[zombieName: string]: {
			Damage: BossStat,
			MaxHealthDamage?: BossStat,
			Speed: BossStat,
		}
	}
}
