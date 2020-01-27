export interface ZombieClass {
	alive: boolean

	InitializeAI: () => void
	InitializeBossAI: (room: Model) => void
}

export interface BossClass extends ZombieClass {
	SummonGoon: (this: BossClass, zombie: ZombieClass) => void
}
