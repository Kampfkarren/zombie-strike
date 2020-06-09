import { RarityIndex } from "types/Rarity"
import { WeaponPerk } from "./Perks/Perk"

declare namespace Loot {
	const Attachments: [
		"Laser",
		"Magazine",
		"Silencer",
	]

	const GunTypes: [
		"Pistol",
		"Rifle",
		"SMG",
		"Shotgun",
		"Sniper",
		"Crystal",
	]

	type LootType = ExtractTypes<typeof Loot["GunTypes"]> | "Armor" | "Helmet"

	type Gun = {
		Type: typeof GunTypes[number],
		Bonus: number,
		CritChance: number,
		CritDamage: number,
		Damage: number,
		FireRate: number,
		Magazine: number,
		ReloadTime: number,
		Seed: number,
		ShotSize: number,
		UUID: string,
	}

	type GunConfig = Omit<Gun, "Type"> & {
		GunType: Gun["Type"],
	} & ({
		FireMode: "Auto",
	} | {
		FireMode: "Burst",
		BurstAmount: number,
		BurstRate: number,
	})

	type GunItem = {
		Type: Gun["Type"],
		Level: number,
		Rarity: number,

		Bonus: number,
		Favorited: boolean,
		Seed: number,

		Perks: {
			Perk: typeof WeaponPerk,
			Upgrades: number,
		}[],

		Model: number,
		UUID: string,
	}

	type Wearable = {
		Type: "Armor" | "Helmet",
		Level: number,
		Rarity: RarityIndex,
	}

	function GetLootName(loot: {
		Type: string,
	}): string

	function IsAttachment(loot: {
		Type: string,
	}): boolean

	function IsArmor(loot: {
		Type: string
	}): loot is Wearable & {
		Type: "Armor",
	}

	function IsHelmet(loot: {
		Type: string
	}): loot is Wearable & {
		Type: "Helmet",
	}

	function IsWeapon(loot: {
		Type: string,
	}): loot is Gun
}

export = Loot
