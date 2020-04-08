import { ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import TakeDamage from "shared/ServerScriptService/TakeDamage"

const GunslingerZombieEffect = ReplicatedStorage.Remotes.Zombies.GunslingerZombieEffect

class Gunslinger extends Common {
	static Model = "Gunslinger"

	AfterSpawn() {
		this.AttackRange = this.GetScale("Range") / 2

		this.aliveMaid.GiveTask(GunslingerZombieEffect.OnServerEvent.Connect((player, zombie) => {
			if (zombie === this.instance) {
				TakeDamage(player, this.GetScale("Damage"))
			}
		}))

		const range = new Instance("NumberValue")
		range.Name = "Range"
		range.Value = this.GetScale("Range")
		range.Parent = this.instance.WaitForChild("Gun")
	}

	Attack() {
		GunslingerZombieEffect.FireAllClients(this.instance, this.aggroFocus)
		this.instance.Humanoid.WalkSpeed = 0
		wait(this.GetScale("ActivationTime"))
		if (this.alive) {
			this.instance.Humanoid.WalkSpeed = this.GetSpeed()
		}

		return true
	}

	GetAttackCooldown() {
		return this.GetScale("Cooldown") + this.GetScale("ActivationTime")
	}
}

export = Gunslinger
