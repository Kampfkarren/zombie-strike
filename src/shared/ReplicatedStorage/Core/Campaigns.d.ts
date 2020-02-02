import { Difficulty } from "types/Gamemode"

type Campaign = {
	Name: string,
	Image: string,
	LockedArena?: boolean,

	Difficulties: Difficulty[],
}

declare const Campaigns: Campaign[]

export = Campaigns
