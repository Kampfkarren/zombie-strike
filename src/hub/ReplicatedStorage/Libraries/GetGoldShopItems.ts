import { GoldShopItems, GoldShopWeapon, GetRotation, GUNS_TO_SELL, MAX_LEVEL } from "hub/ReplicatedStorage/Libraries/GoldShopItemsUtil"
import { GunTypes } from "shared/ReplicatedStorage/Core/Loot"
import LootStyles from "shared/ReplicatedStorage/Core/LootStyles"
import { GenerateWeaponPerksForRarity, Perks } from "shared/ReplicatedStorage/Core/Perks"
import { RarityIndex } from "types/Rarity"

const LEGENDARY_CHANCE = 1 / 4
const RARITIES = ["Rare", "Epic", "Legendary"] as const
const RARITY_ROLLS = ["Rare", "Rare", "Rare", "Epic", "Epic"] as const

assert(RARITY_ROLLS.size() >= GUNS_TO_SELL, "More guns to sell than there are rarities!")

const COSTS = {
	"Rare": 5_000,
	"Epic": 10_000,
	"Legendary": 20_000,
}

const LEGENDARY_PERK_CHANCES = [0.6, 0.245, 0.15, 0.005]
const VARY_COST: [number, number] = [0.96, 1.04]

function createLegendaryRoller(rng: Random): () => boolean {
	let perksRolled = 0
	let noMorePerks = false

	return () => {
		if (noMorePerks) {
			return false
		}

		if (rng.NextNumber() <= LEGENDARY_PERK_CHANCES[perksRolled]) {
			perksRolled += 1
			return true
		} else {
			noMorePerks = true
			return false
		}
	}
}

function generateWeapon(rng: Random, rarity: ValueOf<typeof RARITIES>, fakeUuid: number): GoldShopWeapon {
	let cost = math.floor(COSTS[rarity] * rng.NextNumber(...VARY_COST))
	cost = math.floor(cost / 10) * 10 // Round to nearest 10

	const gun = {
		Type: GunTypes[rng.NextInteger(0, GunTypes.size() - 1)],
		Rarity: LootStyles.findIndex(style => style.Name === rarity) + 1,

		Bonus: rng.NextInteger(0, 35),
		Seed: rng.NextInteger(0, 1000),
		Favorited: false,
		UUID: tostring(fakeUuid),

		Perks: [] as GoldShopWeapon["Gun"]["Perks"],
		Model: LootStyles.findIndex(style => style.Name === rarity) + 1,
	}

	const perks = GenerateWeaponPerksForRarity(
		{
			...gun,
			Perks: [],
			Level: 0,
		},
		RARITIES.indexOf(rarity) + RarityIndex.Rare,
		rarity === "Legendary" ? {
			ForcePerks: LEGENDARY_PERK_CHANCES.size(),
			Random: rng,
			RollLegendaryStrategy: createLegendaryRoller(rng),
		} : {
				Random: rng,
			},
	).map(perk => perk[0])

	gun.Perks = perks.map(perk => {
		return {
			Perk: Perks[perk - 1],
			Upgrades: 0,
		}
	})

	return {
		Cost: cost,
		LevelOffset: rng.NextInteger(0, 4),
		Gun: gun,
		Perks: perks,
	}
}

function GetGoldShopItems(userId: number, timestamp: number, level?: number): GoldShopItems {
	const seed = userId + GetRotation(timestamp)
	const rng = new Random(seed)

	const samples = [...RARITY_ROLLS]
	const weapons = []

	for (let index = 0; index < GUNS_TO_SELL; index++) {
		weapons.push(generateWeapon(
			rng,
			samples.unorderedRemove(
				rng.NextInteger(0, samples.size() - 1))!,
			seed + index,
		))
	}

	if (rng.NextNumber() <= LEGENDARY_CHANCE) {
		const weapon = generateWeapon(rng, "Legendary", seed + 100)
		if (level !== undefined && level + weapon.LevelOffset > MAX_LEVEL) {
			weapon.LevelOffset = MAX_LEVEL - level
		}

		weapons[rng.NextInteger(0, GUNS_TO_SELL - 1)] = weapon
	}

	return {
		Weapons: weapons,
	}
}

export = GetGoldShopItems
