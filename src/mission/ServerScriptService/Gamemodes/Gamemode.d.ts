import Zombie from "mission/ServerScriptService/Zombies/Zombie"

declare namespace Gamemode {
	export const SpawnBoss: (this: void, bossSequence: BossSequence, position: Vector3, room: Model) => Zombie
}

export = Gamemode
