import Zombie from "mission/ServerScriptService/Zombies/Zombie"
import { ZombieClass } from "../Zombies/ZombieClass"

declare namespace Gamemode {
	export const EndMission: (this: void) => void
	export const SpawnBoss: (this: void, bossSequence: BossSequence, position: Vector3, room: Model) => ZombieClass
}

export = Gamemode
