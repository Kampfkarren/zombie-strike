type Standard = {
	SpecialZombies: string[],
}

declare namespace DungeonState {
	export let CurrentGamemode: Standard
	export let CurrentSpawn: SpawnLocation | Attachment | undefined
	export let CurrentRoom: Model | undefined
	export let NormalZombies: number
}

export = DungeonState
