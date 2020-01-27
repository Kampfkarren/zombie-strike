import { ZombieClass } from "./ZombieClass"

declare namespace Zombie {
	const GetDamageAgainstConstant: (zombie: ZombieClass | undefined, player: Player, damage: number, maxHpDamage: number) => number
}

export = Zombie
