import { Players } from "@rbxts/services"
import Collection from "shared/ReplicatedStorage/Core/Collection"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import LookAt from "shared/ReplicatedStorage/Core/LookAt"

const LocalPlayer = Players.LocalPlayer

if (Dungeon.GetDungeonData("Campaign") === 3) {
	Collection("Zombie", (instance) => {
		const zombie = instance as Character

		if (zombie.Name === "Flamecaster Zombie"
			&& LocalPlayer.Character !== undefined
			&& Dungeon.GetDungeonData("Gamemode") !== "Arena"
		) {
			LookAt(zombie, LocalPlayer.Character)
		}
	})
}
