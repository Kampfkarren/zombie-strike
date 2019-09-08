local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Zombies = ServerScriptService.Zombies

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Libraries.Data)
local DungeonState = require(ServerScriptService.DungeonState)
local GunScaling = require(ReplicatedStorage.Libraries.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local Zombie = require(Zombies.Zombie)

local Rooms = ServerStorage.Rooms

local difficultyInfo

local roomTypes = {
	boss = {},
	enemy = {},
	obby = {},
}

local WEAPON_DROP_RATE = 0.67

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

	room.Parent = parent
	return room
end

local function generateDungeon(numRooms)
	local obbyParent = Instance.new("Folder")

	local base = createRoom(Rooms.StartSection, obbyParent)
	local nextRoom = base

	local rooms = {}

	for _ = 1, numRooms do
		-- local obbies = roomTypes.obby
		-- nextRoom = createRoom(obbies[math.random(#obbies)], obbyParent, nextRoom)
		local zombies = roomTypes.enemy
		nextRoom = createRoom(zombies[math.random(#zombies)], obbyParent, nextRoom)
		table.insert(rooms, nextRoom)
	end

	local bossRoom = createRoom(roomTypes.boss[math.random(#roomTypes.boss)], obbyParent, nextRoom)
	table.insert(rooms, bossRoom)

	obbyParent.Parent = Workspace
	return rooms
end

local rooms = generateDungeon(5)

local function spawnZombie(zombieType, level, position)
	local zombie = Zombie.new(zombieType, level)
	zombie:Spawn(position)
	return zombie
end

local function generateLoot(player)
	local rng = Random.new()

	local currentLevel = player.PlayerData.Level.Value
	local level = currentLevel
	if level > 5 then
		level = level - rng:NextInteger(0, 2)
	end

	local rarityRng = rng:NextNumber() * 100
	local rarity

	-- Numbers are cumulative sums
	if rarityRng <= 0.1 then
		rarity = 5
	elseif rarityRng <= 5 then
		rarity = 4
	elseif rarityRng <= 20 then
		rarity = 3
	elseif rarityRng <= 40 then
		rarity = 2
	else
		rarity = 1
	end

	local lootTable = {}
	local uuid = HttpService:GenerateGUID(false):gsub("-", "")

	if rng:NextNumber() <= WEAPON_DROP_RATE then
		local type = GunScaling.RandomType()

		local stats = GunScaling.BaseStats(type, level, rarity)

		local funny = rng:NextInteger(0, 35)
		stats.Damage = math.floor(stats.Damage * (1 + funny / 35))

		local quality
		if funny <= 4 then
			quality = "Average"
		elseif funny <= 9 then
			quality = "Superior"
		elseif funny <= 14 then
			quality = "Choice"
		elseif funny <= 19 then
			quality = "Valuable"
		elseif funny <= 24 then
			quality = "Great"
		elseif funny <= 29 then
			quality = "Ace"
		elseif funny <= 34 then
			quality = "Extraordinary"
		else
			quality = "Perfect"
		end

		local loot = {
			Type = type,
			CritChance = stats.CritChance,
			Damage = stats.Damage,
			FireRate = stats.FireRate,
			Level = level,
			Magazine = stats.Magazine,
			Model = GunScaling.Model(type, rarity),
			Name = quality .. " Poopoo",
			Rarity = rarity,
			UUID = uuid,
		}

		table.insert(lootTable, loot)
	else
		local type, model

		if rng:NextNumber() >= 0.5 then
			-- type = "Armor"
			type = "Helmet"
		else
			type = "Helmet"
		end

		model = ArmorScaling.Model(type, rarity)

		table.insert(lootTable, {
			Level = level,
			Name = "Poopy",
			Rarity = rarity,
			Type = type,

			Model = model,
			UUID = uuid,
		})
	end

	return Loot.SerializeTable(lootTable)
end

local function endMission()
	for _, player in pairs(Players:GetPlayers()) do
		local loot = generateLoot(player)
		ReplicatedStorage.Remotes.MissionOver:FireClient(player, loot, 999, 999)
	end

	for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
		if zombie:IsDescendantOf(Workspace) then
			zombie.Humanoid.Health = 0
		end
	end
end

local function spawnBoss(position)
	local bossZombie = Zombie.new("Boss", 1, ServerStorage.Zombies.TestBossZombie, "Common")
	bossZombie:Spawn(position)
	bossZombie.Died:connect(endMission)
	return bossZombie
end

ServerStorage.Events.EndDungeon.Event:connect(endMission)

local function openNextGate()
	local room = table.remove(rooms, 1)
	local gate = room:FindFirstChild("Gate", true, "No Gate")

	local enemiesLeft = room.EnemiesLeft.Value
	local obbyType = room.ObbyType.Value

	if obbyType == "enemy" or obbyType == "boss" then
		local zombieSpawns = {}
		for _, thing in pairs(room:GetDescendants()) do
			if CollectionService:HasTag(thing, "ZombieSpawn") then
				table.insert(zombieSpawns, thing)
			end
		end

		for _ = 1, enemiesLeft do
			local spawnPoint = table.remove(zombieSpawns, math.random(#zombieSpawns))
			local zombie = spawnZombie("Common", 1, spawnPoint.WorldPosition)
			zombie.Died:connect(function()
				enemiesLeft = enemiesLeft - 1
				if enemiesLeft == 0 then
					wait(2)
					openNextGate()
				end
			end)
		end
	end

	if obbyType == "boss" then
		local bossSpawn = room:FindFirstChild("BossSpawn", true)
		spawnBoss(bossSpawn.WorldPosition)
	end

	gate:Destroy()
end

difficultyInfo = Data.GetDungeonData("DifficultyInfo")

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

wait(3)
openNextGate()
