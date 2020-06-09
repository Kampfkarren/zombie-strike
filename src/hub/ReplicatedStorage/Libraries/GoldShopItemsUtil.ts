import { GunItem } from "shared/ReplicatedStorage/Core/Loot"

export const GUNS_TO_SELL = 4
export const MAX_LEVEL = 118 // TODO: Grab automatically from Campaigns
export const ROTATE_EVERY_SECONDS = 8 * 60 * 60 // 8 hours

export type GoldShopWeapon = {
	Cost: number,
	Gun: Omit<GunItem, "Level">,
	LevelOffset: number,
	Perks: number[],
}

export type GoldShopItems = {
	Weapons: GoldShopWeapon[],
}

export enum GoldShopPacket {
	InitialData,
	BuyWeapon,
	Requesting,
}

export function GetRotation(timestamp: number): number {
	return math.floor(timestamp / ROTATE_EVERY_SECONDS)
}
