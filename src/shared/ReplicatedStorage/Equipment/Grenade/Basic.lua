local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Mouse = require(ReplicatedStorage.RuddevModules.Mouse)
local Promise = require(ReplicatedStorage.Core.Promise)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local Effect = ReplicatedStorage.RuddevRemotes.Effect
local LocalPlayer = Players.LocalPlayer

local BASE_DAMAGE = 65
local BASE_DAMAGE_BETTER = 65 * 1.5
local DAMAGE_SCALE = 1.13

local DROPOFF = 0.5
local GRENADE_SPEED = 50
local MAX_BOSS_RANGE = 100
local MAX_RANGE = 50
local PRIME = 1
local SOUNDS = SoundService.SFX.Explosion:GetChildren()

local function getDamage(better, level)
	return (better and BASE_DAMAGE_BETTER or BASE_DAMAGE) * DAMAGE_SCALE ^ (level - 1)
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local Grenade = {}

Grenade.Index = 1
Grenade.Name = "Grenade"
Grenade.Icon = "http://www.roblox.com/asset/?id=4462345016"
Grenade.Cooldown = 10

Grenade.DefaultPhysicalProperties = PhysicalProperties.new(
	0.01, -- density
	0.1, -- friction
	0.7, -- elasticity
	0.1, -- friction weight
	5 -- elasticity weight
)

function Grenade.DealDamage(player, zombie, damage)
	local GiveQuest = ServerStorage.Events.GiveQuest

	local humanoid = zombie.Humanoid
	if humanoid.Health <= 0 then return end

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

function Grenade.CreateServerEffect(grenade, primeSound, callback)
	return function(player)
		return Promise.new(function(resolve)
			local character = player.Character
			if not character or character.Humanoid.Health <= 0 then return end

			local better = GamePasses.PlayerOwnsPass(
				player, GamePassDictionary.BetterEquipment
			)

			local grenade = grenade:Clone()

			if better then
				grenade.Trail.Color = ColorSequence.new(Color3.new(1, 1, 0))
				grenade.Trail.WidthScale = NumberSequence.new(10)
			end

			PhysicsService:SetPartCollisionGroup(grenade, "Grenade")
			grenade.CustomPhysicalProperties = Grenade.DefaultPhysicalProperties
			grenade.Parent = Workspace
			grenade:SetNetworkOwner(player)

			local primeSound = primeSound:Clone()
			primeSound.Parent = grenade
			primeSound:Play()

			RealDelay(PRIME, function()
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

				callback(player, grenade, better)
			end)

			resolve(grenade)
		end)
	end
end

function Grenade.ClientEffect(grenade)
	if not grenade then
		warn("no grenade")
		return false
	end

	local primaryCFrame = LocalPlayer.Character.PrimaryPart.CFrame
	grenade.CFrame = primaryCFrame + primaryCFrame.RightVector

	local unit

	if UserInputService.MouseEnabled then
		unit = (Mouse.WorldPosition - LocalPlayer.Character.PrimaryPart.Position).Unit
	else
		unit = Workspace.CurrentCamera.CFrame.LookVector
	end

	grenade.Velocity = unit * GRENADE_SPEED + Vector3.new(0, 30, 0)
end

Grenade.ServerEffect = Grenade.CreateServerEffect(
	ReplicatedStorage.Items.Grenade1,
	SoundService.SFX.Prime,
	function(player, grenade, better)
		local level = player:WaitForChild("PlayerData"):WaitForChild("Level").Value

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
						Grenade.DealDamage(player, zombie, damage)
					end
				end
			end
		end
	end
)

return Grenade
