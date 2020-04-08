import { Players } from "@rbxts/services"
import { RunService } from "@rbxts/services"
import Campaigns from "shared/ReplicatedStorage/Core/Campaigns"
import Data from "shared/ReplicatedStorage/Core/Data"

function MissionPlayable(
	campaignIndex: number,
	difficultyIndex: number,
	player: Player = Players.LocalPlayer,
): LuaTuple<[boolean, number?]> {
	const campaign = Campaigns[campaignIndex - 1]
	const difficulty = campaign.Difficulties[difficultyIndex - 1]

	if (difficulty === undefined) {
		return [false, 0] as LuaTuple<[boolean, number?]>
	}

	if (difficulty.MinLevel !== undefined) {
		const level = RunService.IsServer()
			? Data.GetPlayerData(player, "Level")
			: Data.GetLocalPlayerData("Level")

		if (level < difficulty.MinLevel) {
			return [false, 1] as LuaTuple<[boolean, number?]>
		}
	}

	if (difficulty.TimesPlayed !== undefined) {
		const timesPlayed = (RunService.IsServer()
			? Data.GetPlayerData(player, "CampaignsPlayed")
			: Data.GetLocalPlayerData("CampaignsPlayed")) as unknown as { [campaign: string]: number }

		let timesPlayedCampaign = timesPlayed[tostring(campaignIndex)]
		if (timesPlayedCampaign === undefined) {
			timesPlayedCampaign = 0
		}

		if (timesPlayedCampaign < difficulty.TimesPlayed) {
			return [false, 2] as LuaTuple<[boolean, number?]>
		}
	}

	return [true, undefined] as LuaTuple<[boolean, number?]>
}

export = MissionPlayable
