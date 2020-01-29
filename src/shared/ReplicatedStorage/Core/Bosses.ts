import { BossInfo } from "./BossInfo"

const NO_DAMAGE = {
	Base: 0,
	Scale: 1,
}

const Bosses: Array<BossInfo> = [{
	Name: "Samurai Master Zombie",
	Image: "rbxassetid://4639829163",
	RoomName: "Samurai",
	AIAggroRange: 100,

	Stats: {
		Common: {
			Damage: NO_DAMAGE,

			MaxHealthDamage: {
				Base: 30,
				Scale: 1,
			},

			Speed: {
				Base: 15,
				Scale: 1,
			},
		},

		Projectile: {
			Damage: NO_DAMAGE,

			MaxHealthDamage: {
				Base: 20,
				Scale: 1,
			},

			Speed: {
				Base: 13,
				Scale: 1,
			},
		},
	}
}]

export = Bosses
