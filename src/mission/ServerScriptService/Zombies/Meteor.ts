import { ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import TakeDamage from "shared/ServerScriptService/TakeDamage"

const CAST_TIME = 0.75

const MeteorZombieEffect = ReplicatedStorage.Remotes.Zombies.MeteorZombieEffect

class Meteor extends Common {
	static Model = "Meteor"

	AfterSpawn() {
		super.AfterSpawn()

		this.aliveMaid.GiveTask(Interval(this.GetScale("MeteorCooldown"), () => {
			if (this.aggroFocus !== undefined) {
				this.instance.Humanoid.WalkSpeed = 0
				MeteorZombieEffect.FireAllClients(this.instance, this.aggroFocus)

				RealDelay(CAST_TIME, () => {
					if (this.alive) {
						this.instance.Humanoid.WalkSpeed = this.GetSpeed()
					}
				})
			}
		}))

		this.aliveMaid.GiveTask(MeteorZombieEffect.OnServerEvent.Connect((player, zombie) => {
			if (zombie === this.instance) {
				TakeDamage(player, this.GetScale("Damage"))
			}
		}))
	}
}

export = Meteor
