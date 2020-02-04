interface ReplicatedStorage {
	Assets: Folder & {
		Bosses: Folder & {
			Radioactive: Folder & {
				Boss: Folder & {
					SlamAnimation: Animation,
					SludgeBall: BasePart,
					SludgeFire: Animation,
					SludgePrime: Animation,
				},
			},

			Samurai: Folder & {
				Boss: Folder & {
					Crescent: BasePart,
					Katana: BasePart,
					Shuriken: BasePart,
				},
			},
		},

		Campaign: Folder & {
			Campaign4: Folder & {
				Boss: Folder & {
					Ring: BasePart,
				},
			},

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
	Effects: Folder,
	Rooms: Folder & {
		StartSection: Model,
	},
}
