import { WeaponPerk } from "./Perk"
import PerkIcon from "./PerkIcon"

export class Vampire extends WeaponPerk {
	static Name = "Vampire"
	static Icon = PerkIcon.Plus
	static PowerBuff = 1.18

	static Values = [{
		Range: [0.04, 0.08],
	}]

	DamageDealt(damage: number) {
		const heal = this.Value(0)

		const character = this.player.Character as Character | undefined
		if (character !== undefined) {
			character.Humanoid.Health += damage * heal
		}
	}
}
