import { RunService } from "@rbxts/services"

let timeStarted = 0

export function DungeonStarted() {
	if (timeStarted === undefined) {
		timeStarted = os.time()
	}
}

export function GetTimeSinceStarting(): number {
	if (RunService.IsRunning()) {
		if (timeStarted === 0) {
			return time()
		} else {
			return os.time() - timeStarted
		}
	} else {
		// Mock number for Hoarcekat
		return 70
	}
}
