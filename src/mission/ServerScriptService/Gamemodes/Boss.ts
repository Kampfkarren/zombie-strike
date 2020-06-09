import { Players, ReplicatedStorage, ServerScriptService, ServerStorage, StarterPlayer, Workspace } from "@rbxts/services"
import Data from "shared/ReplicatedStorage/Core/Data"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import DungeonState from "mission/ServerScriptService/DungeonState"
import { Gamemode as GamemodeType, GamemodeConstructor, GamemodeReward } from "mission/ReplicatedStorage/GamemodeInfo/Gamemode"
import Gamemode from "./Gamemode"
import GetAvailableMissions from "shared/ReplicatedStorage/Core/GetAvailableMissions"

const REWARDS_MISSIONS_BEHIND = 2

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
					const bossSpawn = bossRoom.FindFirstChild("BossSpawn", true) as Attachment | undefined
					const position = bossSpawn && bossSpawn.WorldPosition

					const boss = Gamemode.SpawnBoss(bossSequence, position, bossRoom)
					boss.Died.Connect(Gamemode.EndMission)
				}
			},

			GenerateLootItem(this: void, player: Player) {
				const [timeBossDefeated, timeBossDefeatedStore] = Data.GetPlayerData(player, "TimeBossDefeated")
				const time = os.time()

				if (time - timeBossDefeated >= 24 * 60 * 60) {
					timeBossDefeatedStore.Set(time)
					return {
						GamemodeLoot: true,
						Type: "Brains",
						Brains: 100,
					}
				} else {
					return undefined
				}
			},

			GetEndRewards(this: void, player: Player) {
				const missions = GetAvailableMissions(player)

				let earlierMission
				for (let index = REWARDS_MISSIONS_BEHIND; index > 0; index--) {
					const nearbyMission = missions[missions.size() - index]
					if (nearbyMission !== undefined) {
						earlierMission = nearbyMission
						break
					}
				}

				return {
					...assert(earlierMission, "No earlier mission?"),
					Gold: Dungeon.GetGamemodeInfo().DifficultyInfo!.Gold,
				}
			},

			Scales(this: void) {
				return true
			}
		}
	},
}

export = BossConstructor
