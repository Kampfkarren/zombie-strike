import { ServerStorage } from "@rbxts/services"
import { WeaponPerk } from "../Perk"
import Damage from "shared/ReplicatedStorage/RuddevModules/Damage"
import Interval from "shared/ReplicatedStorage/Core/Interval"
import Maid from "shared/ReplicatedStorage/Core/Maid"
import OnDied from "shared/ReplicatedStorage/Core/OnDied"
import PerkIcon from "../PerkIcon"

const DAMAGE_RANGE = [0.15, 0.2]
const ON_FIRE_FOR = 2

class IncindearyRounds extends WeaponPerk {
	static Name = "Incindeary Rounds"
	static Icon = PerkIcon.Fire
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = [{
		Range: DAMAGE_RANGE,
	}]

	onFire: Map<Humanoid, {
		cycles: number,
		damage: number,
		time: number,

		maid: Maid,
	}> = new Map()

	DamageDealt(damage: number, zombie: Humanoid): void {
		const onFire = this.onFire.get(zombie)

		if (onFire !== undefined) {
			// If player dealt more damage this time, than just deal that
			onFire.damage = math.max(damage, onFire.damage)
			onFire.time = tick()
			onFire.cycles = 0
		} else {
			OnDied(zombie).Connect(() => {
				const onFire = this.onFire.get(zombie)
				if (onFire !== undefined) {
					onFire.maid.DoCleaning()
				}
			})

			const maid = new Maid()

			for (let asset of ServerStorage.Assets.Fire.GetChildren()) {
				asset = asset.Clone()
				asset.Parent = (zombie.Parent as Model).PrimaryPart

				if (asset.IsA("ParticleEmitter")) {
					maid.GiveTaskParticleEffect(asset)
				} else {
					maid.GiveTask(asset)
				}
			}

			maid.GiveTask(Interval(1, () => {
				const onFire = this.onFire.get(zombie)!
				Damage.Damage(zombie, damage * this.Value(0), this.player, false)

				onFire.cycles += 1
				if (onFire.cycles === ON_FIRE_FOR) {
					maid.DoCleaning()
				}
			}))

			maid.GiveTask(() => {
				this.onFire.delete(zombie)
			})

			this.onFire.set(zombie, {
				cycles: 0,
				damage,
				time: tick(),
				maid,
			})
		}
	}
}

export = IncindearyRounds
