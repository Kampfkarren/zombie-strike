import { ZombieClass } from "./ZombieClass"

declare namespace Zombie {
	const Aggro: (zombie: ZombieClass) => void
	const GetDamageAgainstConstant: (zombie: ZombieClass | undefined, player: Player, damage: number, maxHpDamage: number) => number
	const InitializeAI: (zombie: ZombieClass) => void
	const Wander: (zombie: ZombieClass) => void
}

export = Zombie
