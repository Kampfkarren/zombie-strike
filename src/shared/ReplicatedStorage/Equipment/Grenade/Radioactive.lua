local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Basic = require(script.Parent.Basic)
local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Maid = require(ReplicatedStorage.Core.Maid)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local BASE_DAMAGE = 10
local BASE_DAMAGE_BETTER = 30 * 1.5
local BASE_DPS = 20
local BASE_DPS_BETTER = 20 * 1.5
local DAMAGE_SCALE = 1.13
local MAX_BOSS_RANGE = 100
local MAX_RANGE = 50
local POISON_TIME = 8
local SCALED_BASE_DAMAGE = 0.15
local SCALED_POISON_DAMAGE = 0.09

local Radioactive = {}

Radioactive.Index = 4
Radioactive.Name = "Radioactive Grenade"
Radioactive.Icon = "rbxassetid://4657714533"
Radioactive.Cooldown = 15

Radioactive.ClientEffect = Basic.ClientEffect

local function getDamage(better, level)
	return (better and BASE_DAMAGE_BETTER or BASE_DAMAGE) * DAMAGE_SCALE ^ (level - 1),
		(better and BASE_DPS_BETTER or BASE_DPS) * DAMAGE_SCALE ^ (level - 1)
end

Radioactive.ServerEffect = Basic.CreateServerEffect(
	ReplicatedStorage.Items.Grenade4,
	SoundService.SFX.Prime,
	function(player, grenade, better)
		local level = player:WaitForChild("PlayerData"):WaitForChild("Level").Value
		local maid = Maid.new()

		for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
			if zombie.Humanoid.Health > 0 and zombie:IsDescendantOf(Workspace) then
				local range = (zombie.PrimaryPart.Position - grenade.Position).Magnitude
				if Damage:PlayerCanDamage(player, zombie.Humanoid) then
					local maxRange = CollectionService:HasTag(zombie, "Boss")
						and MAX_BOSS_RANGE
						or MAX_RANGE

					if range <= maxRange then
						local initDamage, dps = getDamage(better, level)
						Basic.DealDamage(player, zombie, initDamage, SCALED_BASE_DAMAGE)

						local emitter = ServerStorage.Assets.PoisonEmitter:Clone()
						emitter.Parent = zombie.PrimaryPart
						maid:GiveTask(emitter)

						maid:GiveTask(RunService.Heartbeat:connect(function(delta)
							if zombie:IsDescendantOf(Workspace) then
								Basic.DealDamage(player, zombie, dps * delta, SCALED_POISON_DAMAGE * delta)
							end
						end))
					end
				end
			end
		end

		RealDelay(POISON_TIME, function()
			maid:DoCleaning()
		end)
	end
)

return Radioactive
