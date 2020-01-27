export type GamemodeReward = {
	GamemodeLoot: true,
} & ({
	Type: "Brains",
	Brains: number,
})

export declare interface Gamemode {
	Countdown(this: void, time: number): void
	GenerateLootItem?: (this: void, player: Player) => GamemodeReward | undefined
}

export declare interface GamemodeInfo {
	Lives?: number,
	DifficultyInfo?: {
		Gold: number,
		XP: number,
	},
}

export declare interface GamemodeConstructor {
	Init(this: void): Gamemode
}
