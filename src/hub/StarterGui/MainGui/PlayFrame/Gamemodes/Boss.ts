import { Gamemode } from "types/Gamemode"
import Bosses from "shared/ReplicatedStorage/Core/Bosses"
import BossImageOverlay from "./BossImageOverlay"

const Boss: Gamemode = {
	Name: "Boss",
	HardcoreEnabled: true,
	Locations: Bosses.mapFiltered((boss) => {
		return {
			Name: boss.Name === "Egg Mech Zombie" ? "[EVENT] Egg Mech Zombie" : boss.Name,
			Image: boss.Image,
			LayoutOrder: boss.Name === "Egg Mech Zombie" ? 0 : undefined,
			PickMe: boss.Name === "Egg Mech Zombie",
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
