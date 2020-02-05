local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Basic = require(script.Parent.Basic)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Promise = require(ReplicatedStorage.Core.Promise)
local Raycast = require(ReplicatedStorage.Core.Raycast)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local BASE_DAMAGE = 55
local BASE_DAMAGE_BETTER = BASE_DAMAGE * 1.5
local DAMAGE_SCALE = 1.13
local FIRE_LIFETIME = 6

local Molotov = {}

Molotov.Index = 2
Molotov.Name = "Molotov"
Molotov.Icon = "rbxassetid://4515426534"
Molotov.Cooldown = 10

Molotov.ClientEffect = Basic.ClientEffect

local function getDamage(better, level)
	return (better and BASE_DAMAGE_BETTER or BASE_DAMAGE) * DAMAGE_SCALE ^ (level - 1)
end

function Molotov.ServerEffect(player)
	return Promise.new(function(resolve)
		local level = player:WaitForChild("PlayerData"):WaitForChild("Level").Value
		local better = GamePasses.PlayerOwnsPass(
			player, GamePassDictionary.BetterEquipment
		)

		local grenade = ReplicatedStorage.Items.Grenade2:Clone()

		PhysicsService:SetPartCollisionGroup(grenade, "Grenade")
		grenade.CustomPhysicalProperties = Basic.DefaultPhysicalProperties
		grenade.Parent = Workspace
		grenade:SetNetworkOwner(player)

		grenade.Touched:connect(function(part)
			if part:CanCollideWith(grenade) then
				local fire = ServerStorage.Assets.Fire:Clone()

				local _, position = Raycast(grenade.Position, Vector3.new(0, -1000, 0), { grenade })
				fire.Position = position

				if better then
					for _, emitter in pairs(fire:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Color = ColorSequence.new(Color3.new(0, 0, 1))
						end
					end
				end

				fire.Parent = Workspace

				local breakSound = SoundService.SFX.Items.MolotovBreak:Clone()
				breakSound.Parent = fire
				breakSound:Play()

				local loopSound = SoundService.SFX.Items.MolotovFireLoop:Clone()
				loopSound.Parent = fire
				loopSound:Play()

				local active = true

				RealDelay(FIRE_LIFETIME, function()
					for _, emitter in pairs(fire:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					Debris:AddItem(fire)
					active = false
				end)

				FastSpawn(function()
					local delta = 1

					while active do
						for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
							if zombie:IsDescendantOf(Workspace) then
								local distance = (zombie.PrimaryPart.Position - fire.Position).Magnitude
								if distance <= fire.Size.X then
									local damage = getDamage(better, level)
									Basic.DealDamage(player, zombie, damage * delta)
								end
							end
						end

						delta = wait(1)
					end
				end)

				grenade:Destroy()
			end
		end)

		resolve(grenade)
	end)
end

return Molotov
