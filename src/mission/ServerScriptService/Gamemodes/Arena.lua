local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ArenaConstants = require(ReplicatedStorage.Core.ArenaConstants)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local ExperienceUtil = require(ServerScriptService.Libraries.ExperienceUtil)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Gamemode = require(script.Parent.Gamemode)
local GenerateLoot = require(ServerScriptService.Libraries.GenerateLoot)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Loot = require(ReplicatedStorage.Core.Loot)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local ArenaRemotes = ReplicatedStorage.Remotes.Arena
local GiveQuest = ServerStorage.Events.GiveQuest

local Arena = {}

local BADGE = 2124497452
local LOOT_EQUIPMENT_RATE = 0.05
local LOOT_ROUNDS = 5
local SPECIAL_ZOMBIE_RATE = 0.05
local SPECIAL_ZOMBIES_IN_FIELD = 5
local XP_BASE = 57
local XP_SCALE = 1.145
local ZOMBIES_FIRST_WAVE = 7
local ZOMBIES_PER_WAVE = 1
local ZOMBIES_IN_FIELD = 17

local rng = Random.new()

DataStore2.Combine("DATA", "LootEarned")

local function spawnArena()
	local rooms = Instance.new("Folder")
	rooms.Name = "Rooms"

	local model = ServerStorage.Arenas[Dungeon.GetDungeonData("Campaign")]
	model.Name = "StartSection"
	model.Parent = rooms

	rooms.Parent = Workspace

	return model
end

local function getSpecialZombieTypes()
	local zombieTypes = {}

	for _, zombieType in pairs(Dungeon.GetDungeonData("CampaignInfo").SpecialZombies) do
		if not ArenaConstants.BannedZombies[zombieType] then
			table.insert(zombieTypes, zombieType)
		end
	end

	return zombieTypes
end

local function getZombieTypes()
	local zombieTypes = {}

	for _, zombieType in pairs(Gamemode.GetZombieTypes()) do
		if not ArenaConstants.BannedZombies[zombieType] then
			table.insert(zombieTypes, zombieType)
		end
	end

	return zombieTypes
end

local function spawnZombie(zombieTypes, zombieSpawns, level)
	local zombie = Gamemode.SpawnZombie(
		zombieTypes[math.random(#zombieTypes)],
		level,
		zombieSpawns[math.random(#zombieSpawns)].WorldPosition
	)

	zombie.GetXP = function()
		return 0
	end

	FastSpawn(function()
		zombie:Aggro()
	end)

	return zombie
end

function Arena.Init()
	local model = spawnArena()
	DungeonState.CurrentSpawn = model:FindFirstChild("SpawnLocation", true)

	local zombieSpawns = {}
	for _, zombieSpawn in pairs(CollectionService:GetTagged("ZombieSpawn")) do
		if zombieSpawn:IsDescendantOf(model) then
			table.insert(zombieSpawns, zombieSpawn)
		end
	end

	local currentWave = Dungeon.GetDungeonData("ArenaLevel")

	local nextWave = Instance.new("BindableEvent")

	local function generateLootFor(player)
		local loot

		if rng:NextNumber() <= LOOT_EQUIPMENT_RATE then
			loot = GenerateLoot.GenerateEquipment(player):awaitValue()
		end

		if loot == nil then
			loot = GenerateLoot.GenerateOne(player)
			loot.Level = math.min(Data.GetPlayerData(player, "Level"), currentWave)
			DataStore2("LootEarned", player):IncrementAsync(1, 0)
		end

		return loot
	end

	local function startWave()
		if currentWave % LOOT_ROUNDS == 0 and currentWave ~= Dungeon.GetDungeonData("ArenaLevel") then
			for _, player in pairs(Players:GetPlayers()) do
				local loot = generateLootFor(player)
				ArenaRemotes.NewWave:FireClient(player, currentWave, loot)
				FastSpawn(function()
					BadgeService:AwardBadge(player.UserId, BADGE)
				end)

				if Loot.IsEquipment(loot) then
					DataStore2("Equipment", player):Update(function(equipment)
						table.insert(equipment[loot.Type], loot.Index)
						return equipment
					end)
				else
					local inventorySpace = InventorySpace(player):awaitValue()
					DataStore2("Inventory", player):Update(function(inventory)
						if #inventory < inventorySpace then
							table.insert(inventory, loot)
						end

						return inventory
					end)
				end
			end
		else
			ArenaRemotes.NewWave:FireAllClients(currentWave)
		end

		local summonCount = ZOMBIES_FIRST_WAVE + (ZOMBIES_PER_WAVE * currentWave)
		local specialZombiesAlive = 0

		local running = coroutine.running()

		for index = 1, summonCount do
			if index > ZOMBIES_IN_FIELD then
				coroutine.yield()
			end

			local isSpecial, zombieTypes

			if specialZombiesAlive < SPECIAL_ZOMBIES_IN_FIELD
				and rng:NextNumber() <= SPECIAL_ZOMBIE_RATE
			then
				specialZombiesAlive = specialZombiesAlive + 1
				zombieTypes = getSpecialZombieTypes()
				isSpecial = true
			else
				zombieTypes = getZombieTypes()
			end

			local zombie = spawnZombie(zombieTypes, zombieSpawns, currentWave)
			zombie.Died:connect(function()
				summonCount = summonCount - 1

				if coroutine.status(running) == "suspended" then
					coroutine.resume(running)
				end

				if isSpecial then
					specialZombiesAlive = specialZombiesAlive - 1
				end

				if summonCount == 0 then
					for _, player in pairs(Players:GetPlayers()) do
						local level = math.min(
							currentWave,
							player
								:WaitForChild("PlayerData")
								:WaitForChild("Level")
								.Value
						)

						local xpGain = math.floor(XP_BASE * XP_SCALE ^ (level - 1))

						local character = player.Character
						ExperienceUtil.GivePlayerXP(player, xpGain, character and character.PrimaryPart)

						DataStore2("Level", player):Set(player.PlayerData.Level.Value)
						DataStore2("XP", player):Set(player.PlayerData.XP.Value)

						local character = player.Character
						if character and character.Humanoid.Health > 0 then
							GiveQuest:Fire(player, "ArenaWaves", 1)
						end
					end

					nextWave:Fire()
				end
			end)
		end
	end

	nextWave.Event:connect(function()
		RealDelay(3, function()
			currentWave = currentWave + 1
			startWave()
		end)
	end)

	return {
		Countdown = function(timer)
			if timer == 1 then
				FastSpawn(startWave)
			end
		end,

		Scales = function()
			return false
		end,
	}
end

return Arena
