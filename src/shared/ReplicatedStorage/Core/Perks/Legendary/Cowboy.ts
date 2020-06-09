import { Gun, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.6, 0.64]
const FIRE_RATE_NERF = 1 - 0.35
const MAGAZINE_NERF = 1 - 0.4
const RELOAD_NERF = 1.2

class Cowboy extends WeaponPerk {
	static Name = "Cowboy"
	static Icon = PerkIcon.Pistol
	static LegendaryPerk = true
	static PowerBuff = 1.1

	static Values = [{
		Range: DAMAGE_RANGE,
		UpgradePercent: [1, 1.04, 1.08, 1.12],
	}]

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * (1 + Cowboy.GetValue(
				gun.Seed,
				upgrades,
				{
					...Cowboy.Values[0],
					Offset: 0,
				},
			)),
			FireRate: gun.FireRate * FIRE_RATE_NERF,
			Magazine: math.floor(gun.Magazine * MAGAZINE_NERF + 0.5),
			ReloadTime: gun.ReloadTime * RELOAD_NERF,
		}
	}

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Pistol"
	}
}

export = Cowboy
