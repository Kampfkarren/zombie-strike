import { CollectionService, Players, RunService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil";
import WarningRange = require("mission/ReplicatedStorage/Libraries/WarningRange");

const SwordSpin = BossLocalScriptUtil.WaitForBossRemote("SwordSpin")

const RANGE_OFFSET = 5
const SWORD_SPIN_DELAY = 2.5
const SWORD_SPIN_RANGE = 15
const SWORD_SPIN_RATE = 3

let swordSpinTick = 0

SwordSpin.OnClientEvent.Connect((swordPoints: Attachment[]) => {
	swordSpinTick += 1
	const spinTick = swordSpinTick

	const boss = CollectionService.GetTagged("Boss")[0] as Model
	const primaryPart = boss.PrimaryPart!
	const angle = primaryPart.CFrame.sub(primaryPart.Position)

	let touched = false
	const warningRange = WarningRange(primaryPart.Position.sub(
		new Vector3(0, RANGE_OFFSET, 0)
	), SWORD_SPIN_RANGE)

	warningRange.Touched.Connect((part) => {
		const character = Players.LocalPlayer.Character
		if (character !== undefined && part.IsDescendantOf(character) && !touched) {
			touched = true
			SwordSpin.FireServer()
		}
	})

	let angleTotal = 0

	for (const swordPoint of swordPoints) {
		touched = false

		const initial = primaryPart.Position
		const goal = new Vector3(swordPoint.WorldPosition.X, initial.Y, swordPoint.WorldPosition.Z)
		let total = 0

		while (total < SWORD_SPIN_DELAY && swordSpinTick === spinTick) {
			const delta = RunService.Heartbeat.Wait()[0]
			total += delta
			angleTotal += delta

			const centerPosition = initial.Lerp(goal, total / SWORD_SPIN_DELAY)
			boss.SetPrimaryPartCFrame(
				new CFrame(centerPosition)
					.mul(angle)
					.mul(CFrame.Angles(0, angleTotal * SWORD_SPIN_RATE, 0)),
			)

			warningRange.Position = centerPosition.sub(new Vector3(0, RANGE_OFFSET, 0))
		}
	}

	warningRange.Destroy()
})
