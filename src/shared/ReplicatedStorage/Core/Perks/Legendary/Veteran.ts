import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const DAMAGE_RESIST_RANGE = [0.3, 0.35]

class Veteran extends WeaponPerk {
	static Name = "Veteran"
	static Icon = PerkIcon.Defense
	static LegendaryPerk = true
	static PowerBuff = 1.15

	static Values = [{
		Range: DAMAGE_RESIST_RANGE,
		UpgradePercent: [1, 1.05, 1.1, 1.15],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Rifle"
	}

	ModifyDamageTaken(damage: number): number {
		const ammoInfo = this.AmmoInfo()
		const resist = this.Value(0) * (ammoInfo.AmmoLeft / ammoInfo.Magazine)
		return damage * (1 - resist)
	}
}

export = Veteran
