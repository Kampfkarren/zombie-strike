import { CollectionService, Players, Workspace } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import DungeonState from "mission/ServerScriptService/DungeonState"
import Gamemode from "mission/ServerScriptService/Gamemodes/Gamemode"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { Zombie } from "mission/ServerScriptService/Zombies/ZombieClass"

const SPECIAL_ZOMBIE_SUMMON_RATE = 0.1

const TELEPORT_DELAY_TIME = 3

const ZOMBIE_IDLE_DEFENSE_BUFF = 0.5
const ZOMBIE_IDLE_TIME = 1.75
const ZOMBIE_SPAWN_INTERVAL = 1.5

const ZOMBIES_ACTIVE = [ 6, 7, 7, 8, 8 ]
const ZOMBIES_TO_KILL = [ 18, 22, 26, 30, 32 ]

type WaveRoom = Model & {
	ArenaBlocker: BasePart,
	Inside: BasePart,
	PrimaryPart: BasePart,
}

function zombieChoices(): string[] {
	const choices = []

	for (const [zombieType, weight] of Dungeon.GetDungeonData("CampaignInfo").ZombieTypes.entries()) {
		for (let _ = 0; _ < weight; _++) {
			choices.push(zombieType)
		}
	}

	return choices
}

function teleportEveryone(waveRoom: WaveRoom) {
	const currentSpawn = DungeonState.CurrentSpawn as Attachment

	waveRoom.Inside.Touched.Connect(() => {})

	for (const player of Players.GetPlayers()) {
		if (player.Character !== undefined
			&& player.Character.PrimaryPart !== undefined
		) {
			if (!player.Character.PrimaryPart.GetTouchingParts().includes(waveRoom.Inside)) {
				player.Character.MoveTo(currentSpawn.WorldPosition)
			}
		}
	}
}

export function ZombiesToKill(): number {
	return ZOMBIES_TO_KILL[Dungeon.GetDungeonData("Difficulty") - 1]
}

export function StartWaveDefenseRoom(waveRoom: WaveRoom): Promise<void> {
	return new Promise((resolve) => {
		const arenaBlocker = waveRoom.ArenaBlocker
		arenaBlocker.Parent = undefined

		RealDelay(TELEPORT_DELAY_TIME, () => {
			arenaBlocker.Parent = Workspace

			const spawnPoints: Attachment[] = []
			for (const spawnPoint of waveRoom.PrimaryPart.GetChildren()) {
				if (spawnPoint.Name === "ZombieSpawn") {
					spawnPoints.push(spawnPoint as Attachment)
				}
			}

			let zombiesLeft = ZombiesToKill()
			let aliveZombies = 0

			function spawnZombie() {
				const zombiePool = (math.random() <= SPECIAL_ZOMBIE_SUMMON_RATE
					&& !DungeonState.CurrentGamemode.SpecialZombies.isEmpty())
					? DungeonState.CurrentGamemode.SpecialZombies
					: zombieChoices()

				let zombie: Zombie | undefined

				do {
					zombie = Gamemode.SpawnZombie(
						zombiePool[math.random(zombiePool.size()) - 1],
						Dungeon.RNGZombieLevel(),
						spawnPoints[math.random(spawnPoints.size()) - 1].WorldPosition,
					)
				} while (zombie === undefined)

				CollectionService.AddTag(zombie.instance, "WaveDefenseZombie")
				zombie.instance.PrimaryPart.Anchored = true

				const buff = zombie.GiveBuff("Defense", ZOMBIE_IDLE_DEFENSE_BUFF)

				RealDelay(ZOMBIE_IDLE_TIME, () => {
					if (zombie === undefined) {
						throw "UNREACHABLE"
					}

					if (!zombie.alive) {
						return
					}

					buff.Destroy()
					zombie.instance.PrimaryPart.Anchored = false
					zombie.Aggro()
				})

				zombie.Died.Connect(() => {
					aliveZombies -= 1
					if (zombiesLeft === 0 && aliveZombies === 0) {
						resolve()
					}
				})
			}

			const activeZombiesNeeded = ZOMBIES_ACTIVE[Dungeon.GetDungeonData("Difficulty") - 1]

			// This could be optimized to only check after a zombie dies
			Interval(ZOMBIE_SPAWN_INTERVAL, () => {
				if (aliveZombies < activeZombiesNeeded) {
					spawnZombie()
					aliveZombies += 1
					zombiesLeft -= 1

					if (zombiesLeft === 0) {
						return false
					}
				}
			})

			teleportEveryone(waveRoom)
		})
	})
}
