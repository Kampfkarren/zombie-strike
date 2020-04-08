import { Players } from "@rbxts/services"
import LineOfSight from "mission/ReplicatedStorage/Libraries/LineOfSight"

/// Gets the closest player within line of sight
export function GetClosestPlayer(fromPoint: Vector3, maxDistance: number = math.huge): Player | undefined {
	let closest: [Player | undefined, number] = [undefined, math.huge]

	for (const player of Players.GetPlayers()) {
		const character = player.Character as Character | undefined
		if (character !== undefined
			&& character.PrimaryPart !== undefined
			&& character.Humanoid.Health > 0
		) {
			const distance = character.PrimaryPart.Position.sub(fromPoint).Magnitude
			if (distance <= maxDistance && closest[1] > distance) {
				closest = [player, distance]
			}
		}
	}

	return closest[0]
}

/// Gets the farthest player regardless of line of sight
export function GetFarthestPlayer(fromPoint: Vector3, exclude?: Set<Player>): Player | undefined {
	let farthest: [Player | undefined, number] = [undefined, -1]

	for (const player of Players.GetPlayers()) {
		if (exclude !== undefined && exclude.has(player)) {
			continue
		}

		const character = player.Character
		if (character !== undefined && character.PrimaryPart !== undefined) {
			const distance = character.PrimaryPart.Position.sub(fromPoint).Magnitude
			if (farthest[1] < distance) {
				farthest = [player, distance]
			}
		}
	}

	return farthest[0]
}
