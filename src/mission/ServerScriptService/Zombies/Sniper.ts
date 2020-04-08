import { CollectionService, ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import DungeonState from "mission/ServerScriptService/DungeonState"
import Equip from "shared/ServerScriptService/Ruddev/Equip"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

const openSniperSpots: Map<Model, Attachment[]> = new Map<Model, Attachment[]>()

let connected = false

type SniperZombie = Character & {
	Gun: Model,
}

class Sniper extends Common<SniperZombie> {
	static Model = "Sniper"

	AfterSpawn() {
		Equip(this.instance.Gun)
		this.instance.PrimaryPart.Anchored = true

		if (!connected) {
			connected = true
			ReplicatedStorage.Remotes.Zombies.SniperZombieEffect.OnServerEvent.Connect(player => {
				TakeDamage(player, this.GetScale("Damage"))
			})
		}
	}

	InitializeAI() { }

	Spawn(): SniperZombie {
		const room = DungeonState.CurrentRoom!
		const attachments = assert(openSniperSpots.get(room), "Spawn called on sniper without any available spots!")
		const spawnPoint = attachments.unorderedRemove(math.random(0, attachments.size() - 1))!
		return Zombie.Spawn(this, spawnPoint.WorldPosition)
	}

	ShouldSpawn() {
		const room = DungeonState.CurrentRoom!
		let sniperSpots = openSniperSpots.get(room)

		if (sniperSpots === undefined) {
			sniperSpots = []

			for (const sniperSpot of CollectionService.GetTagged("SniperSpot")) {
				if (sniperSpot.IsDescendantOf(room)) {
					sniperSpots.push(sniperSpot as Attachment)
				}
			}

			openSniperSpots.set(room, sniperSpots)
		}

		return !sniperSpots.isEmpty()
	}
}

export = Sniper
