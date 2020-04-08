import { BossInfo } from "./BossInfo"
import { LootReward } from "types/Gamemode"

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

		Loot: new Map() as LootReward,

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

		Loot: new Map([
			["Armor" as const, new Map([
				["Common" as const, [37]],
				["Uncommon" as const, [38]],
				["Rare" as const, [39]],
				["Epic" as const, [40]],
				["Legendary" as const, [41]],
			])],

			["Helmet" as const, new Map([
				["Common" as const, [26]],
				["Uncommon" as const, [27]],
				["Rare" as const, [28]],
				["Epic" as const, [29]],
				["Legendary" as const, [30]],
			])],
		]),

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

	{
		Name: "Egg Mech Zombie",
		Image: "rbxassetid://4865133876",
		RoomName: "Egg",
		AIAggroRange: 200,
		LoadingColor: Color3.fromRGB(126, 214, 223),

		Loot: new Map() as LootReward,

		Stats: {
			Common: {
				Damage: scale(0),
				DamageReceivedScale: scale(0.5),
				MaxHealthDamage: scale(30),
				Speed: scale(15),
			},
		},
	},
] as const

export = Bosses
