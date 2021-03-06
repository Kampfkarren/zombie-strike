import { Players, SoundService, Workspace } from "@rbxts/services"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { BossAttack, RotatingBoss } from "./RotatingBoss"
import { BossClass, ZombieClass } from "./ZombieClass"

const BOSS_DEATH_DELAY = 4

const DAMAGE_SHURIKEN_FRENZY = 30
const DAMAGE_SWORD_BEAM_ATTACK = 30
const DAMAGE_SWORD_SPIN_PHASE1 = 40
const DAMAGE_SWORD_SPIN_PHASE2 = 80
const DAMAGE_YOOO = 25

const NINJA_ZOMBIE_SUMMONED = 6

const SHURIKEN_FRENZY_DURATION = 5
const SHURIKEN_FRENZY_ROF = 2

const SWORD_SPIN_DELAY = 2.5
const SWORD_SPIN_SPOTS = 3

const SWORD_BEAM_DURATION = 5
const SWORD_BEAM_ROF = 1 / 2

type SamuraiRootPart = BasePart & {
	SpinEnd: Sound,
	SpinLoop: Sound,
	SpinStart: Sound,
}

class BossSamurai extends RotatingBoss<SamuraiRoom> {
	static Model: string = "Boss"
	static Name: string = "Samurai Master Zombie"

	shurikenFrenzy: RemoteEvent | undefined
	swordBeamAttack: RemoteEvent | undefined
	swordSpin: RemoteEvent | undefined
	yooo: RemoteEvent | undefined

	phases: BossAttack<this>[][] = [
		[this.SwordBeamAttack, this.SwordSpin, this.SummonZombies],
		[this.Yooo, this.ShurikenFrenzy, this.SummonZombies, this.SwordSpin],
	]
	randomAttacks: boolean = false

	AfterDeath(this: this & ZombieClass) {
		this.instance.Humanoid.LoadAnimation(
			this.GetAsset("DeathAnimation") as Animation
		).Play()

		wait(BOSS_DEATH_DELAY)

		this.Destroy()
	}

	AfterSpawn(this: this & ZombieClass) {
		super.AfterSpawn()

		this.shurikenFrenzy = this.NewDamageSource("ShurikenFrenzy", DAMAGE_SHURIKEN_FRENZY)
		this.swordBeamAttack = this.NewDamageSource("SwordBeamAttack", DAMAGE_SWORD_BEAM_ATTACK)
		this.swordSpin = this.NewDamageSource("SwordSpin", [
			DAMAGE_SWORD_SPIN_PHASE1,
			DAMAGE_SWORD_SPIN_PHASE2,
		])
		this.yooo = this.NewDamageSource("Yooo", DAMAGE_YOOO)

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

	ShurikenFrenzy(this: this & ZombieClass): Promise<void> {
		const animation = this.instance.Humanoid.LoadAnimation(this.GetAsset("ShurikenAnimation") as Animation)
		animation.Play()

		return new Promise((resolve) => {
			const started = tick()
			Interval(SHURIKEN_FRENZY_ROF, () => {
				if (tick() - started >= SHURIKEN_FRENZY_DURATION) {
					animation.Stop()
					resolve()
					return false
				}

				this.shurikenFrenzy!.FireAllClients()
			})
		})
	}

	SummonZombies(this: this & BossClass<SamuraiRoom>) {
		const sound = SoundService.ZombieSounds.Samurai.Boss.ZombieSummon.Clone()
		sound.PlayOnRemove = true
		sound.Parent = Workspace
		sound.Destroy()

		for (let _ = 0; _ < NINJA_ZOMBIE_SUMMONED; _++) {
			this.SummonGoon(undefined, this.currentPhase === 0 ? "Projectile" : "Common")
		}
	}

	SwordBeamAttack(this: this & ZombieClass): Promise<void> {
		const animation = this.instance.Humanoid.LoadAnimation(this.GetAsset("ShurikenAnimation") as Animation)
		animation.Play()

		return new Promise((resolve) => {
			const started = tick()
			Interval(SWORD_BEAM_ROF, () => {
				if (tick() - started >= SWORD_BEAM_DURATION) {
					animation.Stop()
					resolve()
					return false
				}

				const target = this.FindAliveTarget()
				if (target !== undefined) {
					this.swordBeamAttack!.FireAllClients(new Vector2int16(
						target.PrimaryPart!.Position.X,
						target.PrimaryPart!.Position.Z,
					))
				}
			})
		})
	}

	SwordSpin(this: this & RotatingBoss<SamuraiRoom> & ZombieClass): Promise<void> {
		const animation = this.instance.Humanoid.LoadAnimation(this.GetAsset("SpinAnimation") as Animation)
		animation.Play()

		const primaryPart = this.instance.PrimaryPart as SamuraiRootPart
		primaryPart.SpinStart.Play()
		primaryPart.SpinLoop.Play()

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

			this.swordSpin!.FireAllClients(chosenPoints)

			RealDelay(SWORD_SPIN_DELAY * SWORD_SPIN_SPOTS, resolve)
		}).then(() => {
			primaryPart.SpinLoop.Stop()
			primaryPart.SpinEnd.Play()
			animation.Stop()
		})
	}

	Yooo() {
		this.yooo!.FireAllClients()
	}
}

export = BossSamurai
