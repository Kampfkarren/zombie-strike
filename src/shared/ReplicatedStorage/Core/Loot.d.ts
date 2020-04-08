type ExtractTypes<T> = T extends (infer U)[] ? U : never

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
		CritChance: number,
		CritDamage: number,
		Damage: number,
		FireRate: number,
		Magazine: number,
		ReloadTime: number,
		ShotSize: number,
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
