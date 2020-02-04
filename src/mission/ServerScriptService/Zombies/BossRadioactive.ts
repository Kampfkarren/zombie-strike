import { Players, ReplicatedStorage, SoundService, Workspace } from "@rbxts/services"
import Interval from "shared/ReplicatedStorage/Core/Interval"
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

const DAMAGE_SLAM_DOWN_AOE_PHASE1 = 40
const DAMAGE_SLAM_DOWN_AOE_PHASE2 = 100
const DAMAGE_SLAM_DOWN_RING = 25
const DAMAGE_SLUDGE_BALL = 40

const SLUDGE_BALL_DELAY = 6

const CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

type Ability = {
	attack: BossAttack<BossRadioactive>,
	cooldown: number,
}

function SlamAttack(this: BossRadioactive & ZombieClass): void | Promise<void> {
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
				boss.SetPrimaryPartCFrame(new CFrame(position)
					.mul(boss.PrimaryPart!.CFrame.sub(boss.PrimaryPart!.Position))
					.add(new Vector3(0, boss.GetExtentsSize().Y, 0)))
				boss.PrimaryPart!.Anchored = false
				this.Aggro()
				resolve()
			})
		})
	}
}

function SludgeBallAttack(this: BossRadioactive & ZombieClass): Promise<void> {
	const boss = this.instance
	boss.PrimaryPart!.Anchored = true

	this.sludgeBall!.FireAllClients()
	return new Promise((resolve) => {
		RealDelay(SLUDGE_BALL_DELAY, () => {
			boss.PrimaryPart!.Anchored = false
			resolve()
		})
	})
}

class BossRadioactive extends RotatingBoss<RadioactiveRoom> {
	static Model: string = "Boss"
	static Name: string = "Radioactive Giga Zombie"
	static AttackRange: number = 15

	abilities: Ability[] = [/*{
		attack: SlamAttack,
		cooldown: 7,
	},*/ {
			attack: SludgeBallAttack,
			cooldown: 7,
		}]

	abilityUseTimes: Map<keyof this["abilities"] & number, number> = new Map()
	normalAi: boolean = true

	slamDownAoE: RemoteEvent | undefined
	slamDownRing: RemoteEvent | undefined
	sludgeBall: RemoteEvent | undefined

	stompAnimation: AnimationTrack | undefined

	phases: BossAttack<this>[][] = [
		[this.BossAttack],
	]

	constructor() {
		super()

		for (let abilityIndex = 0; abilityIndex < this.abilities.size(); abilityIndex++) {
			this.abilityUseTimes.set(abilityIndex, 0)
		}
	}

	AfterSpawn(this: this & ZombieClass) {
		super.AfterSpawn()

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
	}

	Attack() {
		this.stompAnimation!.Play()
		return true
	}

	AttackEffect(this: this & ZombieClass) {
		const origin = this.instance.PrimaryPart!.CFrame
			.sub(new Vector3(0, 5.25, 0))

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
}

export = BossRadioactive
