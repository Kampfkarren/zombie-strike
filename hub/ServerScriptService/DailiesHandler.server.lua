local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DailiesDictionary = require(ReplicatedStorage.DailiesDictionary)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local Dailies = ReplicatedStorage.Remotes.Dailies

local SECONDS_IN_DAY = 60 * 60 * 24

DataStore2.Combine("DATA", "Brains")

local function getDaysSince(time)
	return math.floor((os.time() - time) / SECONDS_IN_DAY)
end

Players.PlayerAdded:connect(function(player)
	local dailies, dailiesStore = Data.GetPlayerData(player, "Dailies")
	local daysSinceLast = getDaysSince(dailies.Time)

	if daysSinceLast <= 0 then
		return
	elseif daysSinceLast == 1 then
		dailies.Streak = (dailies.Streak % #DailiesDictionary) + 1
	else
		dailies.Streak = 1
	end

	DataStore2("Brains", player):Increment(DailiesDictionary[dailies.Streak])

	Dailies:FireClient(player, dailies.Streak)
	dailies.Time = os.time()
	dailiesStore:Set(dailies)
end)
