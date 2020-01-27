import Bosses from "shared/ReplicatedStorage/Core/Bosses"
import { BossInfo } from "shared/ReplicatedStorage/Core/BossInfo"

export = function (): {
	Info: BossInfo,
	Index: number,
} {
	// TODO: When we have more than one boss, make this iterate between them
	// If based on time, cache per player
	const bossIndex = 1

	return { Index: bossIndex, Info: Bosses[bossIndex - 1] }
}
