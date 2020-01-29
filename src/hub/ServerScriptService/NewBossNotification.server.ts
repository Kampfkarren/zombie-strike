import { Players, ReplicatedStorage } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"
import GetCurrentBoss from "hub/ReplicatedStorage/Libraries/GetCurrentBoss"

Players.PlayerAdded.Connect((player) => {
	const [lastDefeatedBoss] = Data.GetPlayerData(player, "LastDefeatedBoss")
	if (lastDefeatedBoss !== GetCurrentBoss().Info.RoomName) {
		ReplicatedStorage.Remotes.NewBoss.FireClient(player)
	}
})
