import { Gun, GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { WeaponPerk, DOESNT_UPGRADE } from "./Perk"
import PerkIcon from "./PerkIcon"

type Stat = {
	Range: [number, number],
	Offset?: number,
	UpgradePercent?: number[],
}

function range(range: [number, number]): Stat {
	return {
		Range: range,
	}
}

function makeBasicWeaponPerk<P extends {
	[stat in keyof Partial<Omit<Gun, "Type" | "UUID">>]?: Stat
}>(name: string, stats: P, options?: {
	DisableForCrystal?: boolean,
	Icon?: string,
	PowerBuff?: number,
	Round?: (keyof P)[],
}): typeof WeaponPerk {
	const values = Object.entries(stats).map(([_, stat]) => {
		return {
			Offset: 0,
			...stat,
		}
	}).sort((a, b) => {
		return a.Offset < b.Offset
	})

	return class BasicWeaponPerk extends WeaponPerk {
		static Icon = (options && options.Icon) || PerkIcon.Bullet
		static Name = name
		static PowerBuff = (options && options.PowerBuff) || 1
		static Values = values

		static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
			if (gun.Type === "Crystal"
				&& options !== undefined
				&& options.DisableForCrystal
			) {
				return false
			}

			return true
		}

		static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
			const newGun = { ...gun }

			for (const [statName, statInfo] of Object.entries(stats)) {
				newGun[statName] += newGun[statName]
					* BasicWeaponPerk.GetValue(
						gun.Seed,
						upgrades,
						assert(
							values.find(value => value.Offset === (statInfo.Offset || 0)),
							`Couldn't find value for ${statName} on ${name}!`,
						),
					)

				if (options !== undefined && options.Round !== undefined && options.Round.includes(statName)) {
					newGun[statName] = math.floor(newGun[statName] + 0.5)
				}
			}

			return newGun
		}
	}
}

export const Gunpowder = makeBasicWeaponPerk("Gunpowder", {
	Damage: range([0.1, 0.13]),
}, {
	Round: ["Damage"],
})

export const Rapid = makeBasicWeaponPerk("Rapid", {
	FireRate: range([0.1, 0.13]),
})

export const Loaded = makeBasicWeaponPerk("Loaded", {
	Magazine: range([0.1, 0.13]),
}, {
	DisableForCrystal: true,
	Round: ["Magazine"],
})

export const Quickload = makeBasicWeaponPerk("Quickload", {
	ReloadTime: range([-0.1, -0.13]),
}, {
	DisableForCrystal: true,
	Icon: PerkIcon.Reload,
})

export const Lucky = makeBasicWeaponPerk("Lucky", {
	CritChance: range([0.1, 0.13]),
}, {
	Icon: PerkIcon.Dice,
})

export const Bullseye = makeBasicWeaponPerk("Bullseye", {
	CritDamage: range([0.1, 0.13]),
}, {
	Icon: PerkIcon.Bullseye,
})

export const Jack = makeBasicWeaponPerk("Jack", {
	Damage: {
		Range: [0.05, 0.065],
		Offset: 0,
	},

	FireRate: {
		Range: [0.05, 0.065],
		Offset: 1,
	},

	Magazine: {
		Range: [0.05, 0.065],
		Offset: 2,
	},

	ReloadTime: {
		Range: [-0.05, -0.065],
		Offset: 3,
	},
}, {
	DisableForCrystal: true,
	Icon: PerkIcon.Starry,
	Round: ["Magazine"],
})

export const FMJ = makeBasicWeaponPerk("FMJ Rounds", {
	Damage: {
		Range: [0.15, 0.22],
		Offset: 0,
	},

	Magazine: {
		Range: [-0.3, -0.3],
		Offset: 1,
	},
}, {
	DisableForCrystal: true,
	Icon: PerkIcon.Fist,
	Round: ["Magazine"],
})

export const NoLuckNeeded = makeBasicWeaponPerk("No Luck Needed", {
	CritChance: {
		Range: [-0.3, -0.3],
		Offset: 0,
		UpgradePercent: [1, 1 - 0.1, 1 - 0.15, 1 - 0.2],
	},

	CritDamage: {
		Range: [-0.3, -0.3],
		Offset: 1,
		UpgradePercent: [1, 1 - 0.1, 1 - 0.15, 1 - 0.2],
	},

	Damage: {
		Range: [0.18, 0.18],
		Offset: 2,
		UpgradePercent: DOESNT_UPGRADE,
	},
}, {
	Icon: PerkIcon.Dice,
})

export const MiniMags = makeBasicWeaponPerk("Mini Mags", {
	ReloadTime: {
		Range: [-0.25, -0.31],
		UpgradePercent: [1, 1 - 0.06, 1 - 0.12, 1 - 0.18],
	},

	Magazine: {
		Range: [-0.25, -0.25],
		Offset: 1,
		UpgradePercent: DOESNT_UPGRADE,
	},
}, {
	DisableForCrystal: true,
	Icon: PerkIcon.Pistol,
	PowerBuff: 1.11,
	Round: ["Magazine"],
})
