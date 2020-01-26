local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Gamemode = require(script.Parent.Gamemode)
local GenerateLoot = require(ServerScriptService.Libraries.GenerateLoot)
local GenerateTreasureLoot = require(ServerScriptService.Libraries.GenerateTreasureLoot)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)
local Zombie = require(ServerScriptService.Zombies.Zombie)

local BossTimer = ReplicatedStorage.BossTimer
local GiveQuest = ServerStorage.Events.GiveQuest
local Rooms = ServerStorage.Rooms

local SPEED_BONUS = 0.33
local SPEED_TIME = 3.5

local Standard = {}

local damagedByBoss = {}

DataStore2.Combine("DATA", "DungeonsPlayed", "LootEarned", "RoomsCleared")

ServerStorage.Events.DamagedByBoss.Event:connect(function(player)
	damagedByBoss[player] = true
end)

local function createRoom(room, parent, connectTo)
	local room = room:Clone()

	if connectTo then
		local front = assert(connectTo:FindFirstChild("Front", true))
		local back = assert(room:FindFirstChild("Back", true))

		room:SetPrimaryPartCFrame(
			-- front.WorldCFrame
			-- + (back.WorldPosition - room.PrimaryPart.Position)
			CFrame.new(front.WorldPosition - back.Position)
		)
	end

	local decor = {}
	for _, thing in pairs(room:GetDescendants()) do
		if CollectionService:HasTag(thing, "Decor") then
			table.insert(decor, thing)
		end
	end

	if #decor > 0 then
		for _ = 1, math.random(#decor * 0.5) do
			table.remove(decor, math.random(#decor)):Destroy()
		end
	end

	room.Parent = parent
	return room
end

local function generateDungeon(roomModels, numRooms)
	local roomTypes = {
		boss = {},
		bossBefore = {},
		enemy = {},
		obby = {},
		treasure = {},
	}

	for _, room in pairs(roomModels:GetChildren()) do
		local obbyType = room:FindFirstChild("ObbyType")
		if obbyType ~= nil then
			local roomTable = assert(roomTypes[obbyType.Value])
			table.insert(roomTable, room)
		end
	end

	local obbyParent = Instance.new("Folder")

	local base = createRoom(roomModels.StartSection, obbyParent)
	DungeonState.CurrentSpawn = base.SpawnLocation
	local nextRoom = base

	local rooms = {}
	local lastRoom = Workspace -- lol

	local halfway = math.floor(numRooms / 2)

	for room = 1, numRooms do
		local treasure = GenerateTreasureLoot:expect()
		if room == halfway and treasure ~= nil then
			local treasures = roomTypes.treasure
			nextRoom = createRoom(treasures[math.random(#treasures)], obbyParent, nextRoom)
			if treasure.Rarity == 5 then
				nextRoom.ChestEpic:Destroy()
			elseif treasure.Rarity == 4 then
				nextRoom.ChestLegendary:Destroy()
			end
			table.insert(rooms, nextRoom)
		end

		local zombies = roomTypes.enemy

		local roomChoice
		repeat
			roomChoice = zombies[math.random(#zombies)]
		until roomChoice.Name ~= lastRoom.Name

		lastRoom = roomChoice
		nextRoom = createRoom(roomChoice, obbyParent, nextRoom)

		table.insert(rooms, nextRoom)
	end

	local bossBeforeRoom = createRoom(roomTypes.bossBefore[1], obbyParent, nextRoom)
	table.insert(rooms, bossBeforeRoom)

	local bossRoom = createRoom(roomTypes.boss[math.random(#roomTypes.boss)], obbyParent, bossBeforeRoom)
	table.insert(rooms, bossRoom)

	obbyParent.Name = "Rooms"
	obbyParent.Parent = Workspace

	return rooms
end

local function endMission()
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
							Dungeon.GetDungeonData("DifficultyInfo").Rooms,
							0
						)

						resolve()
					end)
				end)
			end),

			Promise.async(function(resolve)
				local difficulty = Dungeon.GetDungeonData("DifficultyInfo")

				local goldScale = player.PlayerData.GoldScale.Value
				local xpScale = player.PlayerData.XPScale.Value

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
				local hardestCampaign = 1

				for campaignIndex, campaign in ipairs(Campaigns) do
					if campaign.Difficulties[1].MinLevel <= level then
						hardestCampaign = campaignIndex
					else
						break
					end
				end

				zombiePass.XP = zombiePass.XP + Dungeon.GetDungeonData("Campaign") / hardestCampaign
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

ServerStorage.Events.EndDungeon.Event:connect(endMission)

local function getBossSequence()
	return require(ReplicatedStorage.BossSequences[Dungeon.GetDungeonData("Campaign")])
end

local function spawnBoss(position, room)
	local BossSequence = getBossSequence()

	local bossZombie = Zombie.new("Boss", Dungeon.GetDungeonData("DifficultyInfo").MinLevel)

	local model = bossZombie:Spawn(position)
	model:FindFirstChildOfClass("Humanoid").Died:connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				Instance.new("ForceField").Parent = player.Character
			end
		end
	end)
	bossZombie.Died:connect(endMission)
	BossSequence.Start(model):await()

	bossZombie:InitializeBossAI(room)

	return bossZombie
end

function Standard.Init()
	local rooms = generateDungeon(
		Rooms[Dungeon.GetDungeonData("Campaign")],
		Dungeon.GetDungeonData("DifficultyInfo").Rooms
	)

	local zombieTypes = Gamemode.GetZombieTypes()

	local function startBoss(room)
		DungeonState.CurrentSpawn = assert(room:FindFirstChild("RespawnPoint", true))

		for _, player in pairs(Players:GetPlayers()) do
			FastSpawn(function()
				(player.Character or player.CharacterAdded:wait())
					:MoveTo(DungeonState.CurrentSpawn.WorldPosition)
			end)
		end

		local bossSpawn = room:FindFirstChild("BossSpawn", true)

		spawnBoss(bossSpawn and bossSpawn.WorldPosition, room)
	end

	local function openNextGate()
		local room = table.remove(rooms, 1)
		local gate = assert(room:FindFirstChild("Gate", true), "No Gate")

		local enemiesLeft = room.EnemiesLeft.Value
		local obbyType = room.ObbyType.Value

		local spawnPoint = assert(room:FindFirstChild("RespawnPoint", true), "No RespawnPoint")

		DungeonState.CurrentSpawn = spawnPoint

		if obbyType == "enemy" then
			local zombieSpawns = {}
			for _, thing in pairs(room:GetDescendants()) do
				if CollectionService:HasTag(thing, "ZombieSpawn") then
					table.insert(zombieSpawns, thing)
				end
			end

			local zombies = {}

			for _ = 1, enemiesLeft do
				local spawnPoint = table.remove(zombieSpawns, math.random(#zombieSpawns))
				local zombie = Gamemode.SpawnZombie(
					zombieTypes[math.random(#zombieTypes)],
					Dungeon.RNGZombieLevel(),
					spawnPoint.WorldPosition
				)
				table.insert(zombies, zombie)

				local maxEnemies = enemiesLeft

				zombie.Died:connect(function()
					enemiesLeft = enemiesLeft - 1
					if enemiesLeft == 0 then
						wait(1)
						openNextGate()
					elseif enemiesLeft < maxEnemies / 2 then
						for _, zombie in pairs(zombies) do
							if zombie.alive and zombie.wandering then
								zombie:Aggro()
							end
						end
					end
				end)
			end

			wait(1)
		elseif obbyType == "treasure" then
			delay(4, openNextGate)
		end

		for _, player in pairs(Players:GetPlayers()) do
			local speedMultiplier = player:WaitForChild("SpeedMultiplier")
			speedMultiplier.Value = speedMultiplier.Value + SPEED_BONUS
			delay(SPEED_TIME, function()
				speedMultiplier.Value = speedMultiplier.Value - SPEED_BONUS
			end)
		end

		Debris:AddItem(gate, 4)

		ReplicatedStorage.Remotes.OpenGate:FireAllClients(room)
		Players.PlayerAdded:connect(function(player)
			ReplicatedStorage.Remotes.OpenGate:FireClient(player, room)
		end)

		if obbyType == "bossBefore" then
			for timer = 5, 1, -1 do
				BossTimer.Value = timer
				wait(1)
			end

			BossTimer.Value = 0

			startBoss(rooms[#rooms])
		end
	end

	ServerStorage.Events.ToBoss.Event:connect(function(showSequence)
		ReplicatedStorage.SkipBossSequence.Value = not showSequence

		local room = rooms[#rooms]
		DungeonState.CurrentSpawn = assert(room:FindFirstChild("RespawnPoint", true))
		startBoss(room)
	end)

	local difficultyInfo = Dungeon.GetDungeonData("DifficultyInfo")

	for _, room in pairs(rooms) do
		local zombieSpawns = {}
		for _, thing in pairs(room:GetDescendants()) do
			if CollectionService:HasTag(thing, "ZombieSpawn") then
				table.insert(zombieSpawns, thing)
			end
		end

		local amount = math.ceil(#zombieSpawns * difficultyInfo.ZombieSpawnRate)

		local enemiesLeft = Instance.new("NumberValue")
		enemiesLeft.Name = "EnemiesLeft"
		enemiesLeft.Value = amount
		enemiesLeft.Parent = room

		DungeonState.NormalZombies = DungeonState.NormalZombies + amount
	end

	return {
		Countdown = function(time)
			if time == 2 then
				FastSpawn(openNextGate)
			end
		end,
	}
end

return Standard
