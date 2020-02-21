import { ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"

const Assets = ReplicatedStorage
	.Assets
	.Bosses
	.Radioactive
	.Boss
const SludgeBall = BossLocalScriptUtil.WaitForBossRemote("SludgeBall")

const DURATION = 6
const RANGE = 8
const RATE_OF_FIRE = 3
const TO_TARGET_TIME = 0.8
const WIND_UP_TIME = 0.3

SludgeBall.OnClientEvent.Connect(() => {
	BossLocalScriptUtil.SludgeBalls({
		assets: Assets,
		duration: DURATION,
		range: RANGE,
		rateOfFire: RATE_OF_FIRE,
		toTargetTime: TO_TARGET_TIME,
		windUpTime: WIND_UP_TIME,

		remote: SludgeBall,

		soundHit: SoundService.ZombieSounds.Radioactive.Boss.BallHit,
		soundThrowBall: SoundService.ZombieSounds.Radioactive.Boss.ThrowBall,
	})
})
