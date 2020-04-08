import { Players, ReplicatedStorage, RunService, SoundService, Workspace } from "@rbxts/services"
import Common from "./Common"
import LineOfSight from "mission/ReplicatedStorage/Libraries/LineOfSight"
import { GetCenter } from "shared/ReplicatedStorage/Core/GetCharacterAttachment"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import OnDied from "shared/ReplicatedStorage/Core/OnDied"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"

const MAX_FORCE = 12000
const MAX_VELOCITY = 10
const JUMP_PUNISH = 1
const RANGE = 70

const isHooked = new Set()

function isJumping(humanoid: Humanoid): boolean {
	return humanoid.FloorMaterial === Enum.Material.Air
}

class Gravity extends Common {
	static Model = "Gravity"

	gravityHooks: Map<Player, Maid> = new Map()

	AfterSpawn() {
		super.AfterSpawn()

		this.aliveMaid.GiveTask(() => {
			for (const hook of this.gravityHooks.values()) {
				hook.DoCleaning()
			}
		})

		this.aliveMaid.GiveTask(RunService.Heartbeat.Connect(() => {
			for (const player of Players.GetPlayers()) {
				if (isHooked.has(player)) {
					continue
				}

				const character = player.Character as Character | undefined
				let inRange

				if (character === undefined) {
					inRange = false
				} else {
					inRange = LineOfSight(
						this.instance.PrimaryPart.Position,
						character,
						RANGE,
					)[0]
				}

				const gravityHook = this.gravityHooks.get(player)
				if ((gravityHook !== undefined) !== inRange) {
					if (inRange) {
						const hookMaid = new Maid()

						const sound = SoundService.ZombieSounds["2"].Gravity.Loop.Clone()
						sound.Parent = this.instance.PrimaryPart
						sound.Play()
						hookMaid.GiveTask(sound)

						const hook = new Instance("AlignPosition")
						hook.MaxForce = MAX_FORCE
						hook.MaxVelocity = MAX_VELOCITY
						hook.Responsiveness = 5
						hook.Attachment0 = GetCenter(character!)
						hook.Attachment1 = GetCenter(this.instance)
						hook.Parent = this.instance
						hookMaid.GiveTask(hook)

						const beam = ReplicatedStorage.Assets.Campaign.Campaign2.Gravity.Beam.Clone()
						beam.Attachment0 = GetCenter(this.instance)
						beam.Attachment1 = GetCenter(character!)
						beam.Parent = this.instance.PrimaryPart
						hookMaid.GiveTask(beam)

						const humanoid = character!.Humanoid

						const floorMaterialWatch = humanoid.GetPropertyChangedSignal("FloorMaterial")

						hookMaid.GiveTask(floorMaterialWatch.Connect(() => {
							if (isJumping(humanoid)) {
								RealDelay(JUMP_PUNISH, () => {
									if (hook.IsDescendantOf(Workspace) && isJumping(humanoid)) {
										hook.Enabled = false

										while (isJumping(humanoid)) {
											floorMaterialWatch.Wait()
										}

										hook.Enabled = true
									}
								})
							}
						}))

						hookMaid.GiveTask(() => {
							this.gravityHooks.delete(player)
							isHooked.delete(player)
						})

						hookMaid.GiveTask(OnDied(humanoid).Connect(() => {
							hookMaid.DoCleaning()
						}))

						this.gravityHooks.set(player, hookMaid)
						isHooked.add(player)
					} else if (gravityHook !== undefined) {
						gravityHook.DoCleaning()
					}
				}
			}
		}))
	}
}

export = Gravity
