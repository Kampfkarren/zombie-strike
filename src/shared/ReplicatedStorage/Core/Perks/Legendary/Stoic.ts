import { WeaponPerk } from "../Perk"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { IsReloading } from "shared/ReplicatedStorage/Core/Reloading"
import PerkIcon from "../PerkIcon"

const DEFENSE_RANGE = [0.7, 0.8]

class Stoic extends WeaponPerk {
	static Name = "Stoic"
	static Icon = PerkIcon.Defense
	static LegendaryPerk = true
	static PowerBuff = 1.15

	static Values = [{
		Range: DEFENSE_RANGE,
		UpgradePercent: [1, 1.04, 1.08, 1.12],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Rifle"
	}

	ModifyDamageTaken(damage: number): number {
		return IsReloading(this.player)
			? damage * (1 - this.Value(0))
			: damage
	}
}

export = Stoic
