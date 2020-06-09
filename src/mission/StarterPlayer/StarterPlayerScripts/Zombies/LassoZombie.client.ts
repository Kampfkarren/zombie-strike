import { Players, ReplicatedStorage, RunService, SoundService } from "@rbxts/services"
import Collection from "shared/ReplicatedStorage/Core/Collection"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import LookAt from "shared/ReplicatedStorage/Core/LookAt"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { Stun } from "shared/ReplicatedStorage/Core/Stun"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign5.Lasso

const LassoZombieEffect = ReplicatedStorage.Remotes.Zombies.LassoZombieEffect

const DROP_AT = 5
const LASSO_RANGE = 3
const LIFETIME = 2
const PULL_BACK_TIME = 0.3
const SPEED = [45, 50, 55, 55, 60]
const STUN = [0.25, 0.3, 0.33, 0.4, 0.45]

if (Dungeon.GetDungeonData("Campaign") === 5) {
	const difficulty = Dungeon.GetDungeonData("Difficulty") - 1

	const speed = SPEED[difficulty]
	const stunTime = STUN[difficulty]

	let shooting: Map<Instance, (character: Character) => void> = new Map()

	Collection("Zombie", zombie => {
		if (zombie.Name === "Lasso Zombie") {
			const maid = new Maid()
			maid.DieWith(zombie.WaitForChild("Humanoid") as Humanoid)

			const ropeBeam = zombie.WaitForChild("Rope") as Beam
			const rope = Assets.Rope.Clone()

			maid.GiveTask(RunService.Heartbeat.Connect(() => {
				if (ropeBeam.Attachment0 !== undefined) {
					const wasHooked = shooting.get(zombie)

					const position = ropeBeam.Attachment0.WorldPosition
					const angle = wasHooked !== undefined
						? CFrame.Angles(0, 0, math.pi / 2)
						: CFrame.Angles(0, math.pi / 2, 0)
					const cframe = new CFrame(position).mul(angle)
					rope.SetPrimaryPartCFrame(cframe)

					if (wasHooked !== undefined) {
						const character = Players.LocalPlayer.Character
						if (character !== undefined
							&& character.PrimaryPart !== undefined
							&& rope.PrimaryPart.Center.WorldPosition
								.sub(character.PrimaryPart.Position).Magnitude
							<= LASSO_RANGE
						) {
							PlayQuickSound(SoundService.ZombieSounds["5"].Lasso.Catch, character.PrimaryPart)
							wasHooked(character as Character)
						}
					}
				}
			}))

			rope.Parent = zombie

			maid.GiveTask(rope)
		}
	})

	LassoZombieEffect.OnClientEvent.Connect((zombie: Model, focus: Model) => {
		const humanoid = zombie.WaitForChild("Humanoid") as Humanoid
		const ropeBeam = zombie.WaitForChild("Rope") as Beam

		const maid = new Maid()
		maid.DieWith(humanoid)

		const dropLookAt = LookAt(zombie, focus)
		maid.GiveTask(dropLookAt)

		const primeAnimation = humanoid.LoadAnimation(Assets.Prime)
		primeAnimation.KeyframeReached.Connect(() => {
			if (humanoid.Health > 0) {
				dropLookAt()

				const oldAttachment = ropeBeam.Attachment0!

				const ropeAttachment = new Instance("Attachment")
				ropeAttachment.Parent = zombie.PrimaryPart
				ropeAttachment.WorldOrientation = oldAttachment.WorldOrientation
				ropeAttachment.WorldPosition = zombie.PrimaryPart!.Position

				ropeBeam.Attachment0 = ropeAttachment

				PlayQuickSound(SoundService.ZombieSounds["5"].Lasso.Throw, ropeAttachment)

				shooting.set(zombie, (character: Character) => {
					maid.DoCleaning()

					const alignMaid = new Maid()
					alignMaid.DieWith(humanoid)

					const stunPullAnimation = character.Humanoid.LoadAnimation(Assets.StunPull)
					stunPullAnimation.Play()
					alignMaid.GiveTaskAnimation(stunPullAnimation)

					const stunParticle = Assets.StunParticle.Clone()
					stunParticle.Parent = character.Head
					stunParticle.Emit(1)
					alignMaid.GiveTask(stunParticle)

					alignMaid.GiveTask(() => {
						const stunMaid = new Maid()

						const stunStillAnimation = character.Humanoid.LoadAnimation(Assets.StunStill)
						stunStillAnimation.Play()
						stunMaid.GiveTaskAnimation(stunStillAnimation)

						const stunActionParticle = Assets.StunAction.Clone()
						stunActionParticle.Parent = character.Head.HatAttachment
						stunMaid.GiveTaskParticleEffect(stunActionParticle)

						stunMaid.GiveTask(Stun())

						RealDelay(stunTime, () => {
							stunMaid.DoCleaning()
						})
					})

					const alignPosition = new Instance("AlignPosition")
					alignPosition.ApplyAtCenterOfMass = true
					alignPosition.RigidityEnabled = true
					alignPosition.Attachment0 = character.UpperTorso.BodyFrontAttachment
					alignPosition.Attachment1 = oldAttachment
					alignPosition.Parent = character.UpperTorso
					alignMaid.GiveTask(alignPosition)

					alignMaid.GiveTask(RunService.Heartbeat.Connect(() => {
						if (oldAttachment.WorldPosition
							.sub(character.PrimaryPart.Position)
							.Magnitude <= DROP_AT
						) {
							alignMaid.DoCleaning()
						}
					}))
				})

				maid.GiveTask(() => {
					shooting.delete(zombie)
				})

				maid.GiveTask(() => {
					const initial = ropeAttachment.WorldPosition

					if (humanoid.Health > 0) {
						let totalTime = 0
						const connection = RunService.Heartbeat.Connect(delta => {
							totalTime = math.min(PULL_BACK_TIME, totalTime + delta)
							const alpha = totalTime / PULL_BACK_TIME

							if (alpha >= 1) {
								ropeBeam.Attachment0 = oldAttachment
								ropeAttachment.Destroy()
								connection.Disconnect()
							} else {
								ropeAttachment.WorldPosition = initial.Lerp(oldAttachment.WorldPosition, alpha)
							}
						})
					}
				})

				const throwAnimationLoop = humanoid.LoadAnimation(Assets.ThrowLoop)
				throwAnimationLoop.Play()
				maid.GiveTaskAnimation(throwAnimationLoop)

				maid.GiveTask(() => {
					const pullAnimation = humanoid.LoadAnimation(Assets.Pull)
					pullAnimation.Play()
				})

				let totalTime = 0

				maid.GiveTask(RunService.Heartbeat.Connect(delta => {
					totalTime += delta

					if (totalTime > LIFETIME) {
						maid.DoCleaning()
					} else {
						ropeAttachment.WorldPosition = zombie.PrimaryPart!.Position
							.add(zombie.PrimaryPart!.CFrame.LookVector.mul(totalTime * speed))
					}
				}))
			}
		})
		primeAnimation.Play()
	})
}
