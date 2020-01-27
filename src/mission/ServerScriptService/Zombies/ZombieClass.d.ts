export interface ZombieClass {
	alive: boolean
	instance: Character

	Died: RBXScriptSignal

	AfterSpawn: () => void
	InitializeAI: () => void
}

export interface BossClass<Room extends Model> extends ZombieClass {
	GetXP(): number
	InitializeBossAI: (room: Room) => void
	SummonGoon: (this: BossClass<Room>, callback?: (zombie: ZombieClass) => void, forceType?: string) => void
}
