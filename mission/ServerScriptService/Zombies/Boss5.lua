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

WestBoss.ShootFrenzyDamage = {
	[106] = {
		Base = 22000000,
		Max = 7,
	},

	[112] = {
		Base = 40000000,
		Max = 7.5,
	},

	[118] = {
		Base = 72000000,
		Max = 8,
	},

	[124] = {
		Base = 132000000,
		Max = 8.5,
	},

	[130] = {
		Base = 251000000,
		Max = 9,
	},
}

WestBoss.SummonCount = {
	[106] = 3,
	[112] = 4,
	[118] = 5,
	[124] = 6,
	[130] = 7,
}

function WestBoss.new()
	return setmetatable({}, WestBoss)
end

function WestBoss.InitializeAI() end

function WestBoss:InitializeBossAI(room)
	self.bossRoom = room

	local function takeFrenzyDamage(player)
		local damage = WestBoss.ShootFrenzyDamage[self.level]

		TakeDamage(player, self:GetDamageAgainstConstant(
			player,
			damage.Base,
			damage.Max
		))
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
	for _ = 1, WestBoss.SummonCount[self.level] do
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
