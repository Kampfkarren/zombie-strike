import { ReplicatedStorage, RunService, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign6.DarkMagic
const DarkMagicZombieEffect = ReplicatedStorage.Remotes.Zombies.DarkMagicZombieEffect

const ShootAnimation = Assets.ShootAnimation
const Template = Assets.Template

const ANGLE_DIFF = 15
const RANGE = 50

DarkMagicZombieEffect.OnClientEvent.Connect((
	zombie: Model & {
		Humanoid: Humanoid,
	},
	aggroFocus: Model,
) => {
	const rotateConnection = RunService.Heartbeat.Connect(() => {
		const target = aggroFocus.PrimaryPart

		if (target !== undefined && zombie.PrimaryPart !== undefined) {
			const cframe = zombie.PrimaryPart.CFrame
			zombie.SetPrimaryPartCFrame(new CFrame(
				cframe.Position,
				new Vector3(target.Position.X, cframe.Position.Y, target.Position.Z),
			))
		}
	})

	PlayQuickSound(SoundService.ZombieSounds["6"].DarkMagic.Cast, zombie.PrimaryPart)

	const animation = zombie.Humanoid.LoadAnimation(ShootAnimation)
	animation.KeyframeReached.Connect(() => {
		rotateConnection.Disconnect()
		if (zombie.PrimaryPart === undefined) {
			return
		}

		const position = zombie.PrimaryPart.Position
		const lookVector = zombie.PrimaryPart.CFrame.LookVector

		for (let angle = -ANGLE_DIFF; angle <= ANGLE_DIFF; angle += ANGLE_DIFF) {
			BossLocalScriptUtil.Projectile(Template, {
				initial: position,
				lifetime: 3,
				goal: position.add(lookVector.mul(RANGE)).add(
					new Vector3(
						angle,
						0,
						angle,
					),
				),
				speed: 90,
				onTouched: () => {
					DarkMagicZombieEffect.FireServer(zombie)
				},
			})
		}
	})

	animation.Play()
})
