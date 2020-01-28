export interface ZombieClass {
	alive: boolean
	instance: Character

	Died: RBXScriptSignal

	AfterDeath: () => void
	AfterSpawn: () => void
	Destroy: (this: this) => void
	GetAsset: (this: this, assetName: string) => Instance
	GiveXP: () => void
	InitializeAI: () => void
}

export interface BossClass<Room extends Model> extends ZombieClass {
	GetXP(): number
	InitializeBossAI: (room: Room) => void
	SummonGoon: (this: BossClass<Room>, callback?: (zombie: ZombieClass) => void, forceType?: string) => void
}
