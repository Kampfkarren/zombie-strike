export interface ZombieClass {
	alive: boolean

	InitializeAI: () => void
}

export interface BossClass<Room extends Model> extends ZombieClass {
	InitializeBossAI: (room: Room) => void
	SummonGoon: (this: BossClass<Room>, zombie: ZombieClass) => void
}
