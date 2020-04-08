import { Players, ReplicatedStorage, RunService, SoundService, Workspace } from "@rbxts/services"
import Collection from "shared/ReplicatedStorage/Core/Collection"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import LineOfSight from "mission/ReplicatedStorage/Libraries/LineOfSight"
import LookAt from "shared/ReplicatedStorage/Core/LookAt"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import OnDied from "shared/ReplicatedStorage/Core/OnDied"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"

const COLOR_RED = new Color3(1, 0, 0)
const COLOR_YELLOW = new Color3(1, 1, 0.5)

const DANGER_LEEWAY = 0.1
const RANGE = 300
const TIME_BEFORE_SHOT = 6

if (Dungeon.GetDungeonData("Campaign") === 5) {
	Collection("Zombie", instance => {
		if (instance.Name === "Sniper Zombie") {
			const zombie = instance as Model

			const maid = new Maid()
			maid.DieWith(zombie.WaitForChild("Humanoid") as Humanoid)

			const muzzle = zombie
				.WaitForChild("Gun")
				.WaitForChild("Handle")
				.WaitForChild("Muzzle") as Attachment

			const beam = new Instance("Beam")
			beam.Attachment0 = muzzle
			beam.Color = new ColorSequence(COLOR_YELLOW)
			beam.FaceCamera = true
			beam.TextureSpeed = 0
			beam.Width0 = 0.1
			beam.Parent = muzzle
			maid.GiveTask(beam)

			const countdown = SoundService.ZombieSounds["5"].Sniper.Countdown.Clone()
			countdown.Parent = Workspace
			maid.GiveTask(countdown)

			let lockedOn = false

			function hookCharacter(character: Character) {
				maid.GiveTask(LookAt(zombie, character))
				maid.GiveTask(OnDied(character.WaitForChild("Humanoid") as Humanoid).Connect(() => {
					lockedOn = false
					beam.Attachment1 = undefined
				}))
			}

			let character = Players.LocalPlayer.Character as Character | undefined
			if (character !== undefined) {
				hookCharacter(character)
			}

			maid.GiveTask(Players.LocalPlayer.CharacterAdded.Connect(character => {
				hookCharacter(character as Character)
			}))

			let totalTime = 0

			maid.GiveTask(RunService.Heartbeat.Connect(delta => {
				if (lockedOn) {
					totalTime += delta

					if (totalTime >= TIME_BEFORE_SHOT) {
						totalTime %= TIME_BEFORE_SHOT
						ReplicatedStorage.Remotes.Zombies.SniperZombieEffect.FireServer()

						countdown.Play()
						PlayQuickSound(SoundService.ZombieSounds["5"].Sniper.Shot)
					}

					const alpha = totalTime / TIME_BEFORE_SHOT

					const keypoints = [
						new ColorSequenceKeypoint(0, COLOR_YELLOW),
						new ColorSequenceKeypoint(math.max(0.005, alpha - DANGER_LEEWAY), COLOR_YELLOW),
						new ColorSequenceKeypoint(math.clamp(alpha, 0.006, 0.994), COLOR_RED),
						new ColorSequenceKeypoint(math.min(0.995, alpha + DANGER_LEEWAY), COLOR_YELLOW),
						new ColorSequenceKeypoint(1, COLOR_YELLOW),
					]

					beam.Color = new ColorSequence(keypoints)
				} else {
					character = Players.LocalPlayer.Character as Character | undefined

					if (character !== undefined
						&& character.PrimaryPart !== undefined
						&& LineOfSight(muzzle.WorldPosition, character, RANGE, [zombie, Workspace.Zombies])[0]
					) {
						lockedOn = true
						countdown.Play()
						beam.Attachment1 = character.Head.FaceCenterAttachment
					}
				}
			}))
		}
	})
}
