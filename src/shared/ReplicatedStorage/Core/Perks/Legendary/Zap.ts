import { CollectionService, ReplicatedStorage } from "@rbxts/services"
import Damage from "shared/ReplicatedStorage/RuddevModules/Damage"
import { WeaponPerk } from "../Perk"
import PerkIcon from "../PerkIcon"

const CHANCE = 0.33
const NEARBY_RANGE = 15
const ZOMBIES_TO_ZAP = 2

class Zap extends WeaponPerk {
	static Name = "Zap!"
	static Icon = PerkIcon.Bolt
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = [{
		Range: [0.2, 0.25],
	}]

	overkillDamage?: number

	DamageDealt(damage: number, zombie: Humanoid) {
		if (math.random() <= CHANCE) {
			const zombiesZapped: BasePart[] = []

			for (let otherZombieInstance of CollectionService.GetTagged("Zombie")) {
				const otherZombie = otherZombieInstance as Model & {
					Humanoid: Humanoid
				}

				if (
					otherZombie !== zombie.Parent
					&& otherZombie.PrimaryPart !== undefined
					&& otherZombie.PrimaryPart.Position.sub(
						(zombie.Parent as Model).PrimaryPart!.Position
					).Magnitude <= NEARBY_RANGE
					&& otherZombie.Humanoid.Health > 0
				) {
					Damage.Damage(
						otherZombie.Humanoid,
						damage * (1 + this.Value(0)),
						this.player,
						false,
					)

					zombiesZapped.push(otherZombie.PrimaryPart)

					if (zombiesZapped.size() === ZOMBIES_TO_ZAP) {
						break
					}
				}
			}

			ReplicatedStorage.Remotes.Perks.Zap.FireAllClients(
				(zombie.Parent as Model).PrimaryPart,
				...zombiesZapped,
			)
		}
	}
}

export = Zap
