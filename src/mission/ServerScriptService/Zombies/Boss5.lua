local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local ShootFrenzyCircles = ReplicatedStorage.Remotes.WestBoss.ShootFrenzyCircles
local ShootFrenzyLines = ReplicatedStorage.Remotes.WestBoss.ShootFrenzyLines
local ShootFrenzySpin = ReplicatedStorage.Remotes.WestBoss.ShootFrenzySpin

local WestBoss = {}
WestBoss.__index = WestBoss

WestBoss.Name = "The Judge Zombie"
WestBoss.Model = "Boss"

function WestBoss.new()
	return setmetatable({}, WestBoss)
end

function WestBoss.InitializeAI() end

function WestBoss:InitializeBossAI(room)
	self.bossRoom = room

	local function takeFrenzyDamage(player)
		TakeDamage(player, self:GetScale("ShootFrenzyDamage"))
	end

	ShootFrenzyCircles.OnServerEvent:connect(takeFrenzyDamage)
	ShootFrenzyLines.OnServerEvent:connect(takeFrenzyDamage)
	ShootFrenzySpin.OnServerEvent:connect(takeFrenzyDamage)

	wait(1.5)

	local currentSequence = 1

	while self.alive do
		WestBoss.AttackSequence[currentSequence](self)
		currentSequence = (currentSequence % #WestBoss.AttackSequence) + 1
		wait(4)
	end
end

function WestBoss.ShootFrenzyCircles()
	ShootFrenzyCircles:FireAllClients()
end

function WestBoss.ShootFrenzyLines()
	ShootFrenzyLines:FireAllClients()
end

function WestBoss.ShootFrenzySpin()
	ShootFrenzySpin:FireAllClients()
end

function WestBoss:SummonZombies()
	for _ = 1, self:GetScale("SummonCount") do
		self:SummonGoon()
	end
end

WestBoss.AttackSequence = {
	WestBoss.ShootFrenzyCircles,
	WestBoss.ShootFrenzyLines,
	WestBoss.ShootFrenzySpin,
	WestBoss.SummonZombies,
	WestBoss.ShootFrenzyCircles,
	WestBoss.ShootFrenzySpin,
}

return WestBoss
