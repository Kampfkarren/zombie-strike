import { Players } from "@rbxts/services"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { RotatingBoss } from "./RotatingBoss"
import { BossClass, ZombieClass } from "./ZombieClass"

const DAMAGE_SWORD_BEAM_ATTACK = 30
const DAMAGE_SWORD_SPIN = 40
const DAMAGE_YOOO = 25

const NINJA_ZOMBIE_SUMMONED = 6

const SWORD_SPIN_DELAY = 2.5
const SWORD_SPIN_SPOTS = 3

const SWORD_BEAM_DURATION = 5
const SWORD_BEAM_ROF = 1 / 2

class BossSamurai extends RotatingBoss<SamuraiRoom> {
	static Model: string = "Boss"
	static Name: string = "Samurai Master Zombie"

	swordBeamAttack: RemoteEvent
	swordSpin: RemoteEvent
	yooo: RemoteEvent

	phases = [
		// [this.SwordBeamAttack, this.SwordSpin, this.SummonZombies],
		[this.Yooo],
	]

	constructor() {
		super()

		this.swordBeamAttack = this.NewDamageSource("SwordBeamAttack", DAMAGE_SWORD_BEAM_ATTACK)
		this.swordSpin = this.NewDamageSource("SwordSpin", DAMAGE_SWORD_SPIN)
		this.yooo = this.NewDamageSource("Yooo", DAMAGE_YOOO)
	}

	AfterSpawn(this: ZombieClass) {
		this.instance.SetPrimaryPartCFrame(this.instance.PrimaryPart!.CFrame.mul(
			CFrame.Angles(0, -math.pi / 2, 0),
		))
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

	SummonZombies(this: BossClass<SamuraiRoom>) {
		for (let _ = 0; _ < NINJA_ZOMBIE_SUMMONED; _++) {
			this.SummonGoon(undefined, "Projectile")
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

	SwordSpin(this: this & RotatingBoss<SamuraiRoom> & ZombieClass): Promise<void> {
		return new Promise((resolve) => {
			const swordSpinPoints: Attachment[] = []

			for (const child of this.bossRoom!.Arena.PrimaryPart.GetChildren()) {
				if (child.Name === "SwordSpinPoint") {
					swordSpinPoints.push(child as Attachment)
				}
			}

			const chosenPoints: Attachment[] = []
			for (let _ = 0; _ < SWORD_SPIN_SPOTS; _++) {
				chosenPoints.push(swordSpinPoints.unorderedRemove(math.random(0, swordSpinPoints.size() - 1))!)
			}

			this.swordSpin.FireAllClients(chosenPoints)

			RealDelay(SWORD_SPIN_DELAY * SWORD_SPIN_SPOTS, resolve)
		})
	}

	Yooo() {
		this.yooo.FireAllClients()
	}
}

export = BossSamurai
