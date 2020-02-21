import { CollectionService, ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"

(() => {
	const BALLS_FIRED = 8
	const DURATIONS = [4, 5, 6, 7, 8]
	const LIFETIME = 5
	const RATES_OF_FIRE = [1, 0.75, 0.75, 0.75, 0.75]
	const SPEED = 90

	const RANGE = 200
	const WIND_UP_TIME = 0.3

	const Assets = ReplicatedStorage.Assets.Campaign.Campaign6.Boss
	const MissileRing = ReplicatedStorage.Remotes.Tower.Boss.MissileRing

	const boss = CollectionService.GetInstanceAddedSignal("Boss").Wait()[0] as Model & {
		Humanoid: Humanoid,
	}

	const rng = new Random()

	if (Dungeon.GetDungeonData("Campaign") !== 6) {
		return
	}

	MissileRing.OnClientEvent.Connect(() => {
		const difficulty = Dungeon.GetDungeonData("Difficulty")
		const initial = boss.PrimaryPart!.Position

		const animation = boss.Humanoid.LoadAnimation(ReplicatedStorage.Assets.Campaign.Campaign6.Boss.MissileRingAnimation)

		function fire() {
			const rotationOffset = rng.NextNumber(-math.pi, math.pi)

			for (let index = 0; index < BALLS_FIRED; index++) {
				PlayQuickSound(SoundService.ZombieSounds["6"].Boss.Magic, boss.PrimaryPart, (sound) => {
					sound.Volume = 0.7
				})

				animation.Play()

				const input = ((index + rotationOffset) * 2 * math.pi) / BALLS_FIRED
				const pointX = math.cos(input)
				const pointY = math.sin(input)

				BossLocalScriptUtil.Projectile(Assets.SludgeBall, {
					initial,
					lifetime: LIFETIME,
					goal: initial.add(new Vector3(
						pointX * RANGE,
						0,
						pointY * RANGE,
					)),
					speed: SPEED,

					onTouched: MissileRing,
				})
			}
		}

		RealDelay(WIND_UP_TIME, () => {
			const time = tick()
			fire()
			Interval(RATES_OF_FIRE[difficulty], () => {
				if (tick() - time >= DURATIONS[difficulty]) {
					return false
				}

				fire()
			})
		})
	})
})()
