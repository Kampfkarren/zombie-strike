import { BadgeService, Players, SoundService, Workspace } from "@rbxts/services"
import FastSpawn from "shared/ReplicatedStorage/Core/FastSpawn"
import PlayQuickSound from "shared/ReplicatedStorage/Core/PlayQuickSound"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { BossAttack, RotatingBoss } from "./RotatingBoss"
import { BossClass, ZombieClass } from "./ZombieClass"

const BADGE = 2124520855

const BOSS_DEATH_DELAY = 2
const BUNNY_ZOMBIES_SUMMONED = 3

const DAMAGE_EGG_BOMB_PHASE1 = 16
const DAMAGE_EGG_BOMB_PHASE2 = 22
const DAMAGE_EGG_CRAZY_FRENZY = 10
const DAMAGE_EGG_EXPLOSION = 50

const DAMAGE_GRAVITY_SLAM = 8

const EGG_CRAZY_FRENZY_DURATION = 3

const EGG_EXPLOSION_SPOTS = 5

const GRAVITY_SLAM_SPOTS = 10
const GRAVITY_SLAM_DELAY = (1.3 * GRAVITY_SLAM_SPOTS) + 1.2

const EGG_BOMB_DURATION = 3

type EggRoom = Model & {
	PrimaryPart: BasePart,
}

const rng = new Random()

class BossEgg extends RotatingBoss<EggRoom> {
	static Model: string = "Boss"
	static Name: string = "Egg Mech Zombie"

	eggBomb: RemoteEvent | undefined
	eggCrazyFrenzy: RemoteEvent | undefined
	eggExplosion: RemoteEvent | undefined
	gravitySlam: RemoteEvent | undefined
	goonsLeft: number = 0

	phases: BossAttack<this>[][] = [
		[this.EggBomb, this.GravitySlam, this.SummonZombies],
		[this.EggBomb, this.GravitySlam, this.SummonZombies, this.EggExplosion, this.EggCrazyFrenzy],
	]

	AfterSpawn(this: this & ZombieClass) {
		super.AfterSpawn()

		const damageReceivedScale = this.instance.Humanoid.WaitForChild("DamageReceivedScale") as NumberValue
		damageReceivedScale.Value *= 1.4

		this.eggBomb = this.NewDamageSource("EggBomb", [
			DAMAGE_EGG_BOMB_PHASE1,
			DAMAGE_EGG_BOMB_PHASE2,
		])

		this.eggCrazyFrenzy = this.NewDamageSource("EggCrazyFrenzy", DAMAGE_EGG_CRAZY_FRENZY)
		this.eggExplosion = this.NewDamageSource("EggExplosion", DAMAGE_EGG_EXPLOSION)
		this.gravitySlam = this.NewDamageSource("GravitySlam", DAMAGE_GRAVITY_SLAM)
	}

	AfterDeath(this: this & ZombieClass) {
		for (const player of Players.GetPlayers()) {
			FastSpawn(() => {
				BadgeService.AwardBadge(player.UserId, BADGE)
			})
		}

		for (const part of this.instance.GetDescendants()) {
			if (part.IsA("BasePart") && part.Transparency !== 1) {
				part.Anchored = false
				part.CanCollide = true
			}
		}

		PlayQuickSound(this.GetAsset("Death") as Sound)

		wait(BOSS_DEATH_DELAY)
	}

	ChoosePoints(amount: number): Attachment[] {
		const points: Attachment[] = []

		for (const child of this.bossRoom!.PrimaryPart.GetChildren()) {
			if (child.Name === "GravitySlamPoint") {
				points.push(child as Attachment)
			}
		}

		const chosenPoints: Attachment[] = []
		for (let _ = 0; _ < amount; _++) {
			chosenPoints.push(points.unorderedRemove(rng.NextInteger(0, points.size() - 1))!)
		}

		return chosenPoints
	}

	EggBomb(): Promise<void> {
		this.eggBomb!.FireAllClients()
		return new Promise((resolve) => {
			RealDelay(EGG_BOMB_DURATION, resolve)
		})
	}

	EggCrazyFrenzy(): Promise<void> {
		this.eggCrazyFrenzy!.FireAllClients()
		return new Promise((resolve) => {
			RealDelay(EGG_CRAZY_FRENZY_DURATION, resolve)
		})
	}

	EggExplosion() {
		this.eggExplosion!.FireAllClients(this.ChoosePoints(EGG_EXPLOSION_SPOTS))
	}

	GetModel() {
		return assert(Workspace.Rooms.StartSection.FindFirstChild("Egg Mech Zombie", true))
	}

	GravitySlam(): Promise<void> {
		this.gravitySlam!.FireAllClients(this.ChoosePoints(GRAVITY_SLAM_SPOTS))

		return new Promise((resolve) => {
			RealDelay(GRAVITY_SLAM_DELAY, resolve)
		})
	}

	Spawn(this: this & ZombieClass): Model {
		this.SetupHumanoid();
		this.AfterSpawn()
		return this.instance
	}

	SummonZombies(this: this & BossClass<EggRoom>): void | Promise<void> {
		if (this.goonsLeft > 0) {
			const currentPhase = this.phases[this.currentPhase].copy()
			return currentPhase[math.random(0, currentPhase.size() - 1)](this)
		}

		PlayQuickSound(SoundService.ZombieSounds.Samurai.Boss.ZombieSummon)

		this.goonsLeft = BUNNY_ZOMBIES_SUMMONED

		for (let _ = 0; _ < BUNNY_ZOMBIES_SUMMONED; _++) {
			this.SummonGoon((zombie) => {
				zombie.Died.Connect(() => {
					this.goonsLeft -= 1
				})
			}, "Common")
		}
	}

	UpdateNametag() { }
}

export = BossEgg
