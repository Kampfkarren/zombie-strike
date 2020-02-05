import { Players, ReplicatedStorage } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"

const NewBoss = ReplicatedStorage.Remotes.NewBoss

Players.PlayerAdded.Connect((player) => {
	const timeBossDefeated = Data.GetPlayerData(player, "TimeBossDefeated")
	NewBoss.FireClient(player, timeBossDefeated)
})
