import { BossInfo, BossStat } from "./BossInfo"

const Bosses: Array<BossInfo> = [{
	Name: "Samurai Master Zombie",
	RoomName: "Samurai",
	AIAggroRange: 100,

	Stats: {
		"Projectile": {
			Damage: {
				Base: 0,
				Scale: 1,
			},

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
