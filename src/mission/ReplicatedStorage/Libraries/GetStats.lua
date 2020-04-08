local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local function GetStats()
	local difficulty = Dungeon.GetDungeonData("Difficulty")
	local allStats = {}

	for zombieName, zombieStats in pairs(Campaigns[Dungeon.GetDungeonData("Campaign")].Stats) do
		allStats[zombieName] = {}

		for statName, stats in pairs(zombieStats) do
			allStats[zombieName][statName] = stats[difficulty]
		end
	end

	return allStats
end

return GetStats
