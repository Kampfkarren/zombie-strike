import { ReplicatedStorage } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"

function GetAssetsFolder(): Folder {
	if (Dungeon.GetDungeonData("Gamemode") === "Boss") {
		const roomName = Dungeon.GetDungeonData("BossInfo").RoomName
		const folder = ReplicatedStorage.Assets.Bosses as { [name: string]: Folder }
		return folder[roomName]
	} else {
		return ReplicatedStorage.Assets.Campaign[`Campaign${Dungeon.GetDungeonData("Campaign")}`]
	}
}

export = GetAssetsFolder
