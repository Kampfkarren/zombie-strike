import { Players, ReplicatedStorage, RunService, Workspace } from "@rbxts/services"
import Collection from "shared/ReplicatedStorage/Core/Collection"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import GiveSpeedMultiplier from "shared/ReplicatedStorage/Core/GiveSpeedMultiplier"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import OnDied from "shared/ReplicatedStorage/Core/OnDied"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign4.Blizzard
const LocalPlayer = Players.LocalPlayer

const ROTATION_SPEED = 1
const SLOW = [0.20, 0.22, 0.24, 0.28, 0.30]

if (Dungeon.GetDungeonData("Campaign") === 4) {
	const maids: Map<Model, Maid> = new Map()
	const ranges: Map<Model, typeof Assets["Range"]> = new Map()

	let rangeConnection: RBXScriptConnection | undefined

	function updateRanges(delta: number) {
		const character = LocalPlayer.Character as Character | undefined
		let position: Vector3 | undefined

		if (character !== undefined && character.PrimaryPart !== undefined) {
			position = character.PrimaryPart.Position
		}

		for (const [zombie, range] of ranges.entries()) {
			if (zombie.PrimaryPart !== undefined) {
				const zombiePosition = zombie.PrimaryPart.Position
				range.Position = zombiePosition
				range.CFrame = range.CFrame.mul(CFrame.Angles(0, delta * ROTATION_SPEED, 0))

				let maid = maids.get(zombie)

				const inRange = character !== undefined
					&& position !== undefined
					&& position.sub(zombiePosition).Magnitude <= range.Size.X / 2

				if (inRange && maid === undefined) {
					maid = new Maid()

					const particle = Assets.SlowedParticle.Clone()
					particle.Parent = character!.PrimaryPart

					maid.GiveTask(GiveSpeedMultiplier(
						-(
							Dungeon.GetDungeonData("Gamemode") === "Mission"
								? SLOW[Dungeon.GetDungeonData("Difficulty") - 1]
								: SLOW[1]
						)
					))
					maid.GiveTaskParticleEffect(particle)

					maid.DieWith(character!.Humanoid)
					maid.DieWith(zombie.WaitForChild("Humanoid") as Humanoid)

					maid.GiveTask(() => {
						maids.delete(zombie)
					})

					maids.set(zombie, maid)
				} else if (!inRange && maid !== undefined) {
					print("out of range")
					maid.DoCleaning()
				}
			}
		}
	}

	Collection("Zombie", instance => {
		const zombie = instance as Model
		if (zombie.Name === "Blizzard Zombie") {
			const range = Assets.Range.Clone()
			range.Parent = Workspace
			range.Gust.Play()

			if (ranges.isEmpty()) {
				rangeConnection = RunService.Heartbeat.Connect(updateRanges)
			}

			ranges.set(zombie, range)

			const humanoid = zombie.WaitForChild("Humanoid") as Humanoid
			OnDied(humanoid).Connect(() => {
				range.Destroy()
				ranges.delete(zombie)

				if (ranges.isEmpty() && rangeConnection !== undefined) {
					rangeConnection.Disconnect()
					rangeConnection = undefined

					const maid = maids.get(zombie)
					if (maid !== undefined) {
						maid.DoCleaning()
					}
				}
			})
		}
	})
}
