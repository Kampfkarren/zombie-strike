local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local CollectionService = game:GetService("CollectionService")
local CircleEffect = require(ReplicatedStorage.Core.CircleEffect)
local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Grenade = require(script.Parent.Basic)
local LinearThenLogarithmic = require(ReplicatedStorage.Core.LinearThenLogarithmic)
local Promise = require(ReplicatedStorage.Core.Promise)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect
local KatanaAnimation = ReplicatedStorage.Assets.Animations.KatanaAnimation

local Katana = {}

local BASE_DAMAGE = 35
local FINAL_DAMAGE = 420
local MULTIPLIER = 15
local BETTER_MULTIPLIER = 1.2

local KATANA_DELAY = 1
local SCALED_DAMAGE = 0.7

Katana.Index = 3
Katana.Name = "Katana"
Katana.Icon = "rbxassetid://4515426071"
Katana.Cooldown = 8

local getDamage = LinearThenLogarithmic(BASE_DAMAGE, FINAL_DAMAGE, MULTIPLIER)

function Katana.ServerEffect(player)
	local Equip = require(ServerScriptService.Shared.Ruddev.Equip)

	return Promise.new(function(resolve)
		local character = player.Character
		local better = GamePasses.PlayerOwnsPass(
			player, GamePassDictionary.BetterEquipment
		)

		local damage = getDamage(player
			:WaitForChild("PlayerData")
			:WaitForChild("Level")
			.Value
		)

		if better then
			damage = damage * BETTER_MULTIPLIER
		end

		local sword = Instance.new("Model")

		local part = ReplicatedStorage.Items.Grenade3:Clone()
		part.Parent = sword
		sword.PrimaryPart = part

		sword.Parent = character
		Equip(sword, character.LeftHand)

		local unsheathSound = SoundService.SFX.Items.KatanaUnsheath:Clone()
		unsheathSound.Parent = sword
		unsheathSound:Play()

		local humanoid = character.Humanoid

		local animation = humanoid:LoadAnimation(KatanaAnimation)
		animation.KeyframeReached:connect(function()
			local slashSound = SoundService.SFX.Items.KatanaSlash:Clone()
			slashSound.Parent = sword
			slashSound:Play()

			CircleEffectRemote:FireAllClients(
				character.PrimaryPart.CFrame,
				CircleEffect.Presets.KATANA
			)

			local zombies = CollectionService:GetTagged("Zombie")

			for _, zombie in pairs(zombies) do
				if (zombie.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
					<= CircleEffect.PresetOptions[CircleEffect.Presets.KATANA].Range
				then
					local humanoid = zombie.Humanoid
					if humanoid.Health > 0 then
						Grenade.DealDamage(player, zombie, damage, SCALED_DAMAGE)
						ReplicatedStorage.RuddevEvents.Damaged:Fire(humanoid, damage, player)
						ReplicatedStorage.Remotes.DamageNumber:FireAllClients(humanoid, damage)
					end
				end
			end
		end)
		animation:Play()

		RealDelay(KATANA_DELAY, function()
			sword:Destroy()
			resolve()
		end)
	end)
end

return Katana
