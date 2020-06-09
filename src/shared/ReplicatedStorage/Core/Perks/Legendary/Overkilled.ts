import { CollectionService } from "@rbxts/services"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

class Overkilled extends WeaponPerk {
	static Name = "Overkilled"
	static Icon = PerkIcon.Skull
	static LegendaryPerk = true
	static PowerBuff = 1.275

	static Values = [{
		Range: [2, 2],
	}]

	overkillDamage?: number

	DamageDealt(damage: number, zombie: Humanoid) {
		const healthAfter = zombie.Health - damage
		if (healthAfter < 0 && this.overkillDamage === undefined) {
			this.overkillDamage = -healthAfter

			RealDelay(this.Value(0), () => {
				this.overkillDamage = undefined
			})
		}
	}

	ModifyDamage(damage: number, zombie: Humanoid): number {
		// Don't deal overkill damage to bosses, it'll kill them crazy fast
		if (CollectionService.HasTag(zombie.Parent!, "Boss")) {
			return damage
		}

		if (this.overkillDamage !== undefined) {
			return damage + this.overkillDamage
		}

		return damage
	}
}

export = Overkilled
