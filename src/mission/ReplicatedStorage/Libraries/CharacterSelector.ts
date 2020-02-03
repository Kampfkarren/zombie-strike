import { Players } from "@rbxts/services"

export function GetFarthestPlayer(fromPoint: Vector3, exclude?: Set<Player>): Player | undefined {
	let closest: [Player | undefined, number] = [undefined, -1]

	for (const player of Players.GetPlayers()) {
		if (exclude !== undefined && exclude.has(player)) {
			continue
		}

		const character = player.Character
		if (character !== undefined && character.PrimaryPart !== undefined) {
			const distance = character.PrimaryPart.Position.sub(fromPoint).Magnitude
			if (closest[1] < distance) {
				closest = [player, distance]
			}
		}
	}

	return closest[0]
}
