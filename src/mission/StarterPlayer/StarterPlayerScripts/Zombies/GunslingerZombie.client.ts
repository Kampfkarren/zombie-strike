import { CollectionService, Players, ReplicatedStorage, Workspace, RunService } from "@rbxts/services"
import Dungeon from "mission/ReplicatedStorage/Libraries/Dungeon"
import LookAt from "shared/ReplicatedStorage/Core/LookAt"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import Raycast from "shared/ReplicatedStorage/Core/Raycast"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay";

const GunslingerZombieEffect = ReplicatedStorage.Remotes.Zombies.GunslingerZombieEffect

const LOOK_AT_RESPONSIVENESS = 3
const MUZZLE_HEIGHT = 0.8

type GunslingerZombie = Model & {
	Animations: Folder & {
		Fire: Animation,
	},
	Gun: Instance & {
		Handle: BasePart & {
			Muzzle: Attachment,
		},
		Range: NumberValue,
	},
	Humanoid: Humanoid,
	PrimaryPart: BasePart,
}

function shootRange(zombie: GunslingerZombie, range: BasePart) {
	return function() {
		if (zombie.IsDescendantOf(Workspace) && zombie.Humanoid.Health > 0) {
			const character = Players.LocalPlayer.Character

			if (character !== undefined) {
				range.CanCollide = true

				for (const part of range.GetTouchingParts()) {
					if (part.IsDescendantOf(character)) {
						GunslingerZombieEffect.FireServer(zombie)
						break
					}
				}

				range.CanCollide = false

				range.Color = new Color3(1, 0, 0)
				RealDelay(0.5, () => {
					range.Destroy()
				})
			}
		} else {
			range.Destroy()
		}
	}
}

if (Dungeon.GetDungeonData("Campaign") === 5) {
	GunslingerZombieEffect.OnClientEvent.Connect((zombie: GunslingerZombie, focus: Model) => {
		const gunRange = zombie.Gun.Range.Value

		const maid = new Maid()
		const muzzle = zombie.Gun.Handle.Muzzle

		maid.GiveTask(LookAt(zombie, focus, LOOK_AT_RESPONSIVENESS))
		maid.DieWith(zombie.Humanoid)

		const characters = Players.GetPlayers().mapFiltered(player => player.Character)
		for (const zombie of CollectionService.GetTagged("Zombie")) {
			characters.push(zombie as Model)
		}

		for (const child of zombie.Gun.Handle.GetChildren()) {
			if (child.Name.match("^Final")[0] !== undefined) {
				const attachment = child as Attachment

				const range = ReplicatedStorage.Assets.Range.Clone()
				range.Anchored = true
				range.Massless = true
				range.Shape = Enum.PartType.Block
				range.Size = new Vector3(
					gunRange,
					0.8,
					1.5,
				)

				const [_, position] = Raycast(
					zombie.PrimaryPart.Position,
					new Vector3(0, -1000, 0),
					characters,
				)

				function getCFrame() {
					let cframe = new CFrame(
						position.mul(new Vector3(1, 0, 1)),
						zombie.PrimaryPart.Position
							.add(zombie.PrimaryPart.CFrame.LookVector.mul(
								attachment.Position.sub(muzzle.Position).Magnitude,
							))
							.add(new Vector3(attachment.Position.X, 0, 0))
							.mul(new Vector3(1, 0, 1)),
					)
					cframe = cframe.add(cframe.LookVector.mul(gunRange / 2))
					cframe = cframe.mul(CFrame.Angles(0, math.pi / 2, 0))
					cframe = cframe.add(new Vector3(0, zombie.PrimaryPart.Position.Y + MUZZLE_HEIGHT, 0))
					return cframe
				}

				range.CFrame = getCFrame()

				range.Parent = zombie

				maid.GiveTask(RunService.Heartbeat.Connect(() => {
					range.CFrame = getCFrame()
				}))

				maid.GiveTask(shootRange(zombie, range))
			}
		}

		const animation = zombie.Humanoid.LoadAnimation(zombie.Animations.Fire)
		animation.KeyframeReached.Connect(() => {
			maid.DoCleaning()
		})
		animation.Play()
	})
}
