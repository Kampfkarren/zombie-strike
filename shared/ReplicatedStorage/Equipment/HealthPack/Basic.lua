local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Promise = require(ReplicatedStorage.Core.Promise)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local Effect = ReplicatedStorage.RuddevRemotes.Effect
local HealthPackAnimation = ReplicatedStorage.Assets.Animations.HealthPackAnimation

local HEAL_AMOUNT = 0.3
local HEAL_AMOUNT_BETTER = 0.6

local Basic = {}

Basic.Index = 1
Basic.Name = "Health Pack"
Basic.Icon = "http://www.roblox.com/asset/?id=4462345167"
Basic.Cooldown = 10

function Basic.CanUse(player)
	if not ReplicatedStorage.HubWorld.Value then
		local humanoid = player.Character.Humanoid
		if humanoid.Health == humanoid.MaxHealth then
			return false
		end
	end

	return true
end

function Basic.ServerEffect(player)
	local Equip = require(ServerScriptService.Shared.Ruddev.Equip)

	return Promise.new(function(resolve)
		local character = player.Character
		local better = GamePasses.PlayerOwnsPass(
			player, GamePassDictionary.BetterEquipment
		)

		local healthPack = ReplicatedStorage.Items.HealthPack1:Clone()

		healthPack.Parent = character
		Equip(healthPack, character.LeftHand)

		local humanoid = character.Humanoid
		local animation = humanoid:LoadAnimation(HealthPackAnimation)

		local healthPrime = SoundService.SFX.HealthPrime:Clone()
		local healthUse = SoundService.SFX.HealthUse:Clone()

		healthPrime.Parent = character.PrimaryPart
		healthPrime:Play()
		Debris:AddItem(healthPrime)

		healthUse.Parent = character.PrimaryPart
		Debris:AddItem(healthUse)

		local healed = false

		animation.KeyframeReached:connect(function(name)
			if name == "Heal" then
				healthUse:Play()
				healthPack:Destroy()

				if humanoid.Health > 0 then
					humanoid.Health = humanoid.Health + humanoid.MaxHealth
						* (better and HEAL_AMOUNT_BETTER or HEAL_AMOUNT)

					if not healed then
						healed = true
						resolve()
					end
				end

				Effect:FireAllClients("Shatter", character, better)
			end
		end)

		animation:Play()
		RealDelay(3, function()
			if not healed then
				healed = true
				resolve()
			end
		end)
	end)
end

return Basic
