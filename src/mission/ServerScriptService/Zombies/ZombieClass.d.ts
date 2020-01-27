export interface ZombieClass {
	alive: boolean
	instance: Model

	AfterSpawn: () => void
	InitializeAI: () => void
}

export interface BossClass<Room extends Model> extends ZombieClass {
	InitializeBossAI: (room: Room) => void
	SummonGoon: (this: BossClass<Room>, callback?: (zombie: ZombieClass) => void, forceType?: string) => void
}
