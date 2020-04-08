import { Players, RunService, ReplicatedStorage } from "@rbxts/services"
import Common from "./Common"
import Equip from "shared/ServerScriptService/Ruddev/Equip"
import { GetClosestPlayer } from "mission/ReplicatedStorage/Libraries/CharacterSelector"
import RealDelay from "shared/ReplicatedStorage/Core/RealDelay"

const COOLDOWN = 5
const PER_PLAYER_STUN_BUFF = 0.25
const RANGE = 20

const TaserZombieEffect = ReplicatedStorage.Remotes.Zombies.TaserZombieEffect

class Taser extends Common {
	static Model = "Taser"

	lastTased: number = 0

	AfterSpawn() {
		super.AfterSpawn()

		const taser = this.GetAsset("Taser").Clone() as Model & {
			Taser: BasePart & {
				Beam: Beam,
			},
		}
		taser.Parent = this.instance
		Equip(taser)

		this.aliveMaid.GiveTask(RunService.Heartbeat.Connect(() => {
			const stunDuration = this.GetStunDuration()
			if (tick() - this.lastTased > COOLDOWN + stunDuration) {
				const closestPlayer = GetClosestPlayer(this.instance.PrimaryPart.Position, RANGE)
				if (closestPlayer !== undefined) {
					this.lastTased = tick()

					taser.Taser.Beam.Attachment0 = (closestPlayer.Character as Character).UpperTorso.BodyFrontAttachment
					TaserZombieEffect.FireAllClients(this.instance, true)
					this.instance.Humanoid.WalkSpeed = 0

					RealDelay(stunDuration, () => {
						TaserZombieEffect.FireAllClients(this.instance)
						this.instance.Humanoid.WalkSpeed = this.GetSpeed()
					})
				}
			}
		}))
	}

	GetStunDuration() {
		return this.GetScale("StunDuration")
			* (1 + (Players.GetPlayers().size() - 1)
				* PER_PLAYER_STUN_BUFF)
	}
}

export = Taser
