import { Gun } from "shared/ReplicatedStorage/Core/Loot"
import { AnimationLike, Perk, WeaponPerk } from "../../Perk"
import PerkIcon from "../../PerkIcon"

const BUFF_MAGAZINE = [1, 1]
const BUFF_FIRE_RATE = [1, 1]

const NERF_DAMAGE = 1 - 0.45

const UPGRADE_BUFFS = [1, 1.07, 1.14, 1.2]

const scriptContents = script as Instance & {
	Aim: Animation,
	Equip: Animation,
	Idle: Animation,
	Reload: Animation,
	ShootLeft: Animation,
	ShootRight: Animation,
}

type GunModel = Model & {
	PrimaryPart: BasePart & {
		Muzzle: Attachment,
	},
}

type HasGun = Instance & {
	Gun: GunModel,
	SecondGun: GunModel,
}

const values = [{
	Range: BUFF_FIRE_RATE,
	UpgradePercent: UPGRADE_BUFFS,
	Offset: 0,
}, {
	Range: BUFF_MAGAZINE,
	UpgradePercent: UPGRADE_BUFFS,
	Offset: 1,
}]

class DualWield extends WeaponPerk {
	static Name = "Dual Wield"
	static Icon = PerkIcon.Pistol
	static LegendaryPerk = true
	static PowerBuff = 1.25

	static Values = values

	static ModifyStats(this: void, gun: Readonly<Gun>, upgrades: number): Gun {
		return {
			...gun,
			Damage: gun.Damage * NERF_DAMAGE,
			FireRate: gun.FireRate * (1 + Perk.GetValue(
				gun.Seed,
				upgrades,
				values[0],
			)),
			Magazine: math.floor(0.5 + gun.Magazine * (1 + Perk.GetValue(
				gun.Seed,
				upgrades,
				values[1],
			))),
		}
	}

	static ModifyWeaponAnimations(
		this: void,
		oldAnimations: Map<string, AnimationLike>,
		humanoid: Humanoid,
	): Map<string, AnimationLike> {
		const animations = new Map(oldAnimations.entries())
		animations.set("Aim", humanoid.LoadAnimation(scriptContents.Aim))
		animations.set("Equip", humanoid.LoadAnimation(scriptContents.Equip))
		animations.set("Idle", humanoid.LoadAnimation(scriptContents.Idle))
		animations.set("Reload", humanoid.LoadAnimation(scriptContents.Reload))

		const shootLeft = humanoid.LoadAnimation(scriptContents.ShootLeft)
		const shootRight = humanoid.LoadAnimation(scriptContents.ShootRight)

		let shootingLeft = true

		// TODO AimShoot

		animations.set("Shoot", {
			Play: function (fadeTime, weight, speed) {
				(shootingLeft ? shootLeft : shootRight).Play(fadeTime, weight, speed)
				let muzzle

				if (shootingLeft) {
					muzzle = (humanoid.Parent as HasGun).Gun.PrimaryPart.Muzzle
				} else {
					muzzle = (humanoid.Parent as HasGun).SecondGun.PrimaryPart.Muzzle
				}

				shootingLeft = !shootingLeft
				return muzzle
			},

			Stop: () => { },
		})

		animations.set("AimShoot", animations.get("Shoot")!)

		return animations
	}
}

export = DualWield
