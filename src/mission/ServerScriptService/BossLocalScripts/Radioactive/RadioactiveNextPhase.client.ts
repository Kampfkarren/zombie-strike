import { Players, TweenService } from "@rbxts/services"
import * as BossLocalScriptUtil from "mission/ReplicatedStorage/Libraries/BossLocalScriptUtil"

const NextPhase = BossLocalScriptUtil.WaitForBossRemote("NextPhase")
const LocalPlayer = Players.LocalPlayer

const flashInInfo = new TweenInfo(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
const flashOutInfo = new TweenInfo(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

const overlay = new Instance("Frame")
overlay.BackgroundColor3 = new Color3(0, 1, 0)
overlay.BackgroundTransparency = 0.85
overlay.BorderSizePixel = 0
overlay.Size = UDim2.fromScale(1, 1)

NextPhase.OnClientEvent.Connect(() => {
	const phaseGui = new Instance("ScreenGui")
	phaseGui.DisplayOrder = -1
	phaseGui.IgnoreGuiInset = true
	phaseGui.ResetOnSpawn = false

	const flashEmitter = new Instance("Frame")
	flashEmitter.BackgroundColor3 = new Color3(1, 1, 1)
	flashEmitter.BorderSizePixel = 0
	flashEmitter.BackgroundTransparency = 1
	flashEmitter.Size = UDim2.fromScale(1, 1)
	flashEmitter.ZIndex = 2
	flashEmitter.Parent = phaseGui

	phaseGui.Parent = LocalPlayer.WaitForChild("PlayerGui")

	const flashInTween = TweenService.Create(flashEmitter, flashInInfo, {
		BackgroundTransparency: 0,
	})

	flashInTween.Completed.Connect(() => {
		overlay.Parent = phaseGui

		TweenService.Create(flashEmitter, flashOutInfo, {
			BackgroundTransparency: 1,
		}).Play()
	})

	flashInTween.Play()
})
