import { CollectionService, ServerStorage } from "@rbxts/services"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { WeaponPerk } from "../Perk"
import * as PerkUtil from "../PerkUtil"
import PerkIcon from "../PerkIcon"

const STUN_CHANCE = [0.08, 0.12]
const STUN_COOLDOWN = 2
const STUN_TIME = 1

class Buckd extends WeaponPerk {
	static Name = "Buck'd"
	static Icon = PerkIcon.Starry
	static LegendaryPerk = true
	static PowerBuff = 1.15

	static Values = [{
		Range: STUN_CHANCE,
		UpgradePercent: [1, 1.05, 1.1, 1.15],
	}]

	// Make sure we're only checking once per shot, instead of per pellet
	lastShot: number = 0
	lastStunned: number = 0

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Shotgun"
	}

	DamageDealt(_: number, zombieHumanoid: Humanoid) {
		if (tick() - this.lastShot <= 0.1) {
			return
		}

		if (tick() - this.lastStunned <= STUN_COOLDOWN) {
			return
		}

		const zombie = zombieHumanoid.Parent as Character
		if (CollectionService.HasTag(zombie, "Boss")) {
			return
		}

		if (zombie.FindFirstChild("Head") === undefined) {
			return
		}

		this.lastShot = tick()

		const maid = new Maid()
		const roll = math.random()

		if (roll <= this.Value(0)) {
			this.lastStunned = tick()

			const emitter = ServerStorage.Assets.BuckdEmitter.Clone()
			emitter.Parent = zombie.Head
			emitter.Emit(10)
			maid.GiveTaskParticleEffect(emitter)

			const zombieClass = PerkUtil.GetZombieFromHumanoid(zombieHumanoid)
			if (zombieClass !== undefined) {
				maid.GiveTask(zombieClass.GiveBuff("Speed", -100))
			}

			RealDelay(STUN_TIME, () => {
				maid.DoCleaning()
			})
		}
	}
}

export = Buckd
