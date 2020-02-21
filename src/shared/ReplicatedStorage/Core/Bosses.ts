import { BossInfo } from "./BossInfo"

function scale(x: number): { Base: number, Scale: number } {
	return {
		Base: x,
		Scale: 1,
	}
}

type HasType<T, Q extends T> = Q
type _StaticAssert = HasType<BossInfo, typeof Bosses[number]>

const Bosses = [
	{
		Name: "Samurai Master Zombie",
		Image: "rbxassetid://4639829163",
		RoomName: "Samurai",
		AIAggroRange: 100,
		LoadingColor: Color3.fromRGB(255, 121, 32),

		Loot: {},

		Stats: {
			Common: {
				Damage: scale(0),
				DamageReceivedScale: scale(0.5),
				MaxHealthDamage: scale(30),
				Speed: scale(15),
			},

			Projectile: {
				Damage: scale(0),
				DamageReceivedScale: scale(0.5),
				MaxHealthDamage: scale(20),
				Speed: scale(13),
			},
		}
	},

	{
		Name: "Radioactive Giga Zombie",
		Image: "rbxassetid://4657828606",
		RoomName: "Radioactive",
		AIAggroRange: 200,
		LoadingColor: Color3.fromRGB(106, 176, 76),

		Loot: {
			Armor: {
				Common: [37],
				Uncommon: [38],
				Rare: [39],
				Epic: [40],
				Legendary: [41],
			},

			Helmet: {
				Common: [26],
				Uncommon: [27],
				Rare: [28],
				Epic: [29],
				Legendary: [30],
			},
		},

		Stats: {
			Boss: {
				Damage: scale(0),
				Speed: scale(12),
			},

			Common: {
				Damage: scale(0),
				DamageReceivedScale: scale(0.5),
				MaxHealthDamage: scale(20),
				Speed: scale(20),
			},
		},
	},
] as const

export = Bosses
