import { RunService } from "@rbxts/services"
import CalculateGearScore from "shared/ReplicatedStorage/Core/CalculateGearScore"
import GunScaling from "shared/ReplicatedStorage/Core/GunScaling"
import { Perks } from "./index"
import { Perk } from "./Perk"
import * as PerkUtil from "./PerkUtil"

const GUN = {
	Type: "Pistol",
	Level: 20,
	Rarity: 1,

	Bonus: 0,
	Favorited: false,
	Seed: 0,

	Perks: [],

	Model: 1,
	UUID: "TEST",
}

export = () => {
	if (RunService.IsClient()) {
		it("should have a description for every perk", () => {
			for (const perk of Perks) {
				if (PerkUtil.GetPerkDescription(perk, 0, 0).match("PERK_DESC_")[0] !== undefined) {
					error(`${perk.Name} has no description`)
				}
			}
		})
	}

	it("should have an icon for every perk", () => {
		for (const perk of Perks) {
			if (perk.Icon === Perk.Icon) {
				error(`${perk.Name} has no icon`)
			}
		}
	})

	it("should not lower an items power at base", () => {
		const basePower = CalculateGearScore(GUN)

		for (const perk of Perks) {
			const newPower = CalculateGearScore({
				...GUN,
				Perks: [{
					Perk: perk as unknown as typeof Perk,
					Upgrades: 0,
				}],
			})

			assert(newPower >= basePower, `${perk.Name} lowers base power: ${basePower} -> ${newPower}`)
		}
	})

	it("should not lower an items power when upgraded", () => {
		for (const perk of Perks) {
			const basePower = CalculateGearScore({
				...GUN,
				Perks: [{
					Perk: perk as unknown as typeof Perk,
					Upgrades: 0,
				}],
			})

			for (let upgrades = 1; upgrades <= 3; upgrades++) {
				const newPower = CalculateGearScore({
					...GUN,
					Perks: [{
						Perk: perk as unknown as typeof Perk,
						Upgrades: upgrades,
					}],
				})

				assert(newPower >= basePower, `${perk.Name} lowers base power when upgraded ${upgrades} times: ${basePower} -> ${newPower}`)
			}
		}
	})
}
