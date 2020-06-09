import { CritDecision, CritMethod, WeaponPerk } from "../Perk"
import { GunItem } from "../../Loot"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.2, 0.24]

// The order of events goes as follows:
// 1. ModifyDamage is called
// 2. Critted is called with whatever the result is normally
// 3. ForceCrit is called
enum NextIsCrit {
	GotNaturalCrit = 2,
	NextIsCrit = 1,
	NoCrit = 0,
}

class Croupled extends WeaponPerk {
	static Name = "Croupled"
	static Icon = PerkIcon.X
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = [{
		Range: DAMAGE_RANGE,
		Upgrades: [1, 1.04, 1.08, 1.12],
	}]

	nextIsCrit = NextIsCrit.NoCrit

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Pistol"
	}

	Critted(critMethod: CritMethod) {
		if (critMethod === CritMethod.Natural) {
			this.nextIsCrit = NextIsCrit.GotNaturalCrit
		}
	}

	ModifyDamage(damage: number): number {
		if (this.nextIsCrit === NextIsCrit.NextIsCrit) {
			damage *= (1 + this.Value(0))
		}

		return damage
	}

	ShouldCrit(): CritDecision {
		switch (this.nextIsCrit) {
			case NextIsCrit.NextIsCrit:
				this.nextIsCrit = NextIsCrit.NoCrit
				return CritDecision.ForceCrit
			case NextIsCrit.GotNaturalCrit:
				this.nextIsCrit = NextIsCrit.NextIsCrit
			default:
				return CritDecision.Default
		}
	}
}

export = Croupled
