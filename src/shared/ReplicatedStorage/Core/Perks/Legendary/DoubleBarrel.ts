import { Gun, GunConfig, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { Scope, WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const AMMO_COST_MULTIPLIER = 2
const RELOAD_RANGE = [-0.05, -0.08]
const PELLET_COUNT_MULTIPLIER = 2

class DoubleBarrel extends WeaponPerk {
	static Name = "Double Barrel"
	static Icon = PerkIcon.Bullet
	static Scope = Scope.Both
	static LegendaryPerk = true
	static PowerBuff = 1.2

	static Values = [{
		Range: RELOAD_RANGE,
		UpgradePercent: [1, 1.1, 1.15, 1.2],
	}]

	static ModifyConfig(this: void, gun: Readonly<GunConfig>): GunConfig {
		return {
			...gun,
			ShotSize: gun.ShotSize * PELLET_COUNT_MULTIPLIER,
		}
	}

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			ReloadTime: gun.ReloadTime * (1 + DoubleBarrel.GetValue(
				gun.Seed,
				upgrades,
				{
					...DoubleBarrel.Values[0],
					Offset: 0,
				},
			))
		}
	}

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Shotgun"
	}

	ModifyAmmoCost(ammoCost: number): number {
		return ammoCost * AMMO_COST_MULTIPLIER
	}
}

export = DoubleBarrel
