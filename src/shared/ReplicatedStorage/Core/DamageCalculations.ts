import { Gun, GunConfig } from "./Loot"
import { StatsFor } from "shared/ReplicatedStorage/Core/GunScaling"

export function GetDamageNeededForDPS(config: GunConfig, dps: number): number {
	const magazine = config.GunType === "Crystal" ? 10e10 : config.Magazine
	return (100 * dps * (config.FireRate * config.ReloadTime + magazine))
		/ (config.FireRate * magazine * (config.CritChance * config.CritDamage + 100))
}

export function GetDPS(item: Gun): number {
	const config = StatsFor(item)
	let dmg = config.Damage + (config.Damage * (config.CritChance / 100) * config.CritDamage)

	if (item.Type === "Shotgun") {
		dmg *= config.ShotSize
	}

	if (item.Type === "Crystal") {
		return dmg * config.FireRate
	} else {
		return (dmg * config.Magazine) / ((config.Magazine / config.FireRate) + config.ReloadTime)
	}
}
