import { WeaponPerk, DOESNT_UPGRADE } from "./Perk"
import GiveSpeedMultiplier from "shared/ReplicatedStorage/Core/GiveSpeedMultiplier"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import PerkIcon from "./PerkIcon"

const HUSTLE_SPEED_LIFETIME = 1.5
const RAMPAGE_LIFETIME = 1.5
const TANK_SCALE = [1 - 0.3, 1 - 0.38]
const TANK_LIFETIME = [2, 2]

export class Eater extends WeaponPerk {
	static Name = "Eater"
	static Icon = PerkIcon.Plus
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.02, 0.04],
	}]

	ZombieKilled() {
		const character = this.player.Character as Character
		if (character !== undefined) {
			character.Humanoid.Health += character.Humanoid.MaxHealth
				* this.Value(0)
		}
	}
}

export class Hustle extends WeaponPerk {
	static Name = "Hustle"
	static Icon = PerkIcon.Arrow
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.03, 0.04],
	}]

	currentHustle: {
		Destroy: () => void,
		Tick: number,
	} | undefined

	QueueHustleRemoval() {
		const currentTick = this.currentHustle!.Tick
		RealDelay(HUSTLE_SPEED_LIFETIME, () => {
			if (this.currentHustle !== undefined && this.currentHustle.Tick === currentTick) {
				this.currentHustle.Destroy()
			}
		})
	}

	ZombieKilled() {
		if (this.currentHustle === undefined) {
			this.currentHustle = {
				Destroy: GiveSpeedMultiplier(this.Value(0), this.player),
				Tick: 0,
			}

			this.QueueHustleRemoval()
		} else {
			this.currentHustle.Tick += 1
			this.QueueHustleRemoval()
		}
	}
}

export class Rampage extends WeaponPerk {
	static Name = "R-R-Rampage!"
	static Icon = PerkIcon.Fist
	static PowerBuff = 1.18

	static Values = [{
		Range: [0.22, 0.26],
	}]

	lastZombieKilled: number = 0

	ModifyDamage(damage: number): number {
		if (tick() - this.lastZombieKilled <= RAMPAGE_LIFETIME) {
			return damage * (1 + this.Value(0))
		} else {
			return damage
		}
	}

	ZombieKilled() {
		this.lastZombieKilled = tick()
	}
}

export class Tank extends WeaponPerk {
	static Name = "The Tank"
	static Icon = PerkIcon.Defense
	static PowerBuff = 1.11

	static Values = [{
		Range: TANK_SCALE,
		UpgradePercent: DOESNT_UPGRADE,
	}, {
		Range: TANK_LIFETIME,
	}]

	lastZombieKilled: number = 0

	ModifyDamageTaken(damage: number): number {
		if (tick() - this.lastZombieKilled <= this.Value(1)) {
			return damage * this.Value(0)
		} else {
			return damage
		}
	}

	ZombieKilled() {
		this.lastZombieKilled = tick()
	}
}
