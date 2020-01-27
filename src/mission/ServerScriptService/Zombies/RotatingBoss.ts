import { ReplicatedStorage } from "@rbxts/services"
import { BossClass, ZombieClass } from "./ZombieClass"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import TakeDamage from "shared/ServerScriptService/TakeDamage"
import Zombie from "./Zombie"

export class RotatingBoss implements Partial<BossClass> {
	bossRoom: Model | undefined
	currentPhase: number = -1

	attackInterval: number = 4
	phases: ((self: this) => Promise<void> | void)[][] = []

	InitializeAI() { }

	InitializeBossAI(this: RotatingBoss & ZombieClass, room: Model) {
		this.bossRoom = room

		this.NextPhase()
	}

	NextPhase() {
		this.currentPhase += 1
		const currentPhase = this.currentPhase
		const phase = this.phases[currentPhase]
		if (phase === undefined) {
			return
		}

		let currentSequence = 0

		Interval(this.attackInterval, () => {
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

	NewDamageSource(remoteEventName: string, damage: number): RemoteEvent {
		const remoteEvent = new Instance("RemoteEvent")
		remoteEvent.Name = remoteEventName
		remoteEvent.OnServerEvent.Connect((player) => {
			// this is gross, but `this` wouldn't work
			TakeDamage(player, Zombie.GetDamageAgainstConstant(undefined, player, 0, damage))
		})

		remoteEvent.Parent = ReplicatedStorage.Remotes.RotatingBoss

		return remoteEvent
	}
}
