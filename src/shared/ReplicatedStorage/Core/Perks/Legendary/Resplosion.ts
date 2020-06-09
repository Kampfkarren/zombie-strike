import { CollectionService, Players, ReplicatedStorage, RunService } from "@rbxts/services"
import { Scope, WeaponPerk } from "../Perk"
import { GunItem } from "shared/ReplicatedStorage/Core/Loot"
import Damage from "shared/ReplicatedStorage/RuddevModules/Damage"
import * as Effect from "shared/ReplicatedStorage/RuddevModules/Effects/init"
import PerkIcon from "../PerkIcon"

const RemoteEffect = ReplicatedStorage.RuddevRemotes.Effect

const DAMAGE_RANGE = [0.24, 0.28]
const RADIUS = 15

class Resplosion extends WeaponPerk {
	static Name = "Resplosion"
	static Icon = PerkIcon.Badge
	static Scope = Scope.Both
	static LegendaryPerk = true
	static PowerBuff = 1.22

	static Values = [{
		Range: DAMAGE_RANGE,
		UpgradePercent: [1, 1.04, 1.08, 1.12],
	}]

	static ShouldApply(this: void, gun: Readonly<GunItem>): boolean {
		return gun.Type !== "Crystal"
	}

	Reloaded() {
		const character = this.player.Character
		if (character === undefined) {
			return
		}

		const primaryPart = character.PrimaryPart
		if (primaryPart === undefined) {
			return
		}

		if (RunService.IsServer()) {
			const damage = (this.AmmoInfo().Magazine - this.AmmoInfo().AmmoLeft)
				* (this.gun.Damage * this.gun.ShotSize)
				* this.Value(0)

			for (const player of Players.GetPlayers()) {
				if (player !== this.player) {
					RemoteEffect.FireClient(player, Effect.EffectIDs.MinorExplosion, primaryPart.Position, RADIUS)
				}
			}

			for (const zombie of CollectionService.GetTagged("Zombie")) {
				const zombieModel = (zombie as Model & { Humanoid: Humanoid })
				const zombiePrimaryPart = zombieModel.PrimaryPart
				if (zombiePrimaryPart !== undefined
					&& zombiePrimaryPart.Position.sub(primaryPart.Position).Magnitude <= RADIUS
				) {
					Damage.Damage(zombieModel.Humanoid, damage, this.player, false)
				}
			}
		} else {
			Effect.Effect("MinorExplosion", primaryPart.Position, RADIUS)
		}
	}
}

export = Resplosion
