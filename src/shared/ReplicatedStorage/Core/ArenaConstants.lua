local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)

local function stat(min, max)
	return {
		Min = min,
		Max = max,
	}
end

local function medium(campaignIndex, zombieName, statName)
	return assert(Campaigns[campaignIndex].Stats[zombieName][statName][2])
end

return {
	LevelStep = 20,
	MaxLevel = 200,
	PastCapMultiplier = 1.02,
	StopBeingLinearLevel = 70,

	BannedZombies = {
		Bomber = true,
		Turret = true,
		Sniper = true,
	},

	Zombies = {
		Common = {
			Health = stat(50, 2000),
			Damage = stat(25, 500),
			Speed = stat(13, 14),
		},

		Strong = {
			Health = stat(100, 3000),
			Damage = stat(35, 600),
			Speed = stat(12, 12.5),
		},

		Fast = {
			Health = stat(35, 1750),
			Damage = stat(25, 500),
			Speed = stat(14, 16),
		},

		AoE = {
			Health = stat(100, 3000),
			Damage = stat(35, 600),
			Speed = stat(12, 12.5),
			Range = 25,
		},

		Projectile = {
			Health = stat(35, 1750),
			Damage = stat(25, 500),
			Speed = stat(12, 13),
		},

		Shielder = {
			Health = stat(100, 3000),
			Damage = stat(25, 500),
			Speed = stat(13, 14),
			EnrangedSpeed = stat(19, 20),
		},

		Splitter = {
			Health = stat(150, 4000),
			Damage = stat(35, 600),
			Speed = stat(11, 11.5),
			BabiesSpawned = 2,
		},

		SplitterBaby = {
			Health = stat(20, 1100),
			Damage = stat(15, 350),
			Speed = stat(18, 19),
			RespawnTime = 5,
		},

		Taser = {
			Health = stat(175, 4250),
			Damage = stat(35, 600),
			Speed = stat(14, 15),
			StunDuration = medium(2, "Taser", "StunDuration"),
		},

		Gravity = {
			Health = stat(175, 4250),
			Damage = stat(35, 600),
			Speed = stat(12, 13),
		},

		Meteor = {
			Health = stat(175, 4250),
			Damage = stat(50, 800),
			MeteorDamage = stat(60, 1000),
			Speed = stat(13, 14),
			MeteorCooldown = medium(3, "Meteor", "MeteorCooldown"),
		},

		Flamecaster = {
			Health = stat(100, 3000),
			Damage = stat(25, 500),
			Speed = stat(4, 6),
			Range = medium(3, "Flamecaster", "Range"),
		},

		Blizzard = {
			Health = stat(150, 4000),
			Damage = stat(35, 600),
			Speed = stat(14, 16),
		},

		MegaSnowball = {
			Health = stat(175, 4250),
			Damage = stat(35, 600),
			SnowballDamage = stat(50, 800),
			Speed = stat(14, 16),
			Cooldown = medium(4, "MegaSnowball", "Cooldown"),
		},
	},
}
