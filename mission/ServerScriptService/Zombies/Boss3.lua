local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ChargeBigLaser = ReplicatedStorage.Remotes.FirelandsBoss.ChargeBigLaser
local TriLaser = ReplicatedStorage.Remotes.FirelandsBoss.TriLaser

local SummonSpot = ReplicatedStorage.Assets.Campaign.Campaign3.Boss.SummonSpot

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)
local Zombie = require(script.Parent.Zombie)

local SUMMON_DELAY = 2
local SUMMON_INTERVAL = 0.3
local TRI_LASER_COUNT = 4
local TRI_LASER_MOVE_DELAY = 0.5
local TRI_LASER_TIME = 3
local TRI_LASER_WINDUP = 0.9

local FirelandsBoss = {}
FirelandsBoss.__index = FirelandsBoss

FirelandsBoss.MassiveLaserDamage = {
	[60] = 300000,
	[64] = 550000,
	[68] = 875000,
	[72] = 1500000,
}

FirelandsBoss.MassiveLaserWindup = {
	[60] = 4,
	[64] = 3.6,
	[68] = 3.2,
	[72] = 2.8,
}

FirelandsBoss.SummonCount = {
	[60] = 3,
	[64] = 4,
	[68] = 5,
	[72] = 6,
}

FirelandsBoss.TriLaserDamage = {
	[60] = 210000,
	[64] = 350000,
	[68] = 630000,
	[72] = 1120000,
}

function FirelandsBoss.new()
	return setmetatable({
		zombiesSummoned = {},
	}, FirelandsBoss)
end

function FirelandsBoss.GetModel()
	return assert(Workspace:FindFirstChild("Fire Elemental Zombie", true))
end

function FirelandsBoss:InitializeBossAI(room)
	self.bossRoom = room
	self:NewSpot()
	CollectionService:AddTag(self.instance, "Zombie")

	local currentSequence = math.random(#FirelandsBoss.AttackSequence)

	ChargeBigLaser.OnServerEvent:connect(function(player)
		TakeDamage(player, FirelandsBoss.MassiveLaserDamage[self.level])
	end)

	TriLaser.OnServerEvent:connect(function(player)
		TakeDamage(player, FirelandsBoss.TriLaserDamage[self.level])
	end)

	wait(1.5)

	while self.alive do
		FirelandsBoss.AttackSequence[currentSequence](self)
		currentSequence = (currentSequence % #FirelandsBoss.AttackSequence) + 1
		wait(1)
	end
end

function FirelandsBoss:Spawn()
	self:AfterSpawn()
	self:SetupHumanoid()
	return self.instance
end

function FirelandsBoss:NewSpot()
	local moveSpots = self.bossRoom.MoveSpots:GetChildren()
	self.instance.NextPosition.Value = moveSpots[math.random(#moveSpots)]
end

function FirelandsBoss:BigLaser()
	self:NewSpot()
	ChargeBigLaser:FireAllClients(true)
	wait(FirelandsBoss.MassiveLaserWindup[self.level])
	ChargeBigLaser:FireAllClients(false)
end

function FirelandsBoss:TriLaser()
	for _ = 1, TRI_LASER_COUNT do
		self:NewSpot()
		wait(TRI_LASER_MOVE_DELAY)
		TriLaser:FireAllClients(true)
		wait(TRI_LASER_TIME)
		TriLaser:FireAllClients(false)
		wait(TRI_LASER_WINDUP)
	end
end

function FirelandsBoss:SummonZombies()
	local parts = {}

	for _ = 1, FirelandsBoss.SummonCount[self.level] do
		local spot = SummonSpot:Clone()
		local zombieSummonPart = self.bossRoom.ZombieSummon
		local sizeX, sizeZ = zombieSummonPart.Size.X, zombieSummonPart.Size.Z

		local position = zombieSummonPart.Position + Vector3.new(
			math.random(-sizeX / 2, sizeX / 2),
			spot.Position.Y + spot.Size.X / 2 - 3,
			math.random(-sizeZ / 2, sizeZ / 2)
		)

		spot.Position = position
		spot.Parent = Workspace

		table.insert(parts, spot)
	end

	local campaignInfo = Dungeon.GetDungeonData("CampaignInfo")

	local zombieTypes = {}

	for zombieType in pairs(campaignInfo.ZombieTypes) do
		table.insert(zombieTypes, zombieType)
	end

	wait(SUMMON_DELAY)

	for _, part in ipairs(parts) do
		part.Transparency = 1

		local zombie = Zombie.new(
			zombieTypes[math.random(#zombieTypes)],
			Dungeon.RNGZombieLevel()
		)

		table.insert(self.zombiesSummoned, zombie)

		zombie.Died:connect(function()
			for index, otherZombie in pairs(self.zombiesSummoned) do
				if otherZombie == zombie then
					table.remove(self.zombiesSummoned, index)
				end
			end
		end)

		zombie.GetXP = function()
			return 0
		end

		zombie:Spawn(part.Position)
		zombie:Aggro()

		Debris:AddItem(part)
		wait(SUMMON_INTERVAL)
	end
end

function FirelandsBoss.UpdateNametag() end

FirelandsBoss.AttackSequence = {
	FirelandsBoss.BigLaser,
	FirelandsBoss.TriLaser,
	FirelandsBoss.SummonZombies,
}

return FirelandsBoss
