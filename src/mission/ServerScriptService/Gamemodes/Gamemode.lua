local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Zombie = require(ServerScriptService.Zombies.Zombie)

local Gamemode = {}

local zombieTypes = {}

for key, rate in pairs(Dungeon.GetDungeonData("CampaignInfo").ZombieTypes) do
	assert(
		ServerScriptService.Zombies:FindFirstChild(key),
		"Zombie does not exist, but is in types: " .. key
	)

	for _ = 1, rate do
		table.insert(zombieTypes, key)
	end
end

function Gamemode.GetZombieTypes()
	return zombieTypes
end

function Gamemode.SpawnZombie(zombieType, level, position)
	local zombie = Zombie.new(zombieType, level)
	zombie:Spawn(position)
	return zombie
end

return Gamemode
