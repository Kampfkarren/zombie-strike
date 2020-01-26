import { ReplicatedStorage, ServerStorage, Workspace } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import DungeonState from "mission/ServerScriptService/DungeonState"
import { Gamemode as GamemodeType, GamemodeConstructor } from "mission/ReplicatedStorage/GamemodeInfo/Gamemode"
import Gamemode from "./Gamemode"

const bossInfo = Dungeon.GetDungeonData("BossInfo")

function spawnBossRoom() {
	const rooms = new Instance("Folder")
	rooms.Name = "Rooms"

	const room = ServerStorage.BossRooms[bossInfo.RoomName].Clone()
	room.Name = "StartSection"
	room.Parent = rooms

	rooms.Parent = Workspace

	return room
}

const BossConstructor: GamemodeConstructor = {
	Init(this: void): GamemodeType {
		const bossRoom = spawnBossRoom()
		DungeonState.CurrentSpawn = bossRoom.FindFirstChild("SpawnLocation", true) as SpawnLocation

		return {
			Countdown(this: void, time) {
				if (time === 0) {
					const bossSequence = require(ReplicatedStorage.BossSequences[bossInfo.RoomName]) as BossSequence
					const position = (assert(
						bossRoom.FindFirstChild("BossSpawn", true),
						"No BossSpawn found",
					) as Attachment).WorldPosition

					Gamemode.SpawnBoss(bossSequence, position, bossRoom)
				}
			},
		}
	},
}

export = BossConstructor
