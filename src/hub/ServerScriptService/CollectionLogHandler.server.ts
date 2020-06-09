import { Players, ReplicatedStorage } from "@rbxts/services"
import inspect from "shared/ReplicatedStorage/Core/inspect"
import Analytics from "shared/ServerScriptService/Analytics"
import Data from "shared/ReplicatedStorage/Core/Data"

const UpdateCollectionLog = ReplicatedStorage.Remotes.UpdateCollectionLog

function getLogOfInventory(player: Player): Map<string, Set<number>> {
	const log: Map<string, Set<number>> = new Map()
	log.set("Perks", new Set())

	const [inventory] = Data.GetPlayerData(player, "Inventory")
	for (const item of inventory) {
		if (log.get(item.Type) === undefined) {
			log.set(item.Type, new Set())
		}

		if (item.Perks !== undefined) {
			for (const perk of item.Perks) {
				log.get("Perks")!.add(perk[0])
			}
		}

		log.get(item.Type)!.add(item.Model)
	}

	return log
}

function updatePlayerLog(player: Player) {
	const [collectionLog, collectionLogStore] = Data.GetPlayerData(player, "CollectionLog")

	const currentLog = getLogOfInventory(player)
	for (const [itemType, models] of Object.entries(currentLog)) {
		if (collectionLog[itemType] === undefined) {
			collectionLog[itemType] = models.values()
		} else {
			collectionLog[itemType] = models.union(new Set(collectionLog[itemType])).values()
		}
	}

	collectionLogStore.Set(collectionLog)
}

Players.PlayerAdded.Connect((player) => {
	updatePlayerLog(player)
	const [_, inventoryStore] = Data.GetPlayerData(player, "Inventory")
	inventoryStore.OnUpdate(() => {
		updatePlayerLog(player)
	})
})

UpdateCollectionLog.OnServerEvent.Connect((player) => {
	const [collectionLog] = Data.GetPlayerData(player, "CollectionLog")
	UpdateCollectionLog.FireClient(player, collectionLog)
	Analytics.CollectionLogRequested(player)
})
