import { ReplicatedStorage, ServerScriptService } from "@rbxts/services"
import { ZombieClass } from "mission/ServerScriptService/Zombies/ZombieClass"

let DealZombieDamage: (humanoid: Humanoid, damage: number) => void

type Zombie = {
	GetAliveZombies: () => ZombieClass[]
}

if (ReplicatedStorage.HubWorld.Value) {
	DealZombieDamage = function(humanoid, damage) {
		humanoid.TakeDamage(damage)
	}
} else {
	const Zombie: Zombie = require(ServerScriptService.Zombies.Zombie) as Zombie

	DealZombieDamage = function(humanoid, damage) {
		for (const zombie of Zombie.GetAliveZombies()) {
			if (zombie.instance.Humanoid === humanoid) {
				zombie.TakeDamage(damage)
				return
			}
		}

		// This is the case for the shields of shield zombies
		humanoid.TakeDamage(damage)
	}
}

export = DealZombieDamage
