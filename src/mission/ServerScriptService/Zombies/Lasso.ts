import { ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"

const AGGRO_DELAY = 1.5
const STUN_TIME = 5.8

const LassoZombieEffect = ReplicatedStorage.Remotes.Zombies.LassoZombieEffect

class Lasso extends Common {
	static Model = "Lasso"

	lastLasso = 0

	AggroTargetChanged(newTarget?: Character) {
		if (newTarget !== undefined
			&& tick() - this.lastLasso > this.GetScale("Cooldown")
		) {
			RealDelay(AGGRO_DELAY, () => {
				if (this.aggroFocus === newTarget) {
					this.lastLasso = tick()
					this.instance.Humanoid.WalkSpeed = 0
					LassoZombieEffect.FireAllClients(this.instance, this.aggroFocus)

					RealDelay(STUN_TIME, () => {
						if (this.alive) {
							this.instance.Humanoid.WalkSpeed = this.GetSpeed()
						}
					})
				}
			})
		}
	}
}

export = Lasso
