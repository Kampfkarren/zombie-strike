import { RunService } from "@rbxts/services"
import { Scope, WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

class Medic extends WeaponPerk {
	static Name = "Medic"
	static Icon = PerkIcon.Heart
	static Scope = Scope.Both
	static LegendaryPerk = true
	static PowerBuff = 1.15

	static Values = [{
		Range: [0.02, 0.03],
	}]

	TeammateShot(teammate: Humanoid) {
		if (RunService.IsServer()) {
			const heal = this.gun.Damage * this.Value(0)
			teammate.Health += heal

			const character = this.player.Character as Character
			character.Humanoid.Health += heal
		}
	}
}

export = Medic

