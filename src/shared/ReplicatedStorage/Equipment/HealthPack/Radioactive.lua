local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local Basic = require(script.Parent.Basic)
local Effects = require(ReplicatedStorage.RuddevModules.Effects)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Promise = require(ReplicatedStorage.Core.Promise)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local Effect = ReplicatedStorage.RuddevRemotes.Effect
local HealthPackAnimation = ReplicatedStorage.Assets.Animations.HealthPackAnimation

local HEAL_AMOUNT = 0.25
local HEAL_AMOUNT_BETTER = 0.35
local SPEED_AMOUNT = 0.4
local SPEED_DURATION = 4

local Radioactive = {}

Radioactive.Index = 4
Radioactive.Name = "Radioactive Health Pack"
Radioactive.Icon = "http://www.roblox.com/asset/?id=4657714613"
Radioactive.Cooldown = 14

Radioactive.CanUse = Basic.CanUse

local function destroyLater(item)
	RealDelay(10, function()
		item:Destroy()
	end)
end

function Radioactive.ServerEffect(player)
	local Equip = require(ServerScriptService.Shared.Ruddev.Equip)

	return Promise.new(function(resolve)
		local character = player.Character
		local better = GamePasses.PlayerOwnsPass(
			player, GamePassDictionary.BetterEquipment
		)

		local healthPack = ReplicatedStorage.Items.HealthPack4:Clone()

		healthPack.Parent = character
		Equip(healthPack, character.LeftHand)

		local humanoid = character.Humanoid
		local animation = humanoid:LoadAnimation(HealthPackAnimation)

		local healthPrime = SoundService.SFX.HealthPrime:Clone()
		local healthUse = SoundService.SFX.HealthUse:Clone()

		healthPrime.Parent = character.PrimaryPart
		healthPrime:Play()
		destroyLater(healthPrime)

		healthUse.Parent = character.PrimaryPart
		destroyLater(healthUse)

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

						local speedMultiplier = player.SpeedMultiplier
						speedMultiplier.Value = speedMultiplier.Value + SPEED_AMOUNT
						RealDelay(SPEED_DURATION, function()
							speedMultiplier.Value = speedMultiplier.Value - SPEED_AMOUNT
						end)

						resolve()
					end
				end

				Effect:FireAllClients(Effects.EffectIDs.Shatter, character, better)
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

return Radioactive
