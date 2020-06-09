import { GetDPS } from "shared/ReplicatedStorage/Core/DamageCalculations"
import { IsArmor, IsHelmet, IsWeapon } from "shared/ReplicatedStorage/Core/Loot"
import { ArmorHealth, HelmetHealth } from "./ArmorScaling"
import { Perk } from "./Perks/Perk"

const EXPECTED_NOOB_PISTOL_GEAR_SCORE = 50
const MULTIPLIERS = {
	Pistol: 1.025,
	Rifle: 1,
	SMG: 0.9,
	Shotgun: 0.85,
	Sniper: 0.9,
	Crystal: 1,
}
const PERK_UPGRADE_BUFF = 0.05
const WEARABLE_MULTIPLIER = 2

function CalculateUnfudgedGearScore(item: {
	Type: string,
	[key: string]: unknown,
}): number {
	if (IsWeapon(item)) {
		return math.floor(GetDPS(item) * 1.5 * MULTIPLIERS[item.Type] + 0.5)
	} else if (IsArmor(item)) {
		return math.floor(ArmorHealth(item.Level, item.Rarity) * WEARABLE_MULTIPLIER + 0.5)
	} else if (IsHelmet(item)) {
		return math.floor(HelmetHealth(item.Level, item.Rarity) * WEARABLE_MULTIPLIER + 0.5)
	} else {
		warn(`CalculateGearScore called on ${item.Type}`)
		return 0
	}
}

const NOOB_PISTOL_UNFUDGED_GEAR_SCORE = CalculateUnfudgedGearScore({
	Type: "Pistol",
	Level: 1,
	Rarity: 1,
	Perks: [],
})

function CalculateGearScore(item: {
	Type: string,
	Perks?: {
		Perk: typeof Perk,
		Upgrades: number,
	}[],
}): number {
	let gearScore = CalculateUnfudgedGearScore(item)

	if (IsWeapon(item)) {
		gearScore += (EXPECTED_NOOB_PISTOL_GEAR_SCORE - NOOB_PISTOL_UNFUDGED_GEAR_SCORE)
	}

	if (item.Perks !== undefined) {
		const scale = item.Perks.reduce((acc, perk) => {
			return acc + (perk.Perk.PowerBuff - 1) + (PERK_UPGRADE_BUFF * perk.Upgrades)
		}, 1)

		gearScore *= scale
	}

	return math.ceil(gearScore)
}

export = CalculateGearScore
