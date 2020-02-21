local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CircleEffect = require(ReplicatedStorage.Core.CircleEffect)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local DungeonState = require(ServerScriptService.DungeonState)
local Maid = require(ReplicatedStorage.Core.Maid)

local CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

local DAMAGE_BASE = 50
local DAMAGE_INTERVAL = 1
local DAMAGE_SCALE = 1.13
local SCALED_DAMAGE = 0.2

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
				local damage = math.floor(DAMAGE_BASE * (DAMAGE_SCALE ^ (level - 1)))
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

									humanoid:TakeDamage(damage)
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
