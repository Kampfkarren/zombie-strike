local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Zombie = require(script.Parent.Zombie)

local CityBoss = {}
CityBoss.__index = CityBoss

CityBoss.Name = "Master Chief"
CityBoss.Model = "Boss"

function CityBoss.new()
	return setmetatable({}, CityBoss)
end

function CityBoss:AfterSpawn()
	local instance = self.instance
	instance.PrimaryPart.Anchored = true
end

function CityBoss:InitializeAI()
end

function CityBoss:InitializeBossAI(room)
	self.bossRoom = room

	while true do
		self:SummonZombies()
		wait(3)
	end
end

-- TODO: Cap zombies
function CityBoss:SummonZombies()
	print("summoning zombies")

	local amountToSummon = 5 + math.floor(self.level / 6) * 2
	local zombieSummon = self.bossRoom.ZombieSummon
	local basePosition = zombieSummon.Position
	local sizeX, sizeZ = zombieSummon.Size.X, zombieSummon.Size.Z

	for _ = 1, amountToSummon do
		delay(math.random(30, 100) / 60, function()
			local x = math.random(-sizeX / 2, sizeX / 2)
			local z = math.random(-sizeZ / 2, sizeZ / 2)

			local position = basePosition + Vector3.new(x, 0, z)

			local zombie = Zombie.new("Common", Dungeon.RNGZombieLevel())
			zombie.GetXP = function() return 0 end
			zombie:Spawn(position)
			zombie:Aggro()
		end)
	end
end

return CityBoss
