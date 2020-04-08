import { ReplicatedStorage, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"

const Assets = ReplicatedStorage
	.Assets
	.Bosses
	.Egg
	.Boss
const EggBomb = BossLocalScriptUtil.WaitForBossRemote("EggBomb")

const DURATION = 3
const RANGE = 8
const RATE_OF_FIRE_PHASE1 = 4
const RATE_OF_FIRE_PHASE2 = 5
const SRPEAD = 35
const TO_TARGET_TIME = 1
const WIND_UP_TIME = 0.3

BossLocalScriptUtil.HookAttack(EggBomb, (boss) => {
	const source = boss.FindFirstChild("EggBombSource", true) as Attachment
	BossLocalScriptUtil.SludgeBalls({
		assets: Assets,
		duration: DURATION,
		positionOffset: SRPEAD,
		range: RANGE,
		rateOfFire: boss.CurrentPhase.Value === 1 ? RATE_OF_FIRE_PHASE2 : RATE_OF_FIRE_PHASE1,
		toTargetTime: TO_TARGET_TIME,
		windUpTime: WIND_UP_TIME,

		remote: EggBomb,
		source: () => {
			return source.WorldPosition
		},

		soundHit: SoundService.ZombieSounds.Radioactive.Boss.BallHit,
		soundThrowBall: SoundService.ZombieSounds.Radioactive.Boss.ThrowBall,
	})
})
