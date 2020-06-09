import { ServerStorage } from "@rbxts/services"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import WeakInstanceTable from "shared/ReplicatedStorage/Core/WeakInstanceTable"
import { GetZombieFromHumanoid } from "shared/ReplicatedStorage/Core/Perks/PerkUtil"
import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const CHANCE = 1
const COOLDOWN = 4
const TIMER = 1.5
const SLOW_RANGE = [0.2, 0.2]

class ColdRounds extends WeaponPerk {
	static Name = "Cold Rounds"
	static Icon = PerkIcon.Snowflake
	static LegendaryPerk = true
	static PowerBuff = 1.15

	static Values = [{
		Range: SLOW_RANGE,
	}]

	lastFrozen = WeakInstanceTable<Humanoid, number>()

	DamageDealt(_: number, humanoid: Humanoid) {
		if (math.random() <= CHANCE
			&& tick() - (this.lastFrozen.get(humanoid) || 0) >= COOLDOWN
		) {
			const zombie = GetZombieFromHumanoid(humanoid)
			if (zombie !== undefined) {
				const maid = new Maid()

				maid.GiveTask(zombie.GiveBuff("Speed", -this.Value(0)))
				this.lastFrozen.set(humanoid, tick())

				const emitter = ServerStorage.Assets.ColdRoundsEmitter.Clone()
				emitter.Parent = zombie.instance.PrimaryPart
				emitter.Emit(10)
				maid.GiveTaskParticleEffect(emitter)

				RealDelay(TIMER, () => {
					maid.DoCleaning()
				})
			}
		}
	}
}

export = ColdRounds
