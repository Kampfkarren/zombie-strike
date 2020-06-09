import { UserInputService } from "@rbxts/services"

const timesUsingLastInputs = new Map<Enum.UserInputType, number>()

const watchers: Map<Enum.UserInputType, () => void>[] = []

UserInputService.LastInputTypeChanged.Connect((lastInputType) => {
	timesUsingLastInputs.set(lastInputType, os.time())

	for (const watcher of watchers) {
		const callback = watcher.get(lastInputType)
		if (callback) {
			callback()
		}
	}
})

function LastInputTypeWatcher(inputs: Map<Enum.UserInputType, () => void>): () => void {
	for (const [inputType] of timesUsingLastInputs
		.entries()
		.sort(([_, timeA], [__, timeB]) => {
			return timeA > timeB
		})
	) {
		const callback = inputs.get(inputType)
		if (callback) {
			callback()
			break
		}
	}

	watchers.push(inputs)

	return () => {
		watchers.unorderedRemove(assert(watchers.indexOf(inputs), "LastInputTypeWatcher disconnected twice"))
	}
}

export = LastInputTypeWatcher
