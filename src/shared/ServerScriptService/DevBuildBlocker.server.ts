import { Players, RunService } from "@rbxts/services"

const DEV_GAME = 1429320739
const EGG_GROUP_ID = 5574100
const GOOD_APE_GROUP_ID = 3212936
const TESTER_RANK = 103
const ALLOW = new Set(["Kampfkarren", "megahammer", "chesse20"])

Players.PlayerAdded.Connect((player) => {
	if (RunService.IsStudio() || game.GameId !== DEV_GAME) {
		return
	}

	if (player.GetRankInGroup(EGG_GROUP_ID) === 0
		&& player.GetRankInGroup(GOOD_APE_GROUP_ID) !== TESTER_RANK
		&& !ALLOW.has(player.Name)
	) {
		player.Kick("This place is currently closed to testers.")
	}
})
