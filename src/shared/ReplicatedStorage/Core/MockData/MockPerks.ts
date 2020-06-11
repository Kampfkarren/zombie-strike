import { Perks } from "shared/ReplicatedStorage/Core/Perks"

function findPerk(name: string): number {
	for (const [index, perk] of Perks.entries()) {
		if (perk.Name === name) {
			return index + 1
		}
	}

	throw `Could not find perk "${name}"`
}

export =[
	[findPerk("Cold Rounds"), 0],
]
// export = undefined
