import { CollectionService, Players, ReplicatedStorage, SoundService, Workspace } from "@rbxts/services"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"

const PsychoAttack = BossLocalScriptUtil.WaitForBossRemote("PsychoAttack")

const ATTACK_LIFETIME = 1
const RANGE = new Vector3(20, 1, 500)

PsychoAttack.OnClientEvent.Connect((target: Character) => {
	const boss = CollectionService.GetTagged("Boss")[0] as Model & {
		Humanoid: Humanoid,
	}

	const psychoAnimation = boss.Humanoid.LoadAnimation(
		ReplicatedStorage
			.Assets
			.Bosses
			.Radioactive
			.Boss
			.PsychoAnimation
	)

	const position = boss.PrimaryPart!.Position
		.sub(new Vector3(0, 7.6, 0))
	const targetPosition = target.PrimaryPart!.Position

	const warning = ReplicatedStorage.Assets.Warning.Clone()
	warning.Color = new Color3(1, 1, 0)

	warning.CFrame = new CFrame(
		position,
		new Vector3(targetPosition.X, position.Y, targetPosition.Z),
	)

	warning.Size = RANGE
	warning.Parent = Workspace.Effects

	PlayQuickSound(SoundService.ZombieSounds.Radioactive.Boss.BeamReady)

	psychoAnimation.Play()
	psychoAnimation.KeyframeReached.Connect(() => {
		warning.Color = new Color3(1, 0, 0)

		let touched = false

		warning.Touched.Connect((part) => {
			const character = Players.LocalPlayer.Character

			if (character !== undefined && part.IsDescendantOf(character) && !touched) {
				touched = true
				PsychoAttack.FireServer()
			}
		})

		const character = Players.LocalPlayer.Character

		if (character !== undefined) {
			for (const alreadyTouchingPart of warning.GetTouchingParts()) {
				if (alreadyTouchingPart.IsDescendantOf(character)) {
					touched = true
					PsychoAttack.FireServer()
					break
				}
			}
		}

		PlayQuickSound(SoundService.ZombieSounds.Radioactive.Boss.BeamDamage)

		RealDelay(ATTACK_LIFETIME, () => {
			warning.Destroy()
		})
	})
})
