local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Zombies = ServerScriptService.Zombies

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local GenerateLoot = require(ServerScriptService.Libraries.GenerateLoot)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)
local Zombie = require(Zombies.Zombie)

local BossTimer = ReplicatedStorage.BossTimer
local JoinTimer = ReplicatedStorage.JoinTimer
local Rooms = ServerStorage.Rooms

DataStore2.Combine("DATA", "Gold", "Inventory", "Level", "XP")

local difficultyInfo

local roomTypes = {
	boss = {},
	bossBefore = {},
	enemy = {},
	obby = {},
	treasure = {},
}

for _, room in pairs(Rooms:GetChildren()) do
	local obbyType = room:FindFirstChild("ObbyType")
	if obbyType ~= nil then
		local roomTable = assert(roomTypes[obbyType.Value])
		table.insert(roomTable, room)
	end
end

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

local function generateDungeon(numRooms)
	local obbyParent = Instance.new("Folder")

	local base = createRoom(Rooms.StartSection, obbyParent)
	DungeonState.CurrentSpawn = base.SpawnLocation
	local nextRoom = base

	local rooms = {}

	for _ = 1, numRooms do
		-- local obbies = roomTypes.obby
		-- nextRoom = createRoom(obbies[math.random(#obbies)], obbyParent, nextRoom)
		local zombies = roomTypes.enemy
		nextRoom = createRoom(zombies[math.random(#zombies)], obbyParent, nextRoom)
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

local rooms = generateDungeon(Dungeon.GetDungeonData("DifficultyInfo").Rooms)
local zombieTypes = {}

for key, rate in pairs(Dungeon.GetDungeonData("CampaignInfo").ZombieTypes) do
	assert(Zombies:FindFirstChild(key), "Zombie does not exist, but is in types: " .. key)
	for _ = 1, rate do
		table.insert(zombieTypes, key)
	end
end

local function spawnZombie(zombieType, level, position)
	local zombie = Zombie.new(zombieType, level)
	zombie:Spawn(position)
	return zombie
end

local function endMission()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			Instance.new("ForceField", player.Character)
		end

		Promise.all({
			GenerateLoot(player):andThen(function(loot)
				return Promise.async(function(resolve)
					-- TODO: UpdateAsync
					DataStore2("Inventory", player):Update(function(inventory)
						for _, item in pairs(loot) do
							table.insert(inventory, item)
						end

						return inventory
					end)

					resolve(Loot.SerializeTable(loot))
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
					DataStore2("DungeonsPlayed", player):IncrementAsync(1),
				}):andThen(function()
					resolve({ xp, gold })
				end)
			end),
		}):andThen(function(data)
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
	bossZombie.Died:connect(endMission)
	BossSequence.Start(model):await()

	bossZombie:InitializeBossAI(room)

	return bossZombie
end

local function startBoss(room)
	DungeonState.CurrentSpawn = assert(room:FindFirstChild("RespawnPoint", true))

	for _, player in pairs(Players:GetPlayers()) do
		-- TODO: Does this spawn them on top of each other?
		coroutine.wrap(function()
			(player.Character or player.CharacterAdded:wait())
				:MoveTo(DungeonState.CurrentSpawn.WorldPosition)
		end)()
	end

	local bossSpawn = room:FindFirstChild("BossSpawn", true)

	spawnBoss(bossSpawn.WorldPosition, room)
end

ServerStorage.Events.ToBoss.Event:connect(function(showSequence)
	ReplicatedStorage.SkipBossSequence.Value = not showSequence

	local room = rooms[#rooms]
	DungeonState.CurrentSpawn = assert(room:FindFirstChild("RespawnPoint", true))
	startBoss(room)
end)

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
			local zombie = spawnZombie(
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

difficultyInfo = Dungeon.GetDungeonData("DifficultyInfo")

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

local started = 0
local startedCountdown = false

local function start()
	if started == 2 then return end
	started = 2

	for countdown = -3, -1 do
		JoinTimer.Value = countdown
		if countdown == -2 then
			coroutine.wrap(openNextGate)()
		end

		wait(1)
	end

	JoinTimer.Value = -4

	local playMusicFlag = Instance.new("Model")
	playMusicFlag.Name = "PlayMissionMusic"
	playMusicFlag.Parent = ReplicatedStorage

	delay(3, function()
		JoinTimer.Value = 0
	end)
end

local function checkCharacterCount()
	if started ~= 0 then return end

	local characterCount = 0
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			characterCount = characterCount + 1
		end
	end

	if characterCount == #Dungeon.GetDungeonData("Members") then
		print("all players connected")
		started = 1
		JoinTimer.Value = 0
		wait(5)
		start()
		return
	end
end

local function playerAdded(player)
	if started ~= 0 then return end

	checkCharacterCount()
	player.CharacterAdded:connect(checkCharacterCount)

	if not startedCountdown then
		startedCountdown = true

		coroutine.wrap(function()
			for time = 30, 1, -1 do
				if started ~= 0 then return end
				JoinTimer.Value = time
				wait(1)
			end

			start()
		end)()
	end
end

for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

Players.PlayerAdded:connect(playerAdded)
