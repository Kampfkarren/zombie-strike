import { Scope, WeaponPerk } from "../Perk"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import PerkIcon from "../PerkIcon"

const BUFF_RANGE = [0.08, 0.09]

class ShowOfSkill extends WeaponPerk {
	static Name = "Show of Skill"
	static Icon = PerkIcon.Twinkle
	static Scope = Scope.Both
	static LegendaryPerk = true
	static PowerBuff = 1.2

	static Values = [{
		Range: BUFF_RANGE,
		UpgradePercent: [1, 1.04, 1.08, 1.12],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type === "Pistol"
	}

	stacks: number = 0

	Critted() {
		this.stacks += 1
	}

	ModifyDamage(damage: number): number {
		return damage * ((1 + this.Value(0)) ** this.stacks)
	}

	ModifyReloadTime(reloadTime: number): number {
		return reloadTime * ((1 - this.Value(0)) ** this.stacks)
	}

	Reloaded() {
		this.stacks = 0
	}
}

export = ShowOfSkill
