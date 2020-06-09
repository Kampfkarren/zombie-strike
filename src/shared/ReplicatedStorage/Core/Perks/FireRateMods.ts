import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import { Scope, WeaponPerk } from "./Perk"
import PerkIcon from "./PerkIcon"

const READIED_TIME = 1.5
const STRESS_LIFE = 0.3

export class Readied extends WeaponPerk {
	static Name = "Readied"
	static Icon = PerkIcon.Reload
	static Scope = Scope.Client
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.2, 0.25],
	}]

	lastReloaded = 0

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type !== "Crystal"
	}

	ModifyFireRate(fireRate: number): number {
		if (tick() - this.lastReloaded <= READIED_TIME) {
			return fireRate * (1 + this.Value(0))
		}

		return fireRate
	}

	Reloaded() {
		this.lastReloaded = tick()
	}
}

export class Stress extends WeaponPerk {
	static Name = "Stress"
	static Icon = PerkIcon.Reload
	static Scope = Scope.Client
	static PowerBuff = 1.15

	static Values = [{
		Range: [0.3, 0.35],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type !== "Crystal"
	}

	ModifyFireRate(fireRate: number): number {
		const character = this.player.Character as Character | undefined
		if (character !== undefined
			&& character.Humanoid.Health / character.Humanoid.MaxHealth <= STRESS_LIFE
		) {
			return fireRate * (1 + this.Value(0))
		} else {
			return fireRate
		}
	}
}
