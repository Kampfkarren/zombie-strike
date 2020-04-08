interface ReplicatedStorage {
	Assets: Folder & {
		Bosses: Folder & {
			Egg: Folder & {
				Boss: Folder & {
					EggBomb: BasePart & {
						Mesh: SpecialMesh,
					},
					EggFrenzy: BasePart,
					SludgeBall: BasePart,
					SludgeFire: Animation,
					SludgePrime: Animation,
				},
			},

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
			Campaign2: Folder & {
				Gravity: Folder & {
					Beam: Beam,
				},

				Taser: Folder & {
					Tased: Animation,
					Tasering: Animation,
				},
			},

			Campaign3: Folder & {
				Meteor: Folder & {
					Cast: Animation,
					Meteor: BasePart,
					Impact: BasePart & {
						ParticleEmitter: ParticleEmitter,
					},
				},
			},

			Campaign4: Folder & {
				Boss: Folder & {
					Ring: BasePart,
				},

				Blizzard: Folder & {
					Range: BasePart & {
						Gust: Sound,
					},
					SlowedParticle: ParticleEmitter,
				},

				MegaSnowball: Folder & {
					Animation: Animation,
					IceCube: BasePart & {
						SpecialMesh: SpecialMesh,
					},
					Snowball: BasePart,
				},
			},

			Campaign5: Folder & {
				Lasso: Folder & {
					Prime: Animation,
					Pull: Animation,
					Rope: Model & {
						PrimaryPart: BasePart & {
							Center: Attachment,
						},
					},
					StunAction: ParticleEmitter,
					StunParticle: ParticleEmitter,
					StunPull: Animation,
					StunStill: Animation,
					ThrowLoop: Animation,
				},
			},

			Campaign6: Folder & {
				Boss: Folder & {
					MissileRingAnimation: Animation,
					SludgeBall: BasePart,
					SludgeFire: Animation,
					SludgePrime: Animation,
				},

				DarkMagic: Folder & {
					ShootAnimation: Animation,
					Template: BasePart,
				},
			},

			[name: string]: Folder,
		},

		Range: Part,
		Warning: BasePart,
	},

	BossSequences: Folder & {
		[name: string]: ModuleScript,
	},

	Items: Folder & {
		[name: string]: Instance & {
			ItemType: StringValue,
		},
	},

	HubWorld: BoolValue,

	Remotes: Folder & {
		CircleEffect: RemoteEvent,
		NewBoss: RemoteEvent,
		RotatingBoss: Folder,
		SendServerLogs: RemoteEvent,
		UpdateCampaignsPlayed: RemoteEvent,
		UpdateCollectionLog: RemoteEvent,

		Tower: Folder & {
			Boss: Folder & {
				MagicMissiles: RemoteEvent,
				MissileRing: RemoteEvent,
			},
		},

		Zombies: Folder & {
			DarkMagicZombieEffect: RemoteEvent,
			GunslingerZombieEffect: RemoteEvent,
			LassoZombieEffect: RemoteEvent,
			MegaSnowballZombieEffect: RemoteEvent,
			MeteorZombieEffect: RemoteEvent,
			SniperZombieEffect: RemoteEvent,
			TaserZombieEffect: RemoteEvent,
		},
	},
}

interface ServerScriptService {
	BossLocalScripts: Folder,

	Zombies: Folder & {
		Zombie: ModuleScript,
	},
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

		Egg: Folder & {
			Boss: Folder & {
				Crash: Sound,
				Shoot: Sound,
			},
		},

		"2": Folder & {
			Gravity: Folder & {
				Loop: Sound,
			},

			Taser: Folder & {
				Loop: Sound,
			},
		},

		"3": Folder & {
			Flamecaster: Folder & {
				Cast: Sound,
				Loop: Sound,
			},

			Meteor: Folder & {
				Impact: Sound,
			},
		},

		"4": Folder & {
			MegaSnowball: Folder & {
				Frozen: Sound,
				Pickup: Sound,
			},
		},

		"5": Folder & {
			Lasso: Folder & {
				Catch: Sound,
				Throw: Sound,
			},

			Sniper: Folder & {
				Countdown: Sound,
				Shot: Sound,
			},
		},

		"6": Folder & {
			Boss: Folder & {
				Magic: Folder,
			},

			DarkMagic: Folder & {
				Cast: Sound,
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
	Zombies: Folder,
}
