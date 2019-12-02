local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local QuestsDictionary = require(ReplicatedStorage.Core.QuestsDictionary)

local UpdateQuests = ReplicatedStorage.Remotes.UpdateQuests

local QUEST_COUNT = 3

local rng = Random.new()

local function pickArgument(argument)
	if argument.Type == "Number" then
		local number = rng:NextInteger(argument.Range[1], argument.Range[2])

		if argument.RoundToNearest then
			local near = argument.RoundToNearest
			number = math.floor((number + near / 2) / near) * near
		end

		return number
	elseif argument.Type == "Weapon" then
		return GunScaling.RandomType()
	else
		error("unknown argument type: " .. argument.Type)
	end
end

local function getQuests()
	local quests = {}

	local ourQuests = {}
	for key, value in pairs(QuestsDictionary.Quests) do
		table.insert(ourQuests, { key, value })
	end

	for _ = 1, QUEST_COUNT do
		local key, value = unpack(table.remove(ourQuests, math.random(#ourQuests)))
		local args = {}

		for _, argument in pairs(value.Args) do
			table.insert(args, assert(pickArgument(argument)))
		end

		table.insert(quests, {
			Type = key,
			Args = args,
			Progress = 0,
		})
	end

	return quests
end

Players.PlayerAdded:connect(function(player)
	local time = os.date("!*t")
	local _, brainsStore = Data.GetPlayerData(player, "Brains")
	local quests, questsStore = Data.GetPlayerData(player, "Quests")

	local modifiedQuests = false

	for _, quest in ipairs(quests.Quests) do
		if not quest.Finished and quest.Progress >= quest.Args[1] then
			quest.Finished = true
			brainsStore:Increment(QuestsDictionary.Reward, 0)
			modifiedQuests = true
		end
	end

	if modifiedQuests then
		questsStore:Set(quests)
	end

	if quests.Day ~= time.yday then
		quests = getQuests()
		questsStore:Set({
			Day = time.yday,
			Quests = quests,
		})
	end

	UpdateQuests:FireClient(player, quests.Quests)
end)
