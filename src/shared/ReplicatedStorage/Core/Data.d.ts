import { LootType } from "shared/ReplicatedStorage/Core/Loot"

type CampaignsPlayed = { [campaign: string]: number }
type DataResponse<T> = LuaTuple<[T, DataStore2<T>]>

type Item = {
	Type: LootType,
	Model: number,
	Perks?: [number, number][],
}

declare namespace Data {
	function GetPlayerData(player: Player, arg: "BoughtThisRotation"): DataResponse<{
		Rotation: number,
		Bought: number[],
	} | {
		Rotation: undefined,
		Bought: undefined,
	}>

	function GetPlayerData(player: Player, arg: "Brains"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "CampaignsPlayed"): DataResponse<CampaignsPlayed>
	function GetPlayerData(player: Player, arg: "CollectionLog"): DataResponse<{ [index: string]: number[] }>
	function GetPlayerData(player: Player, arg: "EquippedWeapon"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "Gold"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "Level"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "Inventory"): DataResponse<Item[]>
	function GetPlayerData(player: Player, arg: "TimeBossDefeated"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "Vouchers"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "VoucherUsedEver"): DataResponse<boolean>

	function GetLocalPlayerData(arg: "CampaignsPlayed"): CampaignsPlayed
	function GetLocalPlayerData(arg: "Level"): number

	function SetLocalPlayerData(arg: "CampaignsPlayed", campaignsPlayed: CampaignsPlayed): void
	function SetLocalPlayerData(arg: "Level", level: number): void
}

export = Data
