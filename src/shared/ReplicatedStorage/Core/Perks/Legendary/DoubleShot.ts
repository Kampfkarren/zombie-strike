import { WeaponPerk } from "../Perk"
import { GunItem } from "../../Loot"
import PerkIcon from "../PerkIcon"

const CHANCE_RANGE = [0.08, 0.12]
const DAMAGE_BUFF = 2

class DoubleShot extends WeaponPerk {
	static Name = "Double Shot"
	static Icon = PerkIcon.Bullet
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = [{
		Range: CHANCE_RANGE,
		UpgradePercent: [1, 1.1, 1.15, 1.2],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Pistol"
	}

	ModifyDamage(damage: number): number {
		if (math.random() <= this.Value(0)) {
			damage *= DAMAGE_BUFF
		}

		return damage
	}
}

export = DoubleShot
