import { Gamemode } from "types/Gamemode"
import Campaigns from "shared/ReplicatedStorage/Core/Campaigns"

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

	Submit: (state) => {
		return {
			Campaign: state.campaignIndex,
			Difficulty: state.difficulty,
		}
	},
}

export = Mission
