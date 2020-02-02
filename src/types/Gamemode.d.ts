export type Difficulty = {
	MinLevel: number,
	Style: {
		Name: string,
		Color: Color3,
	},
}

export type Location = {
	Name: string,
	Image: string,
	Difficulties?: Difficulty[],
}

type CreateState = {
	campaignIndex: number,
	difficulty: number,
}

export type Gamemode = {
	Name: string,
	Locations: Location[],
	HardcoreEnabled: boolean,

	Submit(state: CreateState): object,
}
