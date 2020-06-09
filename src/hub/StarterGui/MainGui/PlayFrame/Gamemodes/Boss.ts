import { Gamemode } from "types/Gamemode"
import Bosses from "shared/ReplicatedStorage/Core/Bosses"
import BossImageOverlay from "./BossImageOverlay"

const Boss: Gamemode = {
	Name: "Boss",
	HardcoreEnabled: true,
	Locations: Bosses.mapFiltered((boss) => {
		if (boss.Name === "Egg Mech Zombie") {
			return
		}

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
	},

	IsPlayable: () => {
		return [true] as LuaTuple<[boolean, number?]>
	},
}

export = Boss
