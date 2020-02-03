interface ReplicatedStorage {
	Assets: Folder & {
		Bosses: Folder & {
			Samurai: Folder & {
				Boss: Folder & {
					Crescent: BasePart,
					Katana: BasePart,
					Shuriken: BasePart,
				},
			},
		},

		Campaign: Folder & {
			[name: string]: Folder,
		},
	},

	BossSequences: Folder & {
		[name: string]: ModuleScript,
	},

	Remotes: Folder & {
		CircleEffect: RemoteEvent,
		NewBoss: RemoteEvent,
		RotatingBoss: Folder,
		SendServerLogs: RemoteEvent,
	},
}

interface ServerScriptService {
	BossLocalScripts: Folder,
}

interface ServerStorage {
	BossRooms: Folder & {
		[name: string]: Model,
	},
}

interface SoundService {
	ZombieSounds: Folder & {
		Samurai: Folder & {
			Boss: Folder & {
				Attack: Sound,
				Yooo: Sound,
				ZombieSummon: Sound,
			},
		},
	},
}

interface StarterPlayer {
	StarterPlayerScripts: Folder,
}

interface Workspace {
	Rooms: Folder & {
		StartSection: Model,
	},
}
