import { Players, ReplicatedStorage } from "@rbxts/services"
import { BossClass, ZombieClass } from "./ZombieClass"
import ExperienceUtil from "mission/ServerScriptService/Libraries/ExperienceUtil"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import GetAvailableMissions from "shared/ReplicatedStorage/Core/GetAvailableMissions"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

export type BossAttack<T> = (self: T) => Promise<void> | void

export class RotatingBoss<Room extends Model> implements Partial<BossClass<Room>> {
	bossRoom: Room | undefined
	currentPhase: number = -1
	nextPhaseEvent: RemoteEvent
	phaseValue: NumberValue | undefined

	attackInterval: number = 4
	phases: BossAttack<this>[][] = []

	constructor() {
		this.nextPhaseEvent = this.NewRemoteEvent("NextPhase")
	}

	AfterSpawn() {
		this.phaseValue = new Instance("NumberValue")
		this.phaseValue.Name = "CurrentPhase"
		this.phaseValue.Value = -1
		this.phaseValue.Parent = (this as unknown as ZombieClass).instance
	}

	InitializeAI(this: this & ZombieClass) {
		this.instance.Humanoid.LoadAnimation(this.GetAsset("IdleAnimation") as Animation).Play()
	}

	InitializeBossAI(this: RotatingBoss<Room> & ZombieClass, room: Room) {
		this.bossRoom = room

		this.instance.Humanoid.HealthChanged.Connect((health) => {
			const expectedPhase = -math.ceil(health / (100 / this.phases.size())) + this.phases.size()
			if (this.currentPhase !== expectedPhase && health > 0) {
				this.nextPhaseEvent.FireAllClients()
				this.NextPhase()
			}
		})

		this.NextPhase()
	}

	GiveXP(this: ZombieClass) {
		for (const player of Players.GetPlayers()) {
			const missions = GetAvailableMissions(player)
			let earlierMission = missions[0]

			for (let index = 2; index >= 1; index--) {
				const nearbyMission = missions[missions.size() - index]
				if (nearbyMission !== undefined) {
					earlierMission = nearbyMission
					break
				}
			}

			ExperienceUtil.GivePlayerXP(player, earlierMission.XP, this.instance.PrimaryPart)
		}
	}

	NextPhase(this: this & ZombieClass) {
		this.currentPhase += 1
		const currentPhase = this.currentPhase
		const phase = this.phases[currentPhase]
		if (phase === undefined) {
			return
		}

		this.phaseValue!.Value = currentPhase
		let currentSequence = 0

		Interval(this.attackInterval, () => {
			if (!this.alive) {
				return false
			}

			const result = phase[currentSequence](this)
			if (Promise.is(result)) {
				result.await()
			}

			currentSequence = (currentSequence + 1) % phase.size()

			if (this.currentPhase !== currentPhase) {
				return false
			}
		})
	}

	NewRemoteEvent(remoteEventName: string): RemoteEvent {
		const remoteEvent = new Instance("RemoteEvent")
		remoteEvent.Name = remoteEventName
		remoteEvent.Parent = ReplicatedStorage.Remotes.RotatingBoss
		return remoteEvent
	}

	NewDamageSource(remoteEventName: string, damage: number | number[]): RemoteEvent {
		const remoteEvent = this.NewRemoteEvent(remoteEventName)
		remoteEvent.OnServerEvent.Connect((player) => {
			// this is gross, but `this` wouldn't work
			TakeDamage(
				player,
				Zombie.GetDamageAgainstConstant(
					undefined,
					player,
					0,
					typeIs(damage, "number")
						? damage
						: assert(
							damage[this.currentPhase],
							`No damage for ${remoteEventName} specified for phase ${this.currentPhase}`,
						),
				)
			)
		})

		return remoteEvent
	}
}
