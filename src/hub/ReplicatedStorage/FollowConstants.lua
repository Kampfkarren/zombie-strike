local FollowConstants = {}

FollowConstants.Codes = {
	TeleportServiceFailure = 1,
	PlayerInMission = 2,
	PlayerLeftGame = 3,
}

FollowConstants.Messages = {
	[FollowConstants.Codes.TeleportServiceFailure] = "There was an error teleporting you: %s",
	[FollowConstants.Codes.PlayerInMission] = "%s is already in a mission.",
	[FollowConstants.Codes.PlayerLeftGame] = "%s left the game.",
}

return FollowConstants
