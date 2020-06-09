import { CollectionService, ServerScriptService } from "@rbxts/services"
import { WeaponPerk } from "./Perk"
import * as PerkUtil from "./PerkUtil"
import PerkIcon from "./PerkIcon"

const BERSERK_LIFE_LEFT = 0.25
const CQC_RANGE = 25
const FINISHER_LIFE_LEFT = 0.25

export class Berserk extends WeaponPerk {
	static Name = "Berserk!!!"
	static Icon = PerkIcon.Fist
	static PowerBuff = 1.15

	static Values = [{
		Range: [0.3, 0.4],
	}]

	ModifyDamage(damage: number): number {
		const character = this.player.Character as Character | undefined
		if (character !== undefined
			&& character.Humanoid.Health <= character.Humanoid.MaxHealth * BERSERK_LIFE_LEFT
		) {
			return damage * (1 + this.Value(0))
		}

		return damage
	}
}

export class BossSlayer extends WeaponPerk {
	static Name = "Boss Slayer"
	static Icon = PerkIcon.Skull
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.1, 0.15],
	}]

	ModifyDamage(damage: number, zombieHumanoid: Humanoid): number {
		if (CollectionService.HasTag(zombieHumanoid.Parent!, "Boss")) {
			return damage * (1 + this.Value(0))
		}

		return damage
	}
}

// close quarters cooking
export class CQC extends WeaponPerk {
	static Name = "CQC"
	static Icon = PerkIcon.Fist
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.12, 0.18],
	}]

	ModifyDamage(damage: number, zombieHumanoid: Humanoid): number {
		const character = this.player.Character
		if (character !== undefined && character.PrimaryPart !== undefined) {
			const zombie = zombieHumanoid.Parent as Model & {
				PrimaryPart: defined,
			}

			if (character.PrimaryPart.Position
				.sub(zombie.PrimaryPart.Position).Magnitude
				<= CQC_RANGE
			) {
				return damage * (1 + this.Value(0))
			}
		}

		return damage
	}
}

export class Finisher extends WeaponPerk {
	static Name = "Finisher"
	static Icon = PerkIcon.Skull
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.25, 0.3],
	}]

	ModifyDamage(damage: number, zombieHumanoid: Humanoid): number {
		if (zombieHumanoid.Health <= zombieHumanoid.MaxHealth * FINISHER_LIFE_LEFT) {
			return damage * (1 + this.Value(0))
		}

		return damage
	}
}

export class SuperSlayer extends WeaponPerk {
	static Name = "Super Slayer"
	static Icon = PerkIcon.Skull
	static PowerBuff = 1.11

	static Values = [{
		Range: [0.1, 0.15],
	}]

	ModifyDamage(damage: number, zombieHumanoid: Humanoid): number {
		const zombie = PerkUtil.GetZombieFromHumanoid(zombieHumanoid)
		if (zombie !== undefined) {
			const dungeonState = require(ServerScriptService.DungeonState) as {
				CurrentGamemode: {
					SpecialZombies?: string[],
				}
			}

			const specialZombies: string[] = dungeonState.CurrentGamemode.SpecialZombies || []

			if (specialZombies.includes(zombie.Model)) {
				return damage * (1 + this.Value(0))
			}
		}

		return damage
	}
}
