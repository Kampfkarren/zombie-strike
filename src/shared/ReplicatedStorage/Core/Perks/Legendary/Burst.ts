import { Gun, GunConfig, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { Perk, WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.04, 0.14]
const BURST_AMOUNT = 4
const BURST_RATE = 55
const FIRE_RATE_NERF = 0.6

class Burst extends WeaponPerk {
	static Name = "Burst"
	static Icon = PerkIcon.Bullet
	static LegendaryPerk = true
	static PowerBuff = 2.07

	static Values = [{
		Range: DAMAGE_RANGE,
		UpgradePercent: [1, 1.05, 1.1, 1.15],
	}]

	static ModifyConfig(this: void, gun: Readonly<GunConfig>, upgrades: number): GunConfig {
		return {
			...gun,
			FireMode: "Burst",
			BurstAmount: BURST_AMOUNT,
			BurstRate: BURST_RATE,
		}
	}

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * (1 + Perk.GetValue(
				gun.Seed,
				upgrades,
				{
					...Burst.Values[0],
					Offset: 0,
				}
			)),
			FireRate: gun.FireRate * (1 - FIRE_RATE_NERF),
		}
	}

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Rifle"
	}
}

export = Burst
