import { RunService, SoundService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

const BIG_POUND_DELAY = 1.2
const BIG_POUND_INTERVAL = 0.95
const BIG_POUND_RINGS = 3
const BIG_POUND_RANGE = 15

const GRAVITY_SLAM_DELAY = 1.3
const GRAVITY_SLAM_RANGE = 5

const DROP_DOWN_AT = GRAVITY_SLAM_DELAY * 0.75
const DROP_DOWN_HEIGHT = new Vector3(0, 20, 0)

const GravitySlam = BossLocalScriptUtil.WaitForBossRemote("GravitySlam")

let gravitySlamTick = 0

BossLocalScriptUtil.HookAttack(GravitySlam, (boss, slamPoints: Attachment[]) => {
	gravitySlamTick += 1
	const currentTick = gravitySlamTick

	const primaryPart = boss.PrimaryPart!
	const yPoint = primaryPart.Position.Y
	const angle = primaryPart.CFrame.sub(primaryPart.Position)

	const warningRange = WarningRange(primaryPart.Position, GRAVITY_SLAM_RANGE)

	for (const [index, swordPoint] of slamPoints.entries()) {
		warningRange.Position = swordPoint.WorldPosition

		const initial = primaryPart.Position
		const finishAt = new Vector3(swordPoint.WorldPosition.X, yPoint, swordPoint.WorldPosition.Z)
		const peak = finishAt.add(DROP_DOWN_HEIGHT)
		const bigPound = index === slamPoints.size() - 1

		let total = 0

		if (bigPound) {
			warningRange.Size = new Vector3(0.25, BIG_POUND_RANGE, BIG_POUND_RANGE)
		}

		while (total < (bigPound ? BIG_POUND_DELAY : GRAVITY_SLAM_DELAY) && gravitySlamTick === currentTick) {
			const delta = RunService.Heartbeat.Wait()[0]
			total += delta

			if (total < DROP_DOWN_AT) {
				boss.SetPrimaryPartCFrame(
					new CFrame(initial.Lerp(
						peak,
						total / DROP_DOWN_AT,
					)).mul(angle)
				)
			} else {
				const difference = total - DROP_DOWN_AT - (bigPound ? (BIG_POUND_DELAY - GRAVITY_SLAM_DELAY) : 0)

				if (difference > 0) {
					const alpha = math.min(1, difference / (GRAVITY_SLAM_DELAY - DROP_DOWN_AT))

					boss.SetPrimaryPartCFrame(
						new CFrame(peak.Lerp(
							finishAt,
							alpha,
						)).mul(angle)
					)
				}
			}
		}

		for (let _ = 0; _ < (bigPound ? BIG_POUND_RINGS : 1); _++) {
			BossLocalScriptUtil.FireRing({
				initial: swordPoint.WorldPosition.add(new Vector3(0, 1, 0)),
				tweenInfo: new TweenInfo(6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),

				onTouched: GravitySlam,
			})

			PlayQuickSound(SoundService.ZombieSounds.Egg.Boss.Crash, boss.PrimaryPart)

			if (bigPound) {
				wait(BIG_POUND_INTERVAL)
			}
		}
	}

	warningRange.Destroy()
})
