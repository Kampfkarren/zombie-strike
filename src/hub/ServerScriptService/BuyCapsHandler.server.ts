import { ReplicatedStorage } from "@rbxts/services"
import Analytics from "shared/ServerScriptService/Analytics"
import CapsDictionary from "hub/ReplicatedStorage/CapsDictionary"
import Data from "shared/ReplicatedStorage/Core/Data"

const BuyCaps = ReplicatedStorage.Remotes.BuyCaps

BuyCaps.OnServerEvent.Connect((player, nonce, index) => {
	if (!typeIs(index, "number")) {
		warn("BuyCaps: attempting to buy non number caps")
		return
	}

	if (!typeIs(nonce, "number")) {
		warn("BuyCaps: attempting to buy with bad nonce")
		return
	}

	const product = CapsDictionary[index - 1]
	const [brains, brainsStore] = Data.GetPlayerData(player, "Brains")

	if (product.Cost > brains) {
		warn("BuyCaps: player didn't have enough brains")
		return
	}

	const [_, capsStore] = Data.GetPlayerData(player, "Gold")
	brainsStore.Increment(-product.Cost)
	capsStore.Increment(product.Caps)
	BuyCaps.FireClient(player, nonce)
	Analytics.CapsBought(player, product.Caps)
})
