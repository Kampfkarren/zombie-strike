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

	function IsAttachment(loot: {
		Type: string,
	}): boolean
}

export = Loot
