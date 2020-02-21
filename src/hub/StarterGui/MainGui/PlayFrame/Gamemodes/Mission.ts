import { Gamemode } from "types/Gamemode"
import Campaigns from "shared/ReplicatedStorage/Core/Campaigns"
import MissionPlayable from "hub/ReplicatedStorage/Libraries/MissionPlayable"

const Mission: Gamemode = {
	Name: "Mission",
	HardcoreEnabled: true,
	Locations: Campaigns.map((campaign) => {
		return {
			Name: campaign.Name,
			Image: campaign.Image,

			Difficulties: campaign.Difficulties.map((difficulty) => difficulty),
		}
	}),

	IsPlayable: (campaignIndex: number, difficultyIndex: number) => {
		return MissionPlayable(campaignIndex, difficultyIndex)
	},

	Submit: (state) => {
		return {
			Campaign: state.campaignIndex,
			Difficulty: state.difficulty,
		}
	},
}

export = Mission
