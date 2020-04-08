local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Zombie = require(script.Parent.Zombie)

local HEALTH_PER_PLAYER = 0.23
local XP_AMOUNT_FOR_BOSS = 0.3

local Boss = {}
Boss.__index = Boss

local function getIdentifier()
	if Dungeon.GetDungeonData("Gamemode") == "Boss" then
		return Dungeon.GetDungeonData("BossInfo").RoomName
	else
		return Dungeon.GetDungeonData("Campaign")
	end
end

function Boss.new(level)
	local derivative = Zombie.new(
		"Boss" .. getIdentifier(),
		level
	)

	return setmetatable({
		_derivative = derivative,
	}, {
		__index = function(_, key)
			return Boss[key] or derivative[key]
		end,
	})
end

function Boss:AfterSpawn()
	CollectionService:AddTag(self.instance, "Boss")
	if self._derivative.AfterSpawn then
		self._derivative.AfterSpawn(self)
	end
end

function Boss:GetDamageReceivedScale()
	-- Balanced around:
	-- f(1) = 0.0055
	-- f(2) = 0.0037
	-- 3 and 4 UNTESTED
	if Dungeon.GetDungeonData("Gamemode") == "Boss" then
		local playerCount = #Players:GetPlayers()

		if playerCount == 1 then
			return 0.0055
		elseif playerCount == 2 then
			return 0.0037
		elseif playerCount == 3 then
			return 0.0019
		elseif playerCount == 4 then
			return 0.0015
		else
			return 0
		end
	else
		return self._derivative.GetDamageReceivedScale(self)
	end
end

function Boss:GetHealth()
	local bossStats = Dungeon.GetDungeonData("DifficultyInfo").BossStats

	if DungeonState.CurrentGamemode.Scales() then
		return 100
	end

	local health

	if bossStats ~= nil then
		health = bossStats.Health
	else
		health = Zombie.GetHealth(self)
	end

	health = health * (1 + HEALTH_PER_PLAYER * (#Players:GetPlayers() - 1))

	return health
end

function Boss:GetSpeed()
	local bossStats = Dungeon.GetDungeonData("DifficultyInfo").BossStats
	if bossStats then
		return bossStats.Speed
	else
		return Zombie.GetSpeed(self)
	end
end

function Boss.GetXP()
	return Dungeon.GetDungeonData("DifficultyInfo").XP * XP_AMOUNT_FOR_BOSS
end

function Boss:UpdateNametag()
	if self._derivative.UpdateNametag then
		return self._derivative.UpdateNametag(self)
	end

	local super = Zombie.UpdateNametag(self)
	super.Size = UDim2.new(40, 0, 10, 0)
	return super
end

function Boss:SummonGoon(callback, forceType)
	local zombieSummon = self.bossRoom.ZombieSummon
	local basePosition = zombieSummon.Position
	local sizeX, sizeZ = zombieSummon.Size.X, zombieSummon.Size.Z

	if not self.alive then return end

	local x = math.random(-sizeX / 2, sizeX / 2)
	local z = math.random(-sizeZ / 2, sizeZ / 2)

	local position = basePosition + Vector3.new(x, 0, z)

	local campaignInfo = Dungeon.GetDungeonData("CampaignInfo")

	local zombieType = forceType

	if zombieType == nil then
		local zombieTypes = {}

		for zombieType in pairs(campaignInfo.ZombieTypes) do
			table.insert(zombieTypes, zombieType)
		end

		zombieType = zombieTypes[math.random(#zombieTypes)]
	end

	local zombie = Zombie.new(zombieType, Dungeon.RNGZombieLevel())

	zombie.GetXP = function()
		return 0
	end

	zombie:Spawn(position)
	zombie:Aggro()

	if callback then
		FastSpawn(function()
			callback(zombie)
		end)
	end
end

return Boss
