import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"
import { Gun, GunItem } from "shared/ReplicatedStorage/Core/Loot"

const BASE_DAMAGE_LOSS = 1 - 0.15
const DAMAGE_BUFF_PER_SHOT = [0.8, 1.1]

class Rattata extends WeaponPerk {
	static Name = "Ratatatatatat!!"
	static Icon = PerkIcon.Bullet
	static LegendaryPerk = true
	static PowerBuff = 1.2

	static Values = [{
		Range: DAMAGE_BUFF_PER_SHOT,
		UpgradePercent: [1, 1.05, 1.1, 1.15],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Rifle"
	}

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * BASE_DAMAGE_LOSS,
		}
	}

	ModifyDamage(damage: number): number {
		const ammoWhenShot = this.AmmoInfo().AmmoLeft + 1
		return damage * ((1 + this.Value(0) / 100) ** ammoWhenShot)
	}
}

export = Rattata

