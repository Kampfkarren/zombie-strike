export declare interface Gamemode {
	Countdown(this: void, time: number): void
}

export declare interface GamemodeInfo {
	Lives?: number,
}

export declare interface GamemodeConstructor {
	Init(this: void): Gamemode
}
