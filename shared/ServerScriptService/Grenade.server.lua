local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Data = require(ReplicatedStorage.Core.Data)

local Effect = ReplicatedStorage.RuddevRemotes.Effect

local BASE_DAMAGE = 65
local DAMAGE_SCALE = 1.13

local COOLDOWN = 10
local DROPOFF = 0.5
local MAX_BOSS_RANGE = 100
local MAX_RANGE = 50
local PHYSICAL_PROPERTIES = PhysicalProperties.new(
	0.01, -- density
	0.1, -- friction
	0.7, -- elasticity
	0.1, -- friction weight
	5 -- elasticity weight
)
local PRIME = 1
local SOUNDS = SoundService.SFX.Explosion:GetChildren()

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

		local primeSound = SoundService.SFX.Prime:Clone()
		primeSound.Parent = grenade
		primeSound:Play()

		ReplicatedStorage.Remotes.GrenadeCooldown:FireClient(player)

		delay(PRIME, function()
			primeSound:Destroy()
			grenade.Anchored = true
			grenade.Transparency = 1
			Debris:AddItem(grenade)

			Effect:FireAllClients(
				"Explosion",
				grenade.Position,
				MAX_RANGE
			)

			local sound = SOUNDS[math.random(#SOUNDS)]:Clone()
			sound.Parent = grenade
			sound:Play()

			for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
				if zombie.Humanoid.Health > 0 and zombie:IsDescendantOf(Workspace) then
					local range = (zombie.PrimaryPart.Position - grenade.Position).Magnitude
					if Damage:PlayerCanDamage(player, zombie.Humanoid) then
						local maxRange = CollectionService:HasTag(zombie, "Boss")
							and MAX_BOSS_RANGE
							or MAX_RANGE

						if range <= maxRange then
							local baseDamage = getDamage(level)
							local damage = lerp(baseDamage * DROPOFF, baseDamage, range / maxRange)

							local humanoid = zombie.Humanoid
							if not ReplicatedStorage.HubWorld.Value then
								humanoid:TakeDamage(damage)
							end
							ReplicatedStorage.RuddevEvents.Damaged:Fire(humanoid, damage, player)
							ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage)
						end
					end
				end
			end
		end)

		return grenade
	end
end
