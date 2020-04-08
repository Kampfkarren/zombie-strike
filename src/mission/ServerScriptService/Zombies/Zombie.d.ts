// this is so stupid
import { Zombie as ZombieClass, ZombieClass as ZombieInterface } from "./ZombieClass"

type ZombieInstance = ZombieClass | ZombieInterface

declare namespace Zombie {
	const Aggro: (zombie: ZombieInstance) => void
	const CheckAttack: (zombie: ZombieInstance) => boolean
	const GetDamageAgainstConstant: (zombie: ZombieInstance | undefined, player: Player, damage: number, maxHpDamage: number) => number
	const InitializeAI: (zombie: ZombieInstance) => void
	const Wander: (zombie: ZombieInstance) => void
	const Spawn: <C>(zombie: ZombieClass<C>, position: Vector3) => C

	const GetAliveZombies: () => ZombieInstance[]
}

export = Zombie
