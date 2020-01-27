type DataResponse<T> = LuaTuple<[T, DataStore2<T>]>

declare namespace Data {
	const GetPlayerData: (player: Player, arg: "LastDefeatedBoss") => DataResponse<string | undefined>
}

export = Data
