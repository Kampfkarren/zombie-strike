import Zombie from "mission/ServerScriptService/Zombies/Zombie"
import { Zombie as ZombieInstance, ZombieClass } from "../Zombies/ZombieClass"

declare namespace Gamemode {
	export const EndMission: (this: void) => void
	export const SpawnBoss: (this: void, bossSequence: BossSequence, position: Vector3 | undefined, room: Model) => ZombieClass
	export function SpawnZombie(zombieType: string, level: number, position: Vector3): ZombieInstance | undefined
}

export = Gamemode
