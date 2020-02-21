import { BossName } from "types/BossName"

type CampaignsPlayed = { [campaign: string]: number }
type DataResponse<T> = LuaTuple<[T, DataStore2<T>]>

declare namespace Data {
	function GetPlayerData(player: Player, arg: "CampaignsPlayed"): DataResponse<CampaignsPlayed>
	function GetPlayerData(player: Player, arg: "Level"): DataResponse<number>
	function GetPlayerData(player: Player, arg: "TimeBossDefeated"): DataResponse<number>

	function GetLocalPlayerData(arg: "CampaignsPlayed"): CampaignsPlayed
	function GetLocalPlayerData(arg: "Level"): number

	function SetLocalPlayerData(arg: "CampaignsPlayed", campaignsPlayed: CampaignsPlayed): void
	function SetLocalPlayerData(arg: "Level", level: number): void
}

export = Data
