import { Difficulty, Gamemode, Location } from "types/Gamemode"
import ArenaDifficulty from "hub/ReplicatedStorage/Libraries/ArenaDifficulty"
import ArenaConstants from "shared/ReplicatedStorage/Core/ArenaConstants"
import Campaigns from "shared/ReplicatedStorage/Core/Campaigns"
import Data from "shared/ReplicatedStorage/Core/Data"

const difficulties: Difficulty[] = []
for (let level = 0; level <= ArenaConstants.MaxLevel; level += ArenaConstants.LevelStep) {
	difficulties.push(ArenaDifficulty(math.max(1, level)))
}

const Arena: Gamemode = {
	Name: "Arena",
	HardcoreEnabled: false,
	Locations: Campaigns.filter((campaign) => {
		return campaign.LockedArena !== true
	}).map((campaign) => {
		return {
			Name: campaign.Name,
			Image: campaign.Image,

			Difficulties: difficulties,
		}
	}),

	Submit: (state) => {
		return {
			Campaign: state.campaignIndex,
			Level: difficulties[state.difficulty - 1].MinLevel,
		}
	},

	IsPlayable: (_, __, difficulty): LuaTuple<[boolean, number?]> => {
		if (difficulty.MinLevel! > Data.GetLocalPlayerData("Level")) {
			return [false, 1]
		}

		return [true]
	},
}

export = Arena
