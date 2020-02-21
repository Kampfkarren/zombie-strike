import { RunService, Workspace } from "@rbxts/services"

const LEEWAY = 2

function PlayQuickSound(sound: Folder | Sound, parent?: Instance, mutator?: (sound: Sound) => void) {
	let newSound = sound.ClassName === "Folder"
		? sound.GetChildren()[math.random(0, sound.GetChildren().size() - 1)] as Sound
		: sound

	newSound = newSound.Clone()

	if (mutator !== undefined) {
		mutator(newSound)
	}

	newSound.Parent = parent || Workspace
	newSound.Play()
	newSound.Ended.Connect(() => {
		if (RunService.IsServer()) {
			// Server takes a bit longer to destroy so all clients hear it
			wait(LEEWAY)
		}

		newSound.Destroy()
	})
}

export = PlayQuickSound
