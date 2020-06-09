import { ReplicatedStorage, ServerScriptService } from "@rbxts/services"
import Translate from "shared/ReplicatedStorage/Core/Translate"
import { ZombieClass } from "mission/ServerScriptService/Zombies/ZombieClass";
import { Perk, WeaponPerk } from "./Perk"

export const MAX_PERK_UPGRADES = 3

type Zombie = {
	GetAliveZombies: () => ZombieClass[]
}

export function GetZombieFromHumanoid(humanoid: Humanoid): ZombieClass | undefined {
	if (ReplicatedStorage.HubWorld.Value) {
		return undefined
	} else {
		const Zombie: Zombie = require(ServerScriptService.Zombies.Zombie) as Zombie

		for (const zombie of Zombie.GetAliveZombies()) {
			if (zombie.instance.Humanoid === humanoid) {
				return zombie
			}
		}
	}
}

export function DeserializePerks(serialized: [number, number][]): {
	Perk: typeof Perk,
	Upgrades: number
}[] {
	// Prevent circular dependency, probably
	const Perks = require(script.Parent as ModuleScript) as {
		Perks: typeof Perk[],
	}

	return serialized.map(([perkIndex, upgrades]) => {
		return {
			Perk: Perks.Perks[perkIndex - 1],
			Upgrades: upgrades,
		}
	})
}

function formatNumber(number: number): string {
	if (math.abs(number) < 10) {
		return "%.1f".format(number)
	} else {
		return "%d".format(number)
	}
}

export function GetPerkDescription(perk: typeof WeaponPerk, seed: number, upgrades: number): string {
	const args = new Map<string, string>()

	for (const [index, valueData] of perk.Values.entries()) {
		const value = perk.GetValue(
			seed,
			upgrades,
			{
				Offset: index,
				...valueData,
			},
		)

		const rounded = math.floor(value * 1000 + 0.5) / 10

		args.set(`Value${index}`, formatNumber(rounded))
		args.set(`Value${index}_Negative`, formatNumber(-rounded))
		args.set(`Value${index}_Raw`, formatNumber(value))
	}

	return Translate(`PERK_DESC_${perk.Name}`, args)
}
