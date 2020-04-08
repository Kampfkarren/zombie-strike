import { Players, ReplicatedStorage, SoundService } from "@rbxts/services"
import GetCharacter from "shared/ReplicatedStorage/Core/GetCharacter"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import { Stun } from "shared/ReplicatedStorage/Core/Stun"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign2.Taser
const LocalPlayer = Players.LocalPlayer
const TaserZombieEffect = ReplicatedStorage.Remotes.Zombies.TaserZombieEffect

const WHITE = new ColorSequence(new Color3(1, 1, 1))
const YELLOW = new ColorSequence(new Color3(1, 1, 0))

const COLOR_SHIFT_INTERVAL = 0.05

type TaserZombie = Model & {
	Humanoid: Humanoid,
	Taser: Model & {
		Taser: BasePart & {
			Beam: Beam,
			Sound: Sound,
		},
	},
}

const tasers: Map<TaserZombie, Maid> = new Map()

TaserZombieEffect.OnClientEvent.Connect((
	zombie: TaserZombie,
	enabled: boolean,
) => {
	if (enabled) {
		const maid = new Maid(true)

		// Play animation for zombie
		const tasering = zombie.Humanoid.LoadAnimation(Assets.Tasering)
		tasering.Play()
		maid.DieWith(zombie.Humanoid)
		maid.GiveTaskAnimation(tasering)

		const waitForKeyframe = tasering.KeyframeReached.Connect(() => {
			waitForKeyframe.Disconnect()

			const taser = zombie.Taser.Taser

			const characterBeingTased = GetCharacter(taser.Beam.Attachment0!)

			// Play animation for player being tased
			if (characterBeingTased !== undefined) {
				const taseredAnimation = characterBeingTased.Humanoid.LoadAnimation(Assets.Tased)
				taseredAnimation.Play()
				maid.GiveTaskAnimation(taseredAnimation)
				maid.DieWith(characterBeingTased.Humanoid)
			}

			// Enable beam
			taser.Beam.Enabled = true
			maid.GiveTask(() => {
				taser.Beam.Enabled = false
			})

			// Beam effect
			let white = true
			maid.GiveTask(Interval(COLOR_SHIFT_INTERVAL, () => {
				white = !white
				taser.Beam.Color = white ? WHITE : YELLOW
			}))

			// Play sound
			taser.Sound.Play()
			maid.GiveTask(() => {
				taser.Sound.Stop()
			})

			// Play loop
			const loop = SoundService.ZombieSounds["2"].Taser.Loop.Clone()
			loop.Parent = LocalPlayer.Character!.PrimaryPart
			loop.Play()
			maid.GiveTask(loop)

			if (characterBeingTased === LocalPlayer.Character) {
				maid.GiveTask(Stun())
			}
		})

		maid.GiveTask(waitForKeyframe)

		tasers.set(zombie, maid)
	} else {
		const maid = tasers.get(zombie)
		if (maid !== undefined) {
			maid.DoCleaning()
			tasers.delete(zombie)
		}
	}
})
