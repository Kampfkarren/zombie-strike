import { RunService } from "@rbxts/services"
import { Perk, Scope, WeaponPerk } from "./Perk"
import WeakInstanceTable from "shared/ReplicatedStorage/Core/WeakInstanceTable"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { RarityIndex } from "types/Rarity"

// oh boy
import * as Basic from "./Basic"
import * as DamageMods from "./DamageMods"
import * as Defeat from "./Defeat"
import * as FireRateMods from "./FireRateMods"
import * as Shooting from "./Shooting"
import Buckd from "./Legendary/Buckd"
import Burst from "./Legendary/Burst"
import ColdRounds from "./Legendary/ColdRounds"
import Cowboy from "./Legendary/Cowboy"
import Croupled from "./Legendary/Croupled"
import DoubleBarrel from "./Legendary/DoubleBarrel"
import DoubleShot from "./Legendary/DoubleShot"
import DualWield from "./Legendary/DualWield"
import ExplosiveRounds from "./Legendary/ExplosiveRounds"
import IncindearyRounds from "./Legendary/IncindearyRounds"
import LMG from "./Legendary/LMG"
import Medic from "./Legendary/Medic"
import Overkilled from "./Legendary/Overkilled"
import PopPop from "./Legendary/PopPop"
import Rattata from "./Legendary/Rattata"
import Resplosion from "./Legendary/Resplosion"
import ShowOfSkill from "./Legendary/ShowOfSkill"
import Stoic from "./Legendary/Stoic"
import Veteran from "./Legendary/Veteran"
import Zap from "./Legendary/Zap"
import ZombieGoBoom from "./Legendary/ZombieGoBoom"

const LOW_PERK_CHANCE = 0.75
const PERKS = WeakInstanceTable<Player, Perk[]>()
const PERKS_PER_RARITY = {
	[RarityIndex.Common]: [1, 1],
	[RarityIndex.Uncommon]: [1, 2],
	[RarityIndex.Rare]: [2, 3],
	[RarityIndex.Epic]: [3, 4],
	[RarityIndex.Legendary]: [3, 4],
}

const LEGENDARY_PERK_CHANCES = [
	0.43,
	0.32,
	0.19,
	0.06,
]

function createRollStrategy(rng: Random, perkCount: number): () => boolean {
	let roll = rng.NextNumber()
	let cumulative = 0
	let perksToRoll: number | undefined

	let chances = [...LEGENDARY_PERK_CHANCES]
	if (perkCount !== LEGENDARY_PERK_CHANCES.size()) {
		let toRedistribute = 0
		while (chances.size() > perkCount) {
			toRedistribute += chances.pop()!
		}

		chances = chances.map(chance => chance + toRedistribute / perkCount)
	}

	for (const [index, chance] of chances.entries().reverse()) {
		if (roll <= chance + cumulative) {
			perksToRoll = index + 1
			break
		} else {
			cumulative += chance
		}
	}

	if (perksToRoll === undefined) {
		warn("perksToRoll === undefined!")
		perksToRoll = 1
	}

	return () => {
		if (perksToRoll === 0) {
			return false
		} else {
			perksToRoll! -= 1
			return true
		}
	}
}

const DEFAULT_GENERATE_WEAPON_PERKS_FOR_RARITY_OPTIONS = {
	ForcePerks: undefined as number | undefined,
	Random: new Random(),
	RollLegendaryStrategy: () => {
		warn("default RollLegendaryStrategy called!")
		return false
	},
}

export function GenerateWeaponPerksForRarity(
	gun: Readonly<GunItem>,
	rarity: RarityIndex,
	options: Partial<typeof DEFAULT_GENERATE_WEAPON_PERKS_FOR_RARITY_OPTIONS> = {},
): [number, number][] {
	const fullOptions = {
		...DEFAULT_GENERATE_WEAPON_PERKS_FOR_RARITY_OPTIONS,
		...options,
	}

	const [min, max] = PERKS_PER_RARITY[rarity]
	const perks: [number, number][] = []

	const normalPerks: number[] = []
	const legendaryPerks: number[] = []

	for (const [index, perk] of Perks.entries().filter(entry => {
		return entry[1].ShouldApply(gun)
	})) {
		(perk.LegendaryPerk ? legendaryPerks : normalPerks).push(index + 1)
	}

	const perkCount = options.ForcePerks || (fullOptions.Random.NextNumber() <= LOW_PERK_CHANCE ? min : max)

	if (fullOptions.RollLegendaryStrategy === DEFAULT_GENERATE_WEAPON_PERKS_FOR_RARITY_OPTIONS.RollLegendaryStrategy) {
		fullOptions.RollLegendaryStrategy = createRollStrategy(fullOptions.Random, perkCount)
	}

	for (let _ = 0; _ < perkCount; _++) {
		const pullFrom = (
			rarity === RarityIndex.Legendary && fullOptions.RollLegendaryStrategy()
				? legendaryPerks
				: normalPerks
		)

		perks.push([
			assert(
				pullFrom.unorderedRemove(
					fullOptions.Random.NextInteger(0, pullFrom.size() - 1),
				),
				"perk table is empty",
			),
			0,
		])
	}

	return perks
}

export function GetPerksFor(player: Player): Perk[] {
	const perks = PERKS.get(player)

	return perks ? perks.filter(perk => {
		const perkClass = getmetatable(perk as unknown as object) as typeof Perk
		return PerkInScope(perkClass)
	}) : []
}

export function SetPerksFor(player: Player, perks: Perk[]) {
	PERKS.set(player, perks)
}

export function PerkInScope(perkClass: typeof Perk): boolean {
	switch (perkClass.Scope) {
		case Scope.Both:
			return true
		case Scope.Client:
			return RunService.IsClient()
		case Scope.Server:
			return RunService.IsServer()
	}
}

// DO NOT RE-ORDER!!!
export const Perks: (typeof WeaponPerk)[] = [
	Basic.Bullseye,
	Basic.FMJ,
	Basic.Gunpowder,
	Basic.Jack,
	Basic.Loaded,
	Basic.Lucky,
	Basic.MiniMags,
	Basic.NoLuckNeeded,
	Basic.Quickload,
	Basic.Rapid,
	DamageMods.Berserk,
	DamageMods.BossSlayer,
	DamageMods.CQC,
	DamageMods.Finisher,
	DamageMods.SuperSlayer,
	Defeat.Eater,
	Defeat.Hustle,
	Defeat.Rampage,
	Defeat.Tank,
	FireRateMods.Readied,
	FireRateMods.Stress,
	Shooting.Vampire,
	ColdRounds,
	DualWield,
	ExplosiveRounds,
	Medic,
	Overkilled,
	Zap,
	Croupled,
	DoubleShot,
	Burst,
	Veteran,
	DoubleBarrel,
	Cowboy,
	IncindearyRounds,
	ShowOfSkill,
	Resplosion,
	Rattata,
	ZombieGoBoom,
	Buckd,
	PopPop,
	Stoic,
	LMG,
]
