import { Gun } from "./Loot"
import { StatsFor } from "shared/ReplicatedStorage/Core/GunScaling"

// TODO: Factor critical damage
export type GunConfig = {
	FireRate: number,
	GunType: string,
	Magazine: number,
	ReloadTime: number,
	Type: string,
}

export function GetDamageNeededForDPM(config: GunConfig, dpm: number): number {
	if (config.GunType === "Crystal") {
		return dpm / (60 * config.FireRate)
	}

	return (dpm * (config.FireRate * config.ReloadTime + config.Magazine))
		/ (60 * config.FireRate * config.Magazine)
}

export function GetDamageNeededForDPS(config: GunConfig, dps: number): number {
	if (config.GunType === "Crystal") {
		return dps / config.FireRate
	}

	return (dps * (config.FireRate * config.ReloadTime + config.Magazine))
		/ (config.FireRate * config.Magazine)
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
