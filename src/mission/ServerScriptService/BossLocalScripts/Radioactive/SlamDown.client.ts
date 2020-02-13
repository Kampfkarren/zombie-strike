import { CollectionService, Players, ReplicatedStorage, RunService, SoundService, TweenService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

const SlamDownAoE = BossLocalScriptUtil.WaitForBossRemote("SlamDownAoE")
const SlamDownRing = BossLocalScriptUtil.WaitForBossRemote("SlamDownRing")

const LIFTOFF_HEIGHT = 300
const RING_DELAY = 0.95
const RINGS_PHASE_ONE = 3
const RINGS_PHASE_TWO = 1

const SLAM_DOWN_RANGE = 16
const SLAM_DOWN_TIME = 0.8

SlamDownAoE.OnClientEvent.Connect((position: Vector3) => {
	const boss = CollectionService.GetTagged("Boss")[0] as Model & {
		CurrentPhase: NumberValue,
		Humanoid: Humanoid,
	}

	const slamAnimation = boss.Humanoid.LoadAnimation(
		ReplicatedStorage
			.Assets
			.Bosses
			.Radioactive
			.Boss
			.SlamAnimation
	)

	const warning = WarningRange(position, SLAM_DOWN_RANGE, true)

	slamAnimation.Play()
	slamAnimation.KeyframeReached.Connect((keyframe) => {
		if (keyframe === "Liftoff") {
			PlayQuickSound(SoundService.ZombieSounds.Radioactive.Boss.Jump, boss.PrimaryPart)

			const start = boss.PrimaryPart!.Position
			let total = 0

			const connection = RunService.Heartbeat.Connect((delta) => {
				total += math.min(SLAM_DOWN_TIME, delta)
				const alpha = math.sin(total / SLAM_DOWN_TIME * (math.pi / 2))

				let liftoffHeight = TweenService.GetValue(
					alpha % 0.5 * 2,
					Enum.EasingStyle.Quad,
					alpha > 0.5
						? Enum.EasingDirection.Out
						: Enum.EasingDirection.In
				)

				if (alpha < 0.5) {
					liftoffHeight *= LIFTOFF_HEIGHT
				} else {
					liftoffHeight = LIFTOFF_HEIGHT - (liftoffHeight * LIFTOFF_HEIGHT)
				}

				const newPosition = start.Lerp(position.add(new Vector3(0, 5, 0)), alpha)
					.add(new Vector3(0, liftoffHeight, 0))

				boss.SetPrimaryPartCFrame(new CFrame(newPosition)
					.mul(boss.PrimaryPart!.CFrame.sub(boss.PrimaryPart!.Position)))

				if (total >= SLAM_DOWN_TIME) {
					connection.Disconnect()
					warning.Destroy()

					if (Players.LocalPlayer.Character!.PrimaryPart!.Position.sub(warning.Position).Magnitude
						<= SLAM_DOWN_RANGE
					) {
						SlamDownAoE.FireServer()
					}

					PlayQuickSound(SoundService.ZombieSounds.Radioactive.Boss.JumpLand, boss.PrimaryPart)

					for (let _ = 0; _ < (boss.CurrentPhase.Value === 0 ? RINGS_PHASE_ONE : RINGS_PHASE_TWO); _++) {
						BossLocalScriptUtil.FireRing({
							initial: position.add(new Vector3(0, 2, 0)),
							height: 3,
							tweenInfo: new TweenInfo(6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							onTouched: SlamDownRing,
						})

						wait(RING_DELAY)
					}
				}
			})
		}
	})
})
