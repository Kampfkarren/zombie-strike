import { Players, RunService, SoundService } from "@rbxts/services"
import Common from "./Common"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import LineOfSight from "mission/ReplicatedStorage/Libraries/LineOfSight"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

class Flamecaster extends Common {
	static Model = "Flamecaster"

	burningCharacters: Map<Player, Model> = new Map()
	castAnimation?: AnimationTrack

	AfterSpawn() {
		this.castAnimation = this.instance.Humanoid.LoadAnimation(this.GetAsset("Cast") as Animation)
	}

	Attack() {
		return true
	}

	InitializeAI() {
		if (this.GetSpeed() > 0) {
			Zombie.InitializeAI(this)
			this.Aggro()
		}

		this.aliveMaid.GiveTask(Interval(1, () => {
			for (const [player, character] of this.burningCharacters.entries()) {
				if (character === player.Character) {
					TakeDamage(player, this.GetScale("Damage"))
				}
			}
		}))

		this.aliveMaid.GiveTask(RunService.Heartbeat.Connect((delta) => {
			for (const player of Players.GetPlayers()) {
				const burningCharacter = this.burningCharacters.get(player)
				const character = player.Character as Character | undefined

				if (character !== undefined) {
					if (burningCharacter !== character
						&& LineOfSight(this.instance.PrimaryPart.Position, character, this.GetScale("Range"))[0]
					) {
						const maid = new Maid()
						maid.GiveTask(() => {
							this.burningCharacters.delete(player)
						})

						const flamesParticle = this.GetAsset("Flames").Clone() as ParticleEmitter
						flamesParticle.Parent = character.UpperTorso
						maid.GiveTaskParticleEffect(flamesParticle)

						const circleParticle = this.GetAsset("Circle").Clone() as ParticleEmitter
						circleParticle.Parent = character.UpperTorso.BodyFrontAttachment
						maid.GiveTaskParticleEffect(circleParticle)

						const beam = this.GetAsset("Beam").Clone() as Beam
						beam.Attachment0 = this.instance.UpperTorso.BodyFrontAttachment
						beam.Attachment1 = character.UpperTorso.BodyFrontAttachment
						beam.Parent = beam.Attachment0

						const castSound = SoundService.ZombieSounds["3"].Flamecaster.Cast.Clone()
						castSound.Parent = beam.Attachment0
						castSound.Play()

						const loopSound = SoundService.ZombieSounds["3"].Flamecaster.Loop.Clone()
						loopSound.Parent = beam.Attachment1
						loopSound.Play()
						maid.GiveTask(loopSound)

						this.aliveMaid.GiveTask(maid)
						maid.DieWith(character.Humanoid)

						this.burningCharacters.set(player, character)

						if (this.castAnimation !== undefined) {
							this.castAnimation.Play()
						}
					}
				}
			}
		}))
	}
}

export = Flamecaster
