import { ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import TakeDamage from "shared/ServerScriptService/TakeDamage"

const MegaSnowballZombieEffect = ReplicatedStorage.Remotes.Zombies.MegaSnowballZombieEffect

const ANIMATION_LENGTH = 2.2

let connected = false

class MegaSnowball extends Common {
	static Model = "MegaSnowball"

	AfterSpawn() {
		super.AfterSpawn()

		if (!connected) {
			connected = true
			const damage = this.GetScale("SnowballDamage")
			MegaSnowballZombieEffect.OnServerEvent.Connect((player) => {
				TakeDamage(player, damage)
				MegaSnowballZombieEffect.FireAllClients(player.Character)
			})
		}

		this.aliveMaid.GiveTask(Interval(this.GetScale("Cooldown") + ANIMATION_LENGTH, () => {
			if (this.aggroFocus !== undefined) {
				this.instance.Humanoid.WalkSpeed = 0
				MegaSnowballZombieEffect.FireAllClients(this.instance, this.aggroFocus)
				RealDelay(ANIMATION_LENGTH, () => {
					if (this.alive) {
						this.instance.Humanoid.WalkSpeed = this.GetSpeed()
					}
				})
			}
		}))
	}
}

export = MegaSnowball
