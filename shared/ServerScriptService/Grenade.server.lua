local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Data = require(ReplicatedStorage.Core.Data)

local Effect = ReplicatedStorage.RuddevRemotes.Effect

local BASE_DAMAGE = 65
local DAMAGE_SCALE = 1.13

local COOLDOWN = 10
local DROPOFF = 0.5
local HEAL_AMOUNT = 0.3
local MAX_RANGE = 50
local PHYSICAL_PROPERTIES = PhysicalProperties.new(
	0.01, -- density
	0.1, -- friction
	0.7, -- elasticity
	0.1, -- friction weight
	5 -- elasticity weight
)
local PRIME = 1

local function getDamage(level)
	return BASE_DAMAGE * DAMAGE_SCALE ^ (level - 1)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local grenadeCooldowns = {}

ReplicatedStorage.Remotes.FireGrenade.OnServerInvoke = function(player)
	local level = player:WaitForChild("PlayerData"):WaitForChild("Level").Value
	local character = player.Character
	if not character or character.Humanoid.Health <= 0 then return end

	if tick() - (grenadeCooldowns[player] or 0) > COOLDOWN then
		grenadeCooldowns[player] = tick()

		local grenade = ReplicatedStorage.Items[
			"Grenade" .. Data.GetPlayerData(
				player,
				"EquippedGrenade"
			)
		]:Clone()

		PhysicsService:SetPartCollisionGroup(grenade, "Grenade")
		grenade.CustomPhysicalProperties = PHYSICAL_PROPERTIES
		grenade.Parent = Workspace
		grenade:SetNetworkOwner(player)

		ReplicatedStorage.Remotes.GrenadeCooldown:FireClient(player)

		delay(PRIME, function()
			grenade.Anchored = true
			grenade.Transparency = 1
			Debris:AddItem(grenade)

			Effect:FireAllClients(
				"Explosion",
				grenade.Position,
				MAX_RANGE
			)

			for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
				local range = (zombie.PrimaryPart.Position - grenade.Position).Magnitude
				if Damage:PlayerCanDamage(player, zombie.Humanoid) then
					if range <= MAX_RANGE then
						local baseDamage = getDamage(level)
						local damage = lerp(baseDamage * DROPOFF, baseDamage, range / MAX_RANGE)

						local humanoid = zombie.Humanoid
						humanoid:TakeDamage(damage)
						ReplicatedStorage.RuddevEvents.Damaged:Fire(humanoid, damage, player)
						ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage)
					end
				end
			end
		end)

		return grenade
	end
end
