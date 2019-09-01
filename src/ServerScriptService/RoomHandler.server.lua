local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Zombies = ServerScriptService.Zombies

local Zombie = require(Zombies.Zombie)

local Rooms = ServerStorage.Rooms

local roomTypes = {
	boss = {},
	enemy = {},
	obby = {},
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
			front.WorldCFrame
			+ (back.WorldPosition - room.PrimaryPart.Position)
		)
	end

	room.Parent = parent
	return room
end

local function generateDungeon(numRooms)
	local obbyParent = Instance.new("Folder")

	local base = createRoom(Rooms.StartSection, obbyParent)
	local nextRoom = base
	local connectorAngle = 0

	local rooms = {}

	for roomIndex = 1, numRooms do
		-- local obbies = roomTypes.obby
		-- nextRoom = createRoom(obbies[math.random(#obbies)], obbyParent, nextRoom)
		local zombies = roomTypes.enemy
		nextRoom = createRoom(zombies[math.random(#zombies)], obbyParent, nextRoom)
		table.insert(rooms, nextRoom)
	end

	local bossRoom = createRoom(roomTypes.boss[math.random(#roomTypes.boss)], obbyParent, nextRoom)
	table.insert(rooms, bossRoom)

	obbyParent.Parent = Workspace
	return obbyParent, rooms
end

local folder, rooms = generateDungeon(1)

local function spawnZombie(zombieType, position)
	local zombie = Zombie.new(zombieType)
	zombie:Spawn(position)
	return zombie
end

local function spawnBoss(position)
	local bossZombie = Zombie.new("Boss", ServerStorage.Zombies.TestBossZombie, "Common")
	bossZombie:Spawn(position)
	bossZombie.Died:connect(function()
		ReplicatedStorage.Remotes.MissionOver:FireAllClients()
		for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
			if zombie:IsDescendantOf(Workspace) then
				zombie.Humanoid.Health = 0
			end
		end
	end)
	return bossZombie
end

local function openNextGate()
	local room = table.remove(rooms, 1)
	local gate = room:FindFirstChild("Gate", true, "No Gate")

	local enemiesLeft = 0
	local obbyType = room.ObbyType.Value

	if obbyType == "enemy" or obbyType == "boss"then
		for _, thing in pairs(room:GetDescendants()) do
			if CollectionService:HasTag(thing, "ZombieSpawn") then
				enemiesLeft = enemiesLeft + 1
				local zombie = spawnZombie("Turret", thing.WorldPosition)
				zombie.Died:connect(function()
					enemiesLeft = enemiesLeft - 1
					if enemiesLeft == 0 then
						wait(2)
						openNextGate()
					end
				end)
			end
		end
	end

	if obbyType == "boss" then
		local bossSpawn = room:FindFirstChild("BossSpawn", true)
		spawnBoss(bossSpawn.WorldPosition)
	end

	gate:Destroy()
end

wait(3)
openNextGate()
