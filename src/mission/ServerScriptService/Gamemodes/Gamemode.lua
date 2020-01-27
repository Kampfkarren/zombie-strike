local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local GenerateLoot = require(ServerScriptService.Libraries.GenerateLoot)
local GetAvailableMissions = require(ReplicatedStorage.Core.GetAvailableMissions)
local GiveQuest = ServerStorage.Events.GiveQuest
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)
local Zombie = require(ServerScriptService.Zombies.Zombie)

local Gamemode = {}

local zombieTypes

DataStore2.Combine("DATA", "DungeonsPlayed", "LootEarned", "RoomsCleared")

local function getBossLevel()
	if Dungeon.GetDungeonData("Gamemode") == "Boss" then
		return 1
	else
		return Dungeon.GetDungeonData("DifficultyInfo").MinLevel
	end
end

local damagedByBoss = {}

ServerStorage.Events.DamagedByBoss.Event:connect(function(player)
	damagedByBoss[player] = true
end)

function Gamemode.EndMission()
	for _, player in pairs(Players:GetPlayers()) do
		Promise.all({
			GenerateLoot.GenerateSet(player):andThen(function(loot)
				return Promise.async(function(resolve)
					-- TODO: UpdateAsync
					DataStore2("Inventory", player):Update(function(inventory)
						for _, item in pairs(loot) do
							table.insert(inventory, item)
						end

						return inventory
					end)

					-- GenerateLoot.GenerateSet sets the last legendary to 0 if it gets one
					DataStore2("DungeonsSinceLastLegendary", player):Increment(1, 0)

					resolve(Loot.SerializeTable(loot))
				end):tap(function()
					return Promise.async(function(resolve)
						DataStore2("DungeonsPlayed", player):Increment(1, 0)
						DataStore2("LootEarned", player):Increment(#loot, 0)
						DataStore2("RoomsCleared", player):Increment(
							Dungeon.GetDungeonData("DifficultyInfo").Rooms or 0,
							0
						)

						resolve()
					end)
				end)
			end),

			Promise.async(function(resolve)
				local goldScale = player.PlayerData.GoldScale.Value
				local xpScale = player.PlayerData.XPScale.Value

				local difficulty

				if Dungeon.GetDungeonData("Gamemode") == "Boss" then
					local missions = GetAvailableMissions(player)
					local earlierMission

					for index = 2, 0, -1 do
						local nearbyMission = missions[#missions - index]
						if nearbyMission then
							earlierMission = nearbyMission
							break
						end
					end

					difficulty = earlierMission
				else
					difficulty = Dungeon.GetDungeonData("DifficultyInfo")
				end

				local xp = math.floor(difficulty.XP * xpScale)
				local gold = math.floor(difficulty.Gold * goldScale)

				return Promise.all({
					DataStore2("Level", player):Set(player.PlayerData.Level.Value),
					DataStore2("XP", player):Set(player.PlayerData.XP.Value),
					DataStore2("Gold", player):IncrementAsync(gold, 0),
				}):andThen(function()
					resolve({ xp, gold })
				end)
			end),

			Promise.async(function(resolve)
				local zombiePass, zombiePassStore = Data.GetPlayerData(player, "ZombiePass")

				local level = DataStore2("Level", player):Get(1)
				local zombiePassPoints = 1

				if Dungeon.GetDungeonData("Gamemode") == "Mission" then
					local hardestCampaign = 1

					for campaignIndex, campaign in ipairs(Campaigns) do
						if campaign.Difficulties[1].MinLevel <= level then
							hardestCampaign = campaignIndex
						else
							break
						end
					end

					zombiePassPoints = Dungeon.GetDungeonData("Campaign") / hardestCampaign
				end

				zombiePass.XP = zombiePass.XP + zombiePassPoints
				zombiePassStore:Set(zombiePass)

				resolve()
			end)
		}):andThen(function(data)
			if Dungeon.GetDungeonData("Hardcore") then
				GiveQuest:Fire(player, "BeatHardcoreMissions", 1)
			end

			if not damagedByBoss[player] then
				GiveQuest:Fire(player, "DefeatBossWithoutDamage", 1)
			end

			DataStore2.SaveAllAsync(player)

			local loot, xp, gold = data[1], data[2][1], data[2][2]

			ReplicatedStorage.Remotes.MissionOver:FireClient(
				player,
				loot,
				xp,
				gold
			)
		end)
	end

	for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
		if zombie:IsDescendantOf(Workspace) then
			zombie.Humanoid.Health = 0
		end
	end
end

function Gamemode.GetZombieTypes()
	if not zombieTypes then
		zombieTypes = {}
		for key, rate in pairs(Dungeon.GetDungeonData("CampaignInfo").ZombieTypes) do
			assert(
				ServerScriptService.Zombies:FindFirstChild(key),
				"Zombie does not exist, but is in types: " .. key
			)

			for _ = 1, rate do
				table.insert(zombieTypes, key)
			end
		end
	end

	return zombieTypes
end

function Gamemode.SpawnBoss(bossSequence, position, room)
	local bossZombie = Zombie.new("Boss", getBossLevel())

	local model = bossZombie:Spawn(position)
	model:FindFirstChildOfClass("Humanoid").Died:connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				Instance.new("ForceField").Parent = player.Character
			end
		end
	end)

	bossSequence.Start(model):await()
	bossZombie:InitializeBossAI(room)

	return bossZombie
end

function Gamemode.SpawnZombie(zombieType, level, position)
	local zombie = Zombie.new(zombieType, level)
	zombie:Spawn(position)
	return zombie
end

ServerStorage.Events.EndDungeon.Event:connect(Gamemode.EndMission)

return Gamemode
