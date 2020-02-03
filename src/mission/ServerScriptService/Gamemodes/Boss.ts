import { Players, ReplicatedStorage, ServerScriptService, ServerStorage, StarterPlayer, Workspace } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import DungeonState from "mission/ServerScriptService/DungeonState"
import { Gamemode as GamemodeType, GamemodeConstructor, GamemodeReward } from "mission/ReplicatedStorage/GamemodeInfo/Gamemode"
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

		const localScriptsFolder = ServerScriptService.BossLocalScripts.FindFirstChild(bossInfo.RoomName)

		if (localScriptsFolder !== undefined) {
			for (const localScript of localScriptsFolder.GetChildren()) {
				localScript.Clone().Parent = StarterPlayer.StarterPlayerScripts

				for (const player of Players.GetPlayers()) {
					localScript.Clone().Parent = player.WaitForChild("PlayerGui")
				}
			}
		}

		return {
			Countdown(this: void, time) {
				if (time === 0) {
					const bossSequence = require(ReplicatedStorage.BossSequences[bossInfo.RoomName]) as BossSequence
					const position = (assert(
						bossRoom.FindFirstChild("BossSpawn", true),
						"No BossSpawn found",
					) as Attachment).WorldPosition

					const boss = Gamemode.SpawnBoss(bossSequence, position, bossRoom)
					boss.Died.Connect(Gamemode.EndMission)
				}
			},

			GenerateLootItem(this: void, player: Player): GamemodeReward | undefined {
				// This method sucks, if a player plays a boss, doesn't play for a while,
				// and comes back and it's the same boss, then they won't get brains.

				// const [lastDefeatedBoss, lastDefeatedBossStore] = Data.GetPlayerData(player, "LastDefeatedBoss")
				// if (lastDefeatedBoss !== bossInfo.RoomName) {
				// 	lastDefeatedBossStore.Set(bossInfo.RoomName)
				// 	return {
				// 		GamemodeLoot: true,
				// 		Type: "Brains",
				// 		Brains: 100,
				// 	}
				// } else {
				// 	return undefined
				// }

				warn("NYI: Boss.GenerateLootItem")
				return undefined
			}
		}
	},
}

export = BossConstructor
