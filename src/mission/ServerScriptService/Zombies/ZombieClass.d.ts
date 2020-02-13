import Maid from "shared/ReplicatedStorage/Core/Maid"

export interface ZombieClass {
	alive: boolean
	aliveMaid: Maid
	instance: Character & {
		Humanoid: {
			DamageReceivedScale: NumberValue,
		},
	}

	Died: RBXScriptSignal

	Aggro: (this: this) => void
	AfterDeath: () => void
	AfterSpawn: () => void
	Attack(): () => boolean
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
