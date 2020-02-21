import { Players, ReplicatedStorage, ReplicatedFirst } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"

const LocalPlayer = Players.LocalPlayer

ReplicatedStorage.Remotes.UpdateCampaignsPlayed.OnClientEvent.Connect((campaignsPlayed) => {
	Data.SetLocalPlayerData("CampaignsPlayed", campaignsPlayed as {})
})

const level = LocalPlayer.WaitForChild("PlayerData").WaitForChild("Level") as NumberValue
Data.SetLocalPlayerData("Level", level.Value)
level.Changed.Connect((newLevel) => {
	Data.SetLocalPlayerData("Level", newLevel)
})
