local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CircleEffect = require(ReplicatedStorage.Core.CircleEffect)
local DealZombieDamage = require(ServerScriptService.Shared.DealZombieDamage)
local DungeonState = require(ServerScriptService.DungeonState)
local Maid = require(ReplicatedStorage.Core.Maid)
local LinearThenLogarithmic = require(ReplicatedStorage.Core.LinearThenLogarithmic)

local CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

local BASE_DAMAGE = 20
local FINAL_DAMAGE = 350
local MULTIPLIER = 15

local DAMAGE_INTERVAL = 1
local SCALED_DAMAGE = 0.2

local getDamage = LinearThenLogarithmic(BASE_DAMAGE, FINAL_DAMAGE, MULTIPLIER)

local active = false
local maid = Maid.new()

ReplicatedStorage.CurrentPowerup.Changed:connect(function(powerup)
	if powerup:match("Tank/") then
		active = true

		for _, player in pairs(Players:GetPlayers()) do
			local forceField = Instance.new("ForceField")
			forceField.Parent = player.Character
			maid:GiveTask(forceField)
		end

		while active do
			local zombies = CollectionService:GetTagged("Zombie")

			for _, player in pairs(Players:GetPlayers()) do
				local level = player
					:WaitForChild("PlayerData")
					:WaitForChild("Level")
					.Value
				local damage = getDamage(level)
				local character = player.Character

				if character and character.Humanoid.Health > 0 then
					CircleEffectRemote:FireAllClients(
						character.PrimaryPart.CFrame,
						CircleEffect.Presets.TANK_BUFF
					)

					for _, zombie in pairs(zombies) do
						if not CollectionService:HasTag(zombie, "Boss") then
							if (zombie.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
								<= CircleEffect.PresetOptions[CircleEffect.Presets.TANK_BUFF].Range
							then
								local humanoid = zombie.Humanoid
								if humanoid.Health > 0 then
									if DungeonState.CurrentGamemode.Scales() then
										damage = humanoid.MaxHealth * SCALED_DAMAGE
									end

									DealZombieDamage(humanoid, damage)
									ReplicatedStorage.RuddevEvents.Damaged:Fire(humanoid, damage, player)
									ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage)
								end
							end
						end
					end
				end
			end

			wait(DAMAGE_INTERVAL)
		end
	elseif active then
		active = false
		maid:DoCleaning()
	end
end)
