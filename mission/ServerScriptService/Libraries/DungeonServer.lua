local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local MockDungeon = require(ReplicatedStorage.Core.MockData.MockDungeon)
local Promise = require(ReplicatedStorage.Core.Promise)

local Dungeon = {}

local dungeonDataStore = DataStoreService:GetDataStore("DungeonInfo")
local dungeonTablePromise

function Dungeon.GetDungeonTable()
	if RunService:IsStudio() then
		return Promise.resolve(MockDungeon)
	else
		if not dungeonTablePromise then
			dungeonTablePromise = Promise.new(function(resolve, reject)
				coroutine.wrap(function()
					local success, error = pcall(function()
						dungeonDataStore:UpdateAsync(game.PrivateServerId, function(value)
							assert(value ~= nil)
							resolve(value)
							return value
						end)
					end)

					if not success then
						reject(error)
					end
				end)()
			end)
		end

		return dungeonTablePromise
	end
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
