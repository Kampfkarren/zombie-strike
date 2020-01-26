interface ReplicatedStorage {
	Remotes: Folder & {
		SendServerLogs: RemoteEvent,
	},
}
