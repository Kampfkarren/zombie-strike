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
	AfterSpawn: (this: this) => void
	Attack(): () => boolean
	Destroy: (this: this) => void
	GetAsset: (this: this, assetName: string) => Instance
	GetModel: () => Instance
	GiveXP: () => void
	InitializeAI: () => void
	SetupHumanoid: (this: this) => void
	Spawn: (position: Vector3) => Model
	TakeDamage: (this: this, damage: number) => void
}

export interface BossClass<Room extends Model> extends ZombieClass {
	GetXP(): number
	InitializeBossAI: (room: Room) => void
	SummonGoon: (this: BossClass<Room>, callback?: (zombie: ZombieClass) => void, forceType?: string) => void
}

declare class Zombie<C = Character> {
	static AttackCooldown: number
	static Model: string

	AttackRange: number
	Died: RBXScriptSignal

	alive: boolean
	aliveMaid: Maid
	aggroFocus: Character
	instance: C

	AfterSpawn(): void
	Aggro(): void
	AggroTargetChanged(newTarget?: Character): void
	Attack(): boolean
	CheckAttack(): boolean
	InitializeAI(): void
	GetAsset(assetName: string): Instance
	GiveBuff(scaleName: "Defense", amount: number): {
		Amount: number,
		Destroy: () => void,
	}
	GetScale(stat: string): number
	GetSpeed(): number
	ShouldSpawn(): boolean
	Spawn(position: Vector3): C
}
