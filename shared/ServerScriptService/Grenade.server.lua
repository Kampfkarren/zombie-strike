local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Data = require(ReplicatedStorage.Core.Data)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)

local Effect = ReplicatedStorage.RuddevRemotes.Effect
local GiveQuest = ServerStorage.Events.GiveQuest

local BASE_DAMAGE = 65
local BASE_DAMAGE_BETTER = 65 * 1.5
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

local function getDamage(better, level)
	return (better and BASE_DAMAGE_BETTER or BASE_DAMAGE) * DAMAGE_SCALE ^ (level - 1)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local grenadeCooldowns = {}

ReplicatedStorage.Remotes.FireGrenade.OnServerInvoke = function(player)
	local level = player:WaitForChild("PlayerData"):WaitForChild("Level").Value
	local character = player.Character
	if not character or character.Humanoid.Health <= 0 then return end

	local better = GamePasses.PlayerOwnsPass(
		player, GamePassDictionary.BetterEquipment
	)

	if tick() - (grenadeCooldowns[player] or 0) > COOLDOWN then
		grenadeCooldowns[player] = tick()

		local grenade = ReplicatedStorage.Items[
			"Grenade" .. Data.GetPlayerData(
				player,
				"EquippedGrenade"
			)
		]:Clone()

		if better then
			grenade.Trail.Color = ColorSequence.new(Color3.new(1, 1, 0))
			grenade.Trail.WidthScale = NumberSequence.new(10)
		end

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
				MAX_RANGE,
				better
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
							local baseDamage = getDamage(better, level)
							local damage = lerp(baseDamage * DROPOFF, baseDamage, range / maxRange)

							local humanoid = zombie.Humanoid
							if not ReplicatedStorage.HubWorld.Value then
								humanoid:TakeDamage(damage)
								if humanoid.Health <= 0 then
									for _, player in pairs(Players:GetPlayers()) do
										GiveQuest:Fire(player, "KillZombiesGrenade", 1)
									end
								end
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
