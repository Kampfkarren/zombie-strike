import { Difficulty, Gamemode, Location } from "types/Gamemode"
import Bosses from "shared/ReplicatedStorage/Core/Bosses"

const Boss: Gamemode = {
	Name: "Boss",
	HardcoreEnabled: true,
	Locations: Bosses.map((boss) => {
		return {
			Name: boss.Name,
			Image: boss.Image,
		}
	}),

	Submit: (state) => {
		return {
			Boss: state.campaignIndex,
		}
	},
}

export = Boss
