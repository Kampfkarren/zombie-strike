import { ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"

(() => {
	const DURATIONS = [6, 7, 8, 9, 10]
	const RATES_OF_FIRE = [6, 7, 8, 9, 10]

	const POSITION_OFFSET = 5
	const RANGE = 8
	const TO_TARGET_TIME = 0.8
	const WIND_UP_TIME = 0.3

	const Assets = ReplicatedStorage.Assets.Campaign.Campaign6.Boss
	const MagicMissiles = ReplicatedStorage.Remotes.Tower.Boss.MagicMissiles

	if (Dungeon.GetDungeonData("Campaign") !== 6) {
		return
	}

	MagicMissiles.OnClientEvent.Connect(() => {
		const difficulty = Dungeon.GetDungeonData("Difficulty") - 1

		BossLocalScriptUtil.SludgeBalls({
			assets: Assets,
			duration: DURATIONS[difficulty],
			positionOffset: POSITION_OFFSET,
			range: RANGE,
			rateOfFire: RATES_OF_FIRE[difficulty],
			toTargetTime: TO_TARGET_TIME,
			windUpTime: WIND_UP_TIME,

			remote: MagicMissiles,

			soundHit: SoundService.ZombieSounds.Radioactive.Boss.BallHit,
			soundThrowBall: SoundService.ZombieSounds["6"].Boss.Magic,
		})
	})
})()
