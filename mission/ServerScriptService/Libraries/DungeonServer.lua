local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local MockDungeon = require(ReplicatedStorage.Core.MockData.MockDungeon)
local Promise = require(ReplicatedStorage.Core.Promise)

local Dungeon = {}

local dungeonDataStore = DataStoreService:GetDataStore("DungeonInfo")
local dungeonTablePromise

local MOCK_FAILURE = false

local totalRetries = 0

local function getPrivateServerId()
	if RunService:IsStudio() then
		return "MOCK_PRIVATE_SERVER"
	else
		return game.PrivateServerId
	end
end

local function updateAsync(key, callback)
	if RunService:IsStudio() and MOCK_FAILURE then
		if totalRetries < MOCK_FAILURE then
			error("Simulated UpdateAsync failure")
		else
			callback(MockDungeon)
			return
		end
	end

	dungeonDataStore:UpdateAsync(key, callback)
end

function Dungeon.GetDungeonTable()
	if RunService:IsStudio() then
		if not MOCK_FAILURE then
			return Promise.resolve(MockDungeon)
		end
	end

	if not dungeonTablePromise then
		dungeonTablePromise = Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				while true do
					local success, error = pcall(function()
						updateAsync(getPrivateServerId(), function(value)
							assert(value ~= nil)
							resolve(value)
							if totalRetries > 0 then
								print("finally resolved GetDungeonTable after", totalRetries, "retries")
							end
							return value
						end)
					end)

					if success then
						break
					else
						totalRetries = totalRetries + 1
						print("GetDungeonTable failed:", error)
						print("retries:", totalRetries)

						wait(0.5)
					end
				end
			end)()
		end)
	end

	return dungeonTablePromise
end

function Dungeon.GetDungeonData(key)
	if key == "CampaignInfo" then
		return Campaigns[Dungeon.GetDungeonData("Campaign")]
	elseif key == "DifficultyInfo" then
		return Dungeon.GetDungeonData("CampaignInfo").Difficulties[Dungeon.GetDungeonData("Difficulty")]
	elseif MockDungeon[key] ~= nil then
		local success, result = Dungeon.GetDungeonTable():await()
		assert(success, result)
		return result[key]
	else
		error("dungeon key does not exist: " .. key)
	end
end

function Dungeon.RNGZombieLevel()
	local difficultyInfo = Dungeon.GetDungeonData("DifficultyInfo")
	return math.random(difficultyInfo.MinLevel, difficultyInfo.MinLevel + 2)
end

return Dungeon
