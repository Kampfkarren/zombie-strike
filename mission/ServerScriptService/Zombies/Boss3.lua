local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ChargeBigLaser = ReplicatedStorage.Remotes.FirelandsBoss.ChargeBigLaser
local TriLaser = ReplicatedStorage.Remotes.FirelandsBoss.TriLaser

local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

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

FirelandsBoss.TriLaserDamage = {
	[60] = 210000,
	[64] = 350000,
	[68] = 630000,
	[72] = 1120000,
}

function FirelandsBoss.new()
	return setmetatable({
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

function FirelandsBoss.UpdateNametag() end

FirelandsBoss.AttackSequence = {
	FirelandsBoss.BigLaser,
	FirelandsBoss.TriLaser,
}

return FirelandsBoss
