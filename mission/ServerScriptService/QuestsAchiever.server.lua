local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Data = require(ReplicatedStorage.Core.Data)

local GiveQuest = ServerStorage.Events.GiveQuest

local function alwaysTrue()
	return true
end

GiveQuest.Event:connect(function(player, key, value, condition)
	condition = condition or alwaysTrue
	local quests, questsStore = Data.GetPlayerData(player, "Quests")

	for _, quest in pairs(quests.Quests) do
		if quest.Type == key and condition(quest) then
			quest.Progress = quest.Progress + value
			questsStore:Set(quests)
			return
		end
	end
end)
