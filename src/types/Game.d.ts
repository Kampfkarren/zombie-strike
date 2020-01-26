interface ReplicatedStorage {
	BossSequences: Folder & {
		[name: string]: ModuleScript,
	},

	Remotes: Folder & {
		SendServerLogs: RemoteEvent,
	},
}

interface ServerStorage {
	BossRooms: Folder & {
		[name: string]: Model,
	},
}
