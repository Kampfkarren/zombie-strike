import { Players, PhysicsService, ReplicatedStorage, SoundService, Workspace, CollectionService } from "@rbxts/services"
import CircleEffect from "shared/ReplicatedStorage/Core/CircleEffect"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"
import { GetFarthestPlayer } from "mission/ReplicatedStorage/Libraries/CharacterSelector"
import { BossAttack, RotatingBoss } from "./RotatingBoss"
import { BossClass, ZombieClass } from "./ZombieClass"
import Raycast from "shared/ReplicatedStorage/Core/Raycast"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

const ATTACK_DAMAGE = 90
const ATTACK_RANGE = 25

const BOSS_DEATH_DELAY = 4.5

const DAMAGE_REDUCTION = 0.2

const DAMAGE_PSYCHO_ATTACK = 40
const DAMAGE_SLAM_DOWN_AOE_PHASE1 = 40
const DAMAGE_SLAM_DOWN_AOE_PHASE2 = 100
const DAMAGE_SLAM_DOWN_RING = 25
const DAMAGE_SLUDGE_BALL = 40

const MULTI_SLAM_COUNT = 3
const MULTI_SLAM_DELAY = 1.2

const PSYCHO_DELAY = 2.3
const SLUDGE_BALL_DELAY = 6

const ZOMBIES_DELAY = 10
const ZOMBIES_SUMMONED = 5

const CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

type Ability = {
	attack: BossAttack<BossRadioactive>,
	cooldown: number,
}

function SlamAttack(this: BossRadioactive & ZombieClass, timesLeft: unknown): void | Promise<void> {
	if (!this.alive) {
		return
	}

	if (timesLeft === undefined) {
		timesLeft = this.currentPhase === 0 ? 0 : MULTI_SLAM_COUNT
	}

	const closest = GetFarthestPlayer(this.instance.PrimaryPart!.Position)
	if (closest !== undefined) {
		const boss = this.instance
		boss.PrimaryPart!.Anchored = true

		const [_, position] = Raycast(
			closest.Character!.PrimaryPart!.Position,
			new Vector3(0, -1000, 0),
			Players.GetPlayers().mapFiltered((player) => player.Character),
		)

		this.slamDownAoE!.FireAllClients(position)

		return new Promise((resolve) => {
			RealDelay(0.6, () => {
				if (!this.alive) {
					return
				}

				boss.MoveTo(position)
				// boss.SetPrimaryPartCFrame(new CFrame(position)
				// .mul(boss.PrimaryPart!.CFrame.sub(boss.PrimaryPart!.Position))
				// .add(new Vector3(0, boss.GetExtentsSize().Y, 0)))

				if (timesLeft === 0) {
					boss.PrimaryPart!.Anchored = false
					this.Aggro()
				}

				resolve()
			})
		}).then(() => {
			if (timesLeft as number > 0) {
				return new Promise((resolve) => {
					RealDelay(MULTI_SLAM_DELAY, () => {
						// this is so dumb lol
						const result = (SlamAttack as unknown as (
							self: BossRadioactive & ZombieClass,
							timesLeft: number
						) => void | Promise<void>)(this, (timesLeft as number) - 1)

						if (Promise.is(result)) {
							result.then(resolve)
						} else {
							resolve()
						}
					})
				})
			}
		})
	}
}

function SludgeBallAttack(this: BossRadioactive & ZombieClass): Promise<void> {
	const boss = this.instance
	boss.PrimaryPart!.Anchored = true

	this.sludgeBall!.FireAllClients()
	return new Promise((resolve) => {
		RealDelay(SLUDGE_BALL_DELAY, () => {
			if (!this.alive) {
				return
			}

			boss.PrimaryPart!.Anchored = false
			this.Aggro()
			resolve()
		})
	})
}

function PsychoAttack(this: BossRadioactive & ZombieClass): Promise<void> {
	const boss = this.instance
	boss.PrimaryPart!.Anchored = true

	const characters = Players
		.GetPlayers()
		.mapFiltered(player => player.Character)
		.filter(character => (character as Character).Humanoid.Health > 0)

	if (characters.size() === 0) {
		return Promise.resolve()
	}

	this.psychoAttack!.FireAllClients(characters[math.random(0, characters.size() - 1)])
	return new Promise((resolve) => {
		RealDelay(PSYCHO_DELAY, () => {
			if (!this.alive) {
				return
			}

			boss.PrimaryPart!.Anchored = false
			this.Aggro()
			resolve()
		})
	})
}

class BossRadioactive extends RotatingBoss<RadioactiveRoom> {
	static Model: string = "Boss"
	static Name: string = "Radioactive Giga Zombie"
	static AttackRange: number = 15

	abilities: Ability[] = [{
		attack: SlamAttack,
		cooldown: 7,
	}, {
		attack: SludgeBallAttack,
		cooldown: 7,
	}, {
		attack: PsychoAttack,
		cooldown: 7,
	}]

	abilityUseTimes: Map<keyof this["abilities"] & number, number> = new Map()
	normalAi: boolean = true

	psychoAttack: RemoteEvent | undefined
	slamDownAoE: RemoteEvent | undefined
	slamDownRing: RemoteEvent | undefined
	sludgeBall: RemoteEvent | undefined

	stompAnimation: AnimationTrack | undefined

