import { ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"

const EggCrazyFrenzy = BossLocalScriptUtil.WaitForBossRemote("EggCrazyFrenzy")

const DURATION = 3
const LIFETIME = 5
const OFFSET = new Vector3(0, -8.8, 0)
const RANGE = 150
const RATE_OF_FIRE = 1 / 20
const SPEED = 40

const projectile = ReplicatedStorage
	.Assets
	.Bosses
	.Egg
	.Boss
	.EggFrenzy

const rng = new Random()

BossLocalScriptUtil.HookAttack(EggCrazyFrenzy, (boss) => {
	const time = tick()

	Interval(RATE_OF_FIRE, () => {
		if (tick() - time > DURATION) {
			return false
		}

		const initial = boss.PrimaryPart.Position.add(OFFSET)
		const angle = rng.NextNumber() * 2 * math.pi

		PlayQuickSound(
			SoundService.ZombieSounds.Egg.Boss.Shoot,
			BossLocalScriptUtil.Projectile(projectile, {
				initial,
				lifetime: LIFETIME,
				goal: initial.add(new Vector3(
					math.cos(angle * RANGE),
					0,
					math.sin(angle * RANGE),
				)),
				speed: SPEED,

				onTouched: EggCrazyFrenzy,
			}),
		)
	})
})
