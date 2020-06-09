import * as Basic from "./Basic"
import { WeaponPerk } from "./Perk"
import { Gun } from "shared/ReplicatedStorage/Core/Loot"
import GunScaling from "shared/ReplicatedStorage/Core/GunScaling"

const createTestGun = () => GunScaling.StatsFor({
	Type: "Pistol",
	Level: 20,
	Rarity: 1,

	Bonus: 0,
	Favorited: false,
	Seed: 0,

	Perks: {},

	Model: 1,
	UUID: "TEST",
})

type Comparator = (a: number, b: number) => [boolean, string]

const bigger: Comparator = (a, b) => [a > b, `expected ${a} to be bigger than ${b}`]
const smaller: Comparator = (a, b) => [a < b, `expected ${a} to be smaller than ${b}`]
const equal: Comparator = (a, b) => [a === b, `expected ${a} to equal ${b}`]
const orEqual: (comparator: Comparator) => Comparator =
	(comparator) => (a: number, b: number) => {
		if (a !== b) {
			return comparator(a, b)
		} else {
			return [true, ""]
		}
	}

function assertWithInfo(info: string, condition: boolean, message: string) {
	assert(condition, `${info}: ${message}`)
}

function perkTestModifier(
	perk: typeof WeaponPerk,
	stats: Partial<{ [key in KeysWithValue<Gun, number>]: Comparator[] }>,
): () => void {
	return () => {
		const base = createTestGun()
		const zeroUpgrades = perk.ModifyStats(createTestGun(), 0)
		const oneUpgrade = perk.ModifyStats(createTestGun(), 1)

		for (const [statName, comparators] of Object.entries(stats)) {
			const compareToBase = comparators[0]
			const compareToInitial = comparators[1] || compareToBase
			assertWithInfo(statName, ...compareToBase(zeroUpgrades[statName], base[statName]))
			assertWithInfo(statName, ...compareToInitial(oneUpgrade[statName], zeroUpgrades[statName]))
		}
	}
}

export = () => {
	it("Gunpowder", perkTestModifier(Basic.Gunpowder, {
		Damage: [bigger],
	}))

	it("Rapid", perkTestModifier(Basic.Rapid, {
		FireRate: [bigger],
	}))

	it("Loaded", perkTestModifier(Basic.Loaded, {
		Magazine: [orEqual(bigger)],
	}))

	it("Quickload", perkTestModifier(Basic.Quickload, {
		ReloadTime: [smaller],
	}))

	it("Lucky", perkTestModifier(Basic.Lucky, {
		CritChance: [bigger],
	}))

	it("Bullseye", perkTestModifier(Basic.Bullseye, {
		CritDamage: [bigger],
	}))

	it("Jack", perkTestModifier(Basic.Jack, {
		Damage: [bigger],
		FireRate: [bigger],
		Magazine: [orEqual(bigger)],
		ReloadTime: [smaller],
	}))

	it("FMJ Rounds", perkTestModifier(Basic.FMJ, {
		Damage: [bigger],
		Magazine: [smaller],
	}))

	it("No Luck Needed", perkTestModifier(Basic.NoLuckNeeded, {
		CritChance: [smaller, bigger],
		CritDamage: [smaller, bigger],
		Damage: [bigger, equal],
	}))

	it("Mini Mags", perkTestModifier(Basic.MiniMags, {
		ReloadTime: [smaller, bigger],
		Magazine: [smaller, equal],
	}))
}
