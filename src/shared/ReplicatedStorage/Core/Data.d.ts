import { BossName } from "types/BossName"

type DataResponse<T> = LuaTuple<[T, DataStore2<T>]>

declare namespace Data {
	const GetPlayerData: (player: Player, arg: "BossesDefeated") => DataResponse<Map<BossName, boolean>>
}

export = Data
