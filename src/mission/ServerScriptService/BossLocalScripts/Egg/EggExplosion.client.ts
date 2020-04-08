import { Players, ReplicatedStorage, RunService, Workspace } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"
import Effects from "shared/ReplicatedStorage/RuddevModules/Effects/init"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

const DROP_HEIGHT = 20
const EGG_DELAY = 2.5
const EGG_DROP_TIME = 0.5
const EGG_RANGE = 9
const FLASH_RATE = 0.2

const EggExplosion = BossLocalScriptUtil.WaitForBossRemote("EggExplosion")

const EggBomb = ReplicatedStorage
	.Assets
	.Bosses
	.Egg
	.Boss
	.EggBomb

BossLocalScriptUtil.HookAttack(EggExplosion, (_, points: Attachment[]) => {
	for (const point of points) {
		const bomb = EggBomb.Clone()
		bomb.Parent = Workspace

		const texture = bomb.Mesh.TextureId

		let flashing = false
		const stopFlashing = Interval(FLASH_RATE, () => {
			flashing = !flashing
			bomb.Mesh.TextureId = flashing ? "" : texture
		})

		const initial = point.WorldPosition.add(new Vector3(0, DROP_HEIGHT, 0))
		const goal = point.WorldPosition.add(new Vector3(0, bomb.Size.Y / 2, 0))

		const warningRange = WarningRange(goal.add(new Vector3(0, 1, 0)), EGG_RANGE)

		let total = 0

		while (total < EGG_DROP_TIME) {
			const [delta] = RunService.Heartbeat.Wait()
			total = math.min(total + delta, EGG_DROP_TIME)

			bomb.Position = initial.Lerp(goal, math.sin((total / EGG_DROP_TIME) * (math.pi / 2)))
		}

		RealDelay(EGG_DELAY, () => {
			bomb.Destroy()
			Effects.Effect("Explosion", goal, EGG_RANGE)
			stopFlashing()

			const character = Players.LocalPlayer.Character

			if (character !== undefined && (character.PrimaryPart!.Position.sub(goal).Magnitude <= EGG_RANGE / 2)) {
				EggExplosion.FireServer()
			}

			warningRange.Destroy()
		})
	}
})
