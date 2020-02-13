import { CollectionService, Players, ReplicatedStorage, RunService, SoundService, Workspace } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

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
	const boss = CollectionService.GetTagged("Boss")[0] as Model & {
		Head: BasePart,
		Humanoid: Humanoid,
	}

	boss.Humanoid.LoadAnimation(Assets.SludgePrime).Play()
	const fireAnimation = boss.Humanoid.LoadAnimation(Assets.SludgeFire)

	RealDelay(WIND_UP_TIME, () => {
		const time = tick()

		Interval(1 / RATE_OF_FIRE, () => {
			if (boss.Humanoid.Health <= 0) {
				return
			}

			if (tick() - time >= DURATION) {
				return false
			}

			PlayQuickSound(SoundService.ZombieSounds.Radioactive.Boss.ThrowBall, boss.PrimaryPart)

			fireAnimation.Play()

			const characters = []
			for (const player of Players.GetPlayers()) {
				if (player.Character !== undefined && player.Character.PrimaryPart !== undefined) {
					characters.push(player.Character)
				}
			}

			if (characters.size() > 0) {
				const character = characters[math.random(0, characters.size() - 1)]
				const range = WarningRange(character.PrimaryPart!.Position, RANGE)

				const ball = Assets.SludgeBall.Clone()

				// Animation
				const start = boss.Head.Position
				const goal = range.Position

				ball.Position = start
				ball.Parent = Workspace

				let total = 0
				const connection = RunService.Heartbeat.Connect((delta) => {
					total = math.min(TO_TARGET_TIME, total + delta)
					const newPosition = start.Lerp(goal, math.sin(total / TO_TARGET_TIME))
					ball.Position = newPosition

					if (total >= TO_TARGET_TIME) {
						const jumpSound = SoundService.ZombieSounds.Radioactive.Boss.Jump.Clone()
						jumpSound.PlayOnRemove = true
						jumpSound.Parent = ball

						ball.Destroy()
						range.Destroy()
						connection.Disconnect()

						if (Players.LocalPlayer.Character!.PrimaryPart!.Position.sub(range.Position).Magnitude
							<= RANGE
						) {
							SludgeBall.FireServer()
						}
					}
				})
			}
		})
	})
})
