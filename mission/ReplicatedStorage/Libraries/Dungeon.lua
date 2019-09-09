local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local MockDungeon = require(ReplicatedStorage.Core.MockData.MockDungeon)
local Promise = require(ReplicatedStorage.Core.Promise)

local Dungeon = {}

local dungeonTablePromise

function Dungeon.GetDungeonTable()
	if RunService:IsStudio() then
		return Promise.resolve(MockDungeon)
	else
		if not dungeonTablePromise then
			dungeonTablePromise = Promise.new(function(resolve, reject)
				local playersChecked = 0

				local function playerAdded(player)
					local joinData = player:GetJoinData()
					-- TODO: Check if SourcePlaceId is valid
					local teleportData = joinData.TeleportData
					table.foreach(joinData, print)

					playersChecked = playersChecked + 1

					if teleportData == nil then
						-- uh oh, cheater. shoo
						-- player:Kick("There was an issue with your mission--error code 'ant'")

						-- if playersChecked == #joinData.Members then
							-- *all* of them were cheaters?!?
							-- reject()
						-- end

						return
					end

					print("dungeon data receieved")
					table.foreach(teleportData.DungeonData, print)
					resolve(teleportData.DungeonData)
				end

				for _, player in pairs(Players:GetPlayers()) do
					playerAdded(player)
				end

				Players.PlayerAdded:connect(playerAdded)
			end)
		end

		return dungeonTablePromise
	end
end

function Dungeon.GetDungeonData(key)
	-- TODO: Put this in teleport data or a data store
	if key == "CampaignInfo" then
		return Campaigns[Dungeon.GetDungeonData("Campaign")]
	elseif key == "DifficultyInfo" then
		return Dungeon.GetDungeonData("CampaignInfo").Difficulties[Dungeon.GetDungeonData("Difficulty")]
	elseif MockDungeon[key] then
		local success, result = Dungeon.GetDungeonTable():await()

		-- Uncomment the below code if it's possible to get number of players

		-- if not success then
		-- 	local playerNames = {}

		-- 	for _, player in pairs(Players:GetPlayers()) do
		-- 		table.insert(playerNames, player.Name)
		-- 	end

		-- 	warn(string.format(
		-- 		"GetDungeonTable has FAILED! This should only be possible when there's a hacker!\n"
		-- 		.. "List of players:\n%s",
		-- 		table.concat(playerNames, "\n")
		-- 	))

		-- 	if not RunService:IsStudio() then
		-- 		for _, player in pairs(Players:GetPlayers()) do
		-- 			player:Kick("There was an issue with your mission--error code 'worm'")
		-- 		end

		-- 		coroutine.yield() -- don't let anything that would error by this continue, it's over
		-- 	end
		-- end

		return result[key]
	else
		error("dungeon key does not exist: " .. key)
	end
end

return Dungeon
