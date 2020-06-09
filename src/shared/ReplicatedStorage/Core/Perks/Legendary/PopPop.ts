import { Scope, WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"

const FIRE_RATE_BUFF = [0.05, 0.08]

class PopPop extends WeaponPerk {
	static Name = "Pop Pop!"
	static Icon = PerkIcon.Bullet
	static LegendaryPerk = true
	static Scope = Scope.Client
	static PowerBuff = 1.2

	static Values = [{
		Range: FIRE_RATE_BUFF,
		UpgradePercent: [1, 1.1, 1.15, 1.2],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Shotgun"
	}

	ModifyFireRate(fireRate: number): number {
		const ammoInfo = this.AmmoInfo()
		return fireRate * (1 + this.Value(0)) ** (ammoInfo.Magazine - ammoInfo.AmmoLeft)
	}
}

export = PopPop
