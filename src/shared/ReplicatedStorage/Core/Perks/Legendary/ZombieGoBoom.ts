import { CollectionService, ReplicatedStorage } from "@rbxts/services"
import { WeaponPerk } from "../Perk"
import Damage from "shared/ReplicatedStorage/RuddevModules/Damage"
import * as Effect from "shared/ReplicatedStorage/RuddevModules/Effects/init"
import PerkIcon from "../PerkIcon"

const RemoteEffect = ReplicatedStorage.RuddevRemotes.Effect

const DAMAGE_RANGE = [0.06, 0.1]
const RADIUS = 15

class ZombieGoBoom extends WeaponPerk {
	static Name = "Zombie-go-Boom"
	static Icon = PerkIcon.Badge
	static LegendaryPerk = true
	static PowerBuff = 1.2

	static Values = [{
		Range: DAMAGE_RANGE,
	}]

	ZombieKilled(zombieHumanoid: Humanoid) {
		const zombie = zombieHumanoid.Parent as Character
		if (zombie.PrimaryPart === undefined) {
			return
		}

		RemoteEffect.FireAllClients(
			Effect.EffectIDs.MinorExplosion,
			zombie.PrimaryPart.Position,
			RADIUS,
		)

		for (const otherZombie of CollectionService.GetTagged("Zombie")) {
			if (otherZombie === zombie) {
				continue
			}

			const zombieModel = zombie as Character
			const zombiePrimaryPart = zombieModel.PrimaryPart
			if (zombiePrimaryPart !== undefined
				&& zombiePrimaryPart.Position.sub(zombie.PrimaryPart.Position).Magnitude <= RADIUS
			) {
				Damage.Damage(
					zombieModel.Humanoid,
					zombie.Humanoid.MaxHealth * this.Value(0),
					this.player,
					false,
				)
			}
		}
	}
}

export = ZombieGoBoom

