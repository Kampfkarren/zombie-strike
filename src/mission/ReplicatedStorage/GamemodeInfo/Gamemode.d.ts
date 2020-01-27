export declare interface Gamemode {
	Countdown(this: void, time: number): void
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
