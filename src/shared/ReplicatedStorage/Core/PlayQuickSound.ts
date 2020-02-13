import { Workspace } from "@rbxts/services"

function PlayQuickSound(sound: Folder | Sound, parent?: Instance) {
	let newSound = sound.ClassName === "Folder"
		? sound.GetChildren()[math.random(0, sound.GetChildren().size() - 1)] as Sound
		: sound

	newSound = newSound.Clone()
	newSound.Parent = parent || Workspace
	newSound.Play()
	newSound.Ended.Connect(() => {
		newSound.Destroy()
	})
}

export = PlayQuickSound
