import { Difficulty, Gamemode, Location } from "types/Gamemode"
import Bosses from "shared/ReplicatedStorage/Core/Bosses"
import BossImageOverlay from "./BossImageOverlay"

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

	ImageOverlay: (e) => {
		return e(BossImageOverlay)
	}
}

export = Boss
