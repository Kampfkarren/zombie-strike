import { ReplicatedStorage } from "@rbxts/services"
import { Perk, Scope, WeaponPerk } from "../Perk"
import { Gun } from "shared/ReplicatedStorage/Core/Loot"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.1, 0.15]

function howManyParticles(fireRate: number): number {
	return math.clamp(10 * (5 / fireRate), 1, 9)
}

class ExplosiveRounds extends WeaponPerk {
	static Name = "Explosive Rounds"
	static Scope = Scope.Both
	static Icon = PerkIcon.Starry
	static LegendaryPerk = true
	static PowerBuff = 1.2

	static Values = [{
		Range: DAMAGE_RANGE,
	}]

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * Perk.GetValue(
				gun.Seed,
				upgrades,
				{
					Range: [DAMAGE_RANGE[0] + 1, DAMAGE_RANGE[1] + 1],
					Offset: 0,
				},
			),
		}
	}

	DamageDealtClient(zombie: Humanoid) {
		const primaryPart = (zombie.Parent as Model).PrimaryPart
		if (primaryPart !== undefined) {
			let emitter: ParticleEmitter | undefined = primaryPart.FindFirstChild("ExplosiveRoundsEmitter") as ParticleEmitter
			if (emitter === undefined) {
				emitter = ReplicatedStorage.Assets.Particles.ExplosiveRoundsEmitter.Clone()
				emitter.Parent = primaryPart
			}

			emitter.Emit(howManyParticles(this.gun.FireRate))
		}
	}
}

export = ExplosiveRounds
