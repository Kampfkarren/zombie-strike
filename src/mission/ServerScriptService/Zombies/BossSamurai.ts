import { Players } from "@rbxts/services"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import { ZombieClass } from "./ZombieClass"
import { RotatingBoss } from "./RotatingBoss"

const DAMAGE_SWORD_BEAM_ATTACK = 30

const SWORD_BEAM_DURATION = 5
const SWORD_BEAM_ROF = 1 / 2

class BossSamurai extends RotatingBoss {
	static Model: string = "Boss"
	static Name: string = "Samurai Master Zombie"

	swordBeamAttack: RemoteEvent
	phases = [[this.SwordBeamAttack]]

	constructor() {
		super()

		this.swordBeamAttack = this.NewDamageSource("SwordBeamAttack", DAMAGE_SWORD_BEAM_ATTACK)
	}

	FindAliveTarget(): Character | undefined {
		const possibleTargets = []

		for (const player of Players.GetPlayers()) {
			const character = player.Character as Character | undefined
			if (character && character.Humanoid.Health > 0) {
				possibleTargets.push(character)
			}
		}

		if (possibleTargets.size() === 0) {
			return undefined
		} else {
			return possibleTargets[math.random(0, possibleTargets.size() - 1)]
		}
	}

	SwordBeamAttack(): Promise<void> {
		return new Promise((resolve) => {
			const started = tick()
			Interval(SWORD_BEAM_ROF, () => {
				if (tick() - started >= SWORD_BEAM_DURATION) {
					resolve()
					return false
				}

				const target = this.FindAliveTarget()
				if (target !== undefined) {
					this.swordBeamAttack.FireAllClients(new Vector2int16(
						target.PrimaryPart!.Position.X,
						target.PrimaryPart!.Position.Z,
					))
				}
			})
		})
	}
}

export = BossSamurai