	phases: BossAttack<this>[][] = [
		[this.BossAttack],
		[this.BossAttack],
	]

	constructor() {
		super()

		for (let abilityIndex = 0; abilityIndex < this.abilities.size(); abilityIndex++) {
			this.abilityUseTimes.set(abilityIndex, 0)
		}
	}

	Aggro(this: this & ZombieClass) {
		if (this.bossRoom === undefined) {
			return
		}

		Zombie.Aggro(this)
	}

	Wander(this: this & ZombieClass) {
		if (this.bossRoom === undefined) {
			return
		}

		Zombie.Wander(this)
	}

	AfterDeath(this: this & ZombieClass) {
		const decoy = this.instance.Clone()
		decoy.PrimaryPart!.Anchored = true
		CollectionService.RemoveTag(decoy, "Boss")
		CollectionService.RemoveTag(decoy, "Zombie")
		decoy.Parent = Workspace

		for (const thing of this.instance.GetDescendants()) {
			if (thing.IsA("BasePart")) {
				thing.Transparency = 1
			} else if (thing.IsA("Decal") || thing.IsA("BillboardGui")) {
				thing.Destroy()
			}
		}

		const animation = decoy.Humanoid.LoadAnimation(
			this.GetAsset("DeathAnimation") as Animation
		)
		animation.AdjustSpeed(animation.Length / (BOSS_DEATH_DELAY + 1))
		animation.Play()

		wait(BOSS_DEATH_DELAY)

		decoy.Destroy()

		this.Destroy()
	}

	AfterSpawn(this: this & ZombieClass) {
		super.AfterSpawn()

		this.psychoAttack = this.NewDamageSource("PsychoAttack", DAMAGE_PSYCHO_ATTACK)
		this.slamDownAoE = this.NewDamageSource("SlamDownAoE", [
			DAMAGE_SLAM_DOWN_AOE_PHASE1,
			DAMAGE_SLAM_DOWN_AOE_PHASE2,
		])
		this.slamDownRing = this.NewDamageSource("SlamDownRing", DAMAGE_SLAM_DOWN_RING)
		this.sludgeBall = this.NewDamageSource("SludgeBall", DAMAGE_SLUDGE_BALL)

		this.stompAnimation = this.instance.Humanoid.LoadAnimation(
			this.GetAsset("AttackAnimation") as Animation,
		)

		this.stompAnimation.KeyframeReached.Connect(() => {
			this.AttackEffect()
		})

		PhysicsService.CollisionGroupSetCollidable("Players", "Zombies", false)
	}

	Attack() {
		this.stompAnimation!.Play()
		return true
	}

	AttackEffect(this: this & ZombieClass) {
		const origin = this.instance.PrimaryPart!.CFrame
			.sub(new Vector3(0, 5.25, 0))

		const beamSounds = SoundService.ZombieSounds.Radioactive.Boss.BeamDamage.GetChildren()
		const beamSound = beamSounds[math.random(0, beamSounds.size() - 1)].Clone() as Sound
		beamSound.PlayOnRemove = true
		beamSound.Parent = this.instance.PrimaryPart!
		beamSound.Destroy()

		for (const player of Players.GetPlayers()) {
			const character = player.Character!
			if (character.PrimaryPart!.Position.sub(this.instance.PrimaryPart!.Position).Magnitude
				<= ATTACK_RANGE / 2
			) {
				TakeDamage(player, Zombie.GetDamageAgainstConstant(
					undefined,
					player,
					0,
					ATTACK_DAMAGE,
				))
			}
		}

		CircleEffectRemote.FireAllClients(
			origin,
			CircleEffect.Presets.BOSS_RADIOACTIVE,
		)
	}

	BossAttack(): void | Promise<void> {
		const abilities: [number, Ability][] = []

		for (const [abilityIndex, useTime] of this.abilityUseTimes.entries()) {
			const ability = this.abilities[abilityIndex]
			if (tick() - useTime > ability.cooldown) {
				abilities.push([abilityIndex, ability])
			}
		}

		if (abilities.size() > 0) {
			const [abilityIndex, ability] = abilities[math.random(0, abilities.size() - 1)]
			this.abilityUseTimes.set(abilityIndex, tick())
			return ability.attack(this)
		}
	}

	NewPhase(this: this & BossClass<RadioactiveRoom>, phase: number) {
		if (phase === 1) {
			this.instance.Humanoid.DamageReceivedScale.Value *= (1 - DAMAGE_REDUCTION)

			this.SummonZombiesLater()
		}
	}

	SummonZombiesLater(this: this & BossClass<RadioactiveRoom>) {
		RealDelay(ZOMBIES_DELAY, () => {
			if (this.alive) {
				let goonsLeft = ZOMBIES_SUMMONED

				const zombieSummon = SoundService.ZombieSounds.Samurai.Boss.ZombieSummon.Clone()
				zombieSummon.Parent = Workspace
				zombieSummon.PlayOnRemove = true
				zombieSummon.Destroy()

				for (let _ = 0; _ < ZOMBIES_SUMMONED; _++) {
					this.SummonGoon((zombie) => {
						zombie.Died.Connect(() => {
							goonsLeft -= 1
							if (goonsLeft === 0) {
								this.SummonZombiesLater()
							}
						})
					}, "Common")
				}
			}
		})
	}
}

export = BossRadioactive
