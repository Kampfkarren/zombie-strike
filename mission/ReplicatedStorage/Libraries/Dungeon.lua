local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local MockDungeon = require(ReplicatedStorage.Core.MockData.MockDungeon)

local Dungeon = {}

function Dungeon.GetDungeonData(key)
	-- TODO: Put this in teleport data or a data store
	if key == "CampaignInfo" then
		return Campaigns[Dungeon.GetDungeonData("Campaign")]
	elseif key == "DifficultyInfo" then
		return Dungeon.GetDungeonData("CampaignInfo").Difficulties[Dungeon.GetDungeonData("Difficulty")]
	elseif MockDungeon[key] then
		return MockDungeon[key]
	else
		error("dungeon key does not exist: " .. key)
	end
end

return Dungeon
