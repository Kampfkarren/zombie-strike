interface ReplicatedStorage {
	Assets: Folder & {
		Bosses: Folder & {
			Radioactive: Folder & {
				Boss: Folder & {
					PsychoAnimation: Animation,
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

			Campaign6: Folder & {
				Boss: Folder & {
					MissileRingAnimation: Animation,
					SludgeBall: BasePart,
					SludgeFire: Animation,
					SludgePrime: Animation,
				},
			},

			[name: string]: Folder,
		},

		Warning: BasePart,
	},

	BossSequences: Folder & {
		[name: string]: ModuleScript,
	},

	Remotes: Folder & {
		CircleEffect: RemoteEvent,
		NewBoss: RemoteEvent,
		RotatingBoss: Folder,
		SendServerLogs: RemoteEvent,
		UpdateCampaignsPlayed: RemoteEvent,

		Tower: Folder & {
			Boss: Folder & {
				MagicMissiles: RemoteEvent,
				MissileRing: RemoteEvent,
			},
		},
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
		Radioactive: Folder & {
			Boss: Folder & {
				BallHit: Folder,
				BeamDamage: Folder,
				BeamReady: Folder,
				Jump: Sound,
				JumpLand: Folder,
				Smash: Folder,
				ThrowBall: Sound,
			},
		},

		Samurai: Folder & {
			Boss: Folder & {
				Attack: Sound,
				Yooo: Sound,
				ZombieSummon: Sound,
			},
		},

		"6": Folder & {
			Boss: Folder & {
				Magic: Folder,
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
