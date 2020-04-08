import { Players, ReplicatedStorage, RunService, SoundService, TweenService, Workspace } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import WarningRange from "mission/ReplicatedStorage/Libraries/WarningRange"

const Assets = ReplicatedStorage.Assets.Campaign.Campaign3.Meteor
const LocalPlayer = Players.LocalPlayer
const MeteorZombieEffect = ReplicatedStorage.Remotes.Zombies.MeteorZombieEffect

const CAST_TIME = 0.75
const IMPACT_TIME = [1.3, 1.2, 1.1, 1, 0.8]
const METEOR_START = new Vector3(0, 400, 0)
const RANDOM_RANGE = 7
const RANGE = [25, 26, 28, 30, 31]

MeteorZombieEffect.OnClientEvent.Connect((zombie: Model, focus: Model) => {
	const difficulty =
		Dungeon.GetDungeonData("Gamemode") === "Mission"
		? Dungeon.GetDungeonData("Difficulty") - 1
		: 1

	const humanoid = zombie.FindFirstChild("Humanoid") as Humanoid | undefined
	if (humanoid !== undefined) {
		humanoid.LoadAnimation(Assets.Cast).Play()
	}

	const range = RANGE[difficulty] / 2
	const warning = WarningRange(
		(focus.WaitForChild("HumanoidRootPart") as Part).Position
		.add(new Vector3(
			math.random(-RANDOM_RANGE, RANDOM_RANGE),
			0,
			math.random(-RANDOM_RANGE, RANDOM_RANGE),
		)),
		range,
	)

	warning.Color = new Color3(1, 1, 0)

	RealDelay(CAST_TIME, () => {
		const maid = new Maid()

		const initial = warning.Position.add(METEOR_START)

		const meteor = Assets.Meteor.Clone()
		meteor.Size = new Vector3(range * 2, range * 2, range * 2)
		meteor.Position = initial
		meteor.Parent = Workspace

		const impactTime = IMPACT_TIME[difficulty]
		let totalTime = 0

		maid.GiveTask(RunService.Heartbeat.Connect(delta => {
			totalTime = math.min(totalTime + delta, impactTime)
			if (totalTime >= impactTime) {
				const character = LocalPlayer.Character
				if (character !== undefined
					&& character.PrimaryPart!.Position.sub(warning.Position).Magnitude <= range
				) {
					MeteorZombieEffect.FireServer(zombie)
				}

				const impact = Assets.Impact.Clone()
				impact.Position = warning.Position
				impact.ParticleEmitter.Emit(20)
				impact.Parent = Workspace

				PlayQuickSound(SoundService.ZombieSounds["3"].Meteor.Impact, impact)

				RealDelay(6, () => {
					impact.Destroy()
				})

				maid.DoCleaning()
			} else {
				meteor.Position = initial.Lerp(
					warning.Position,
					TweenService.GetValue(totalTime / impactTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				)
			}
		}))

		maid.GiveTask(meteor)
		maid.GiveTask(warning)
	})
})
