import { WeaponPerk } from "../Perk"
import { Gun, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.1, 0.14]
const MAGAZINE_BUFF = 1.6
const RELOAD_TIME_NERF = 3

class LMG extends WeaponPerk {
	static Name = "LMG"
	static Icon = PerkIcon.Bullet
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = [{
		Range: DAMAGE_RANGE,
		UpgradePercent: [1, 1.05, 1.1, 1.15],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Rifle"
	}

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * (1 + WeaponPerk.GetValue(gun.Seed, upgrades, {
				...LMG.Values[0],
				Offset: 0,
			})),
			Magazine: math.floor(gun.Magazine * MAGAZINE_BUFF + 0.5),
			ReloadTime: gun.ReloadTime * RELOAD_TIME_NERF,
		}
	}
}

export = LMG
