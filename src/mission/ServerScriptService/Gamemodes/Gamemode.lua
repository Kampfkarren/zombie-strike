local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Zombie = require(ServerScriptService.Zombies.Zombie)

local Gamemode = {}

local zombieTypes

local function getBossLevel()
	if Dungeon.GetDungeonData("Gamemode") == "Boss" then
		return 1
	else
		return Dungeon.GetDungeonData("DifficultyInfo").MinLevel
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

return Gamemode
