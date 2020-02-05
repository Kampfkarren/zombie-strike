import { BossName } from "types/BossName"

type DataResponse<T> = LuaTuple<[T, DataStore2<T>]>

declare namespace Data {
	function GetPlayerData(player: Player, arg: "TimeBossDefeated"): DataResponse<number>
}

export = Data
