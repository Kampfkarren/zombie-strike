function PlayQuickSound(sound: Sound, parent?: Instance) {
	const newSound = sound.Clone()
	newSound.Parent = parent
	newSound.Play()
	newSound.Ended.Connect(() => {
		newSound.Destroy()
	})
}

export = PlayQuickSound
