import { ReplicatedStorage, StarterGui } from "@rbxts/services"

ReplicatedStorage.Remotes.SendServerLogs.OnClientEvent.Connect((message: string) => {
	StarterGui.SetCore("ChatMakeSystemMessage", {
		Text: message,
	})
})
