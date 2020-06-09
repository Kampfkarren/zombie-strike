import { Players, RunService } from "@rbxts/services"

let GiveSpeedMultiplier: (speed: number, player?: Player) => () => void

if (RunService.IsServer()) {
	GiveSpeedMultiplier = (speed, player) => {
		if (player === undefined) {
			error("player is required for server use")
		}

		const speedMultiplier = player.WaitForChild("SpeedMultiplier") as NumberValue
		speedMultiplier.Value += speed

		let destroyed = false

		return () => {
			if (!destroyed) {
				destroyed = true
				speedMultiplier.Value -= speed
			}
		}
	}
} else {
	GiveSpeedMultiplier = (speed, player = Players.LocalPlayer) => {
		if (player !== Players.LocalPlayer) {
			error("player must be LocalPlayer when used from the client")
		}

		const speedMultiplier = player.WaitForChild("SpeedMultiplier")
		const localMultipliers = speedMultiplier.WaitForChild("LocalMultipliers")

		const value = new Instance("NumberValue")
		value.Value = speed
		value.Parent = localMultipliers

		return () => {
			value.Destroy()
		}
	}
}

export = GiveSpeedMultiplier
