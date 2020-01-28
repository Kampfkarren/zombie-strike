import { Players, ReplicatedStorage, SoundService, TweenService, Workspace } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"

const Katana = ReplicatedStorage.Assets.Bosses.Samurai.Boss.Katana
const Yooo = BossLocalScriptUtil.WaitForBossRemote("Yooo")

const katanaFadeInfo = new TweenInfo(0.5, Enum.EasingStyle.Sine)
const katanaTweenInfo = new TweenInfo(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)

const KATANA_DELAY = 0.7 * 2.5 // 0.7 is when Back tween starts to be positive
const KATANA_RANGE = 250

const SOUND_START_POSITION = 5 - KATANA_DELAY // YOOOO is at 5, subtract by delay

let touched = false

function spawnKatana(cframe: CFrame) {
	const firedAt = tick()

	const katana = Katana.Clone()
	katana.CFrame = cframe
	katana.Transparency = 1
	katana.Parent = Workspace

	const attackTween = TweenService.Create(katana, katanaTweenInfo, {
		CFrame: cframe.add(cframe.LookVector.mul(-KATANA_RANGE))
	})

	TweenService.Create(katana, katanaFadeInfo, {
		Transparency: 0,
	}).Play()

	const warning = katana.Clone()
	warning.ClearAllChildren()
	warning.Color = new Color3(1, 0, 0)
	warning.Size = new Vector3(1, 0.5, KATANA_RANGE * 2)
	warning.Transparency = 0.8
	warning.Parent = Workspace

	attackTween.Completed.Connect(() => {
		warning.Destroy()
	})

	attackTween.Play()

	katana.Touched.Connect((part) => {
		const character = Players.LocalPlayer.Character

		if (character !== undefined
			&& tick() - firedAt >= KATANA_DELAY
			&& part.IsDescendantOf(character)
			&& !touched
		) {
			touched = true
			Yooo.FireServer()
		}
	})
}

Yooo.OnClientEvent.Connect(() => {
	touched = false
	const room = Workspace.Rooms.StartSection as SamuraiRoom

	const sound = SoundService.ZombieSounds.Samurai.Boss.Yooo.Clone()
	sound.TimePosition = SOUND_START_POSITION
	sound.Parent = Workspace
	sound.Play()

	const katanaSpawns: Attachment[] = []
	for (const attachment of room.Arena.PrimaryPart.GetChildren()) {
		if (attachment.Name === "KatanaSpawn") {
			katanaSpawns.push(attachment as Attachment)
			spawnKatana((attachment as Attachment).WorldCFrame.mul(CFrame.Angles(0, math.pi / 2, 0)))
		}
	}
})
