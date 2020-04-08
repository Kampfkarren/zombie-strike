import { ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import LineOfSight from "mission/ReplicatedStorage/Libraries/LineOfSight"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

const ATTACK_PRIME = 1.35
const DarkMagicZombieEffect = ReplicatedStorage.Remotes.Zombies.DarkMagicZombieEffect

class DarkMagic extends Common {
	static AttackCooldown = 2.5
	static Model = "DarkMagic"
	AttackRange = 40

	CheckAttack(): boolean {
		if (this.aggroFocus === undefined) {
			return false
		}

		return Zombie.CheckAttack(this) && LineOfSight(
			this.instance.PrimaryPart.Position,
			this.aggroFocus,
			this.AttackRange,
		)[0]
	}

	AfterSpawn() {
		super.AfterSpawn()

		this.aliveMaid.GiveTask(DarkMagicZombieEffect.OnServerEvent.Connect((player, zombie) => {
			if (zombie === this.instance) {
				TakeDamage(player, this.GetScale("Damage"))
			}
		}))
	}

	Attack() {
		if (this.aggroFocus === undefined) {
			return false
		}

		this.instance.Humanoid.WalkSpeed = 0
		DarkMagicZombieEffect.FireAllClients(this.instance, this.aggroFocus)
		wait(ATTACK_PRIME)
		if (this.alive) {
			this.instance.Humanoid.WalkSpeed = this.GetSpeed()
		}

		return true
	}
}

export = DarkMagic
