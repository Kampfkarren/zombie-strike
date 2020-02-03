import { BossInfo } from "./BossInfo"

function scale(x: number): { Base: number, Scale: number } {
	return {
		Base: x,
		Scale: 1,
	}
}

const Bosses = [
	{
		Name: "Samurai Master Zombie",
		Image: "rbxassetid://4639829163",
		RoomName: "Samurai",
		AIAggroRange: 100,

		Stats: {
			Common: {
				Damage: scale(0),
				MaxHealthDamage: scale(30),
				Speed: scale(15),
			},

			Projectile: {
				Damage: scale(0),
				MaxHealthDamage: scale(20),
				Speed: scale(13),
			},
		}
	},

	{
		Name: "Radioactive Giga Zombie",
		Image: "rbxassetid://378620366",
		RoomName: "Radioactive",
		AIAggroRange: 200,

		Stats: {
			Boss: {
				Speed: scale(14),
			},
		},
	},
] as const

export = Bosses
