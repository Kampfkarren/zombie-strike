local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Effects = require(ReplicatedStorage.RuddevModules.Effects)
local Grenade = require(script.Parent.Parent.Grenade.Basic)

local Effect = ReplicatedStorage.RuddevRemotes.Effect

local HEAL_AMOUNT = 0.25
local HEAL_AMOUNT_BETTER = 0.35
local MAX_RANGE = 50

local HealthGrenade = {}

HealthGrenade.Index = 2
HealthGrenade.Name = "Health Grenade"
HealthGrenade.Icon = "rbxassetid://4515425559"
HealthGrenade.Cooldown = 12

HealthGrenade.ClientEffect = Grenade.ClientEffect

HealthGrenade.ServerEffect = Grenade.CreateServerEffect(
	ReplicatedStorage.Items.HealthPack2.PrimaryPart,
	SoundService.SFX.Items.HealthNadePrime,
	function(_, grenade, better)
		local healAmount = better and HEAL_AMOUNT_BETTER or HEAL_AMOUNT

		for _, otherPlayer in pairs(Players:GetPlayers()) do
			local character = otherPlayer.Character
			if character.Humanoid.Health > 0 then
				local range = (character.PrimaryPart.Position - grenade.Position).Magnitude

				if range <= MAX_RANGE then
					character.Humanoid.Health = character.Humanoid.Health
						+ (character.Humanoid.MaxHealth * healAmount)

					local healthUse = SoundService.SFX.Items.HealthNadeUse:Clone()
					healthUse.Parent = character.PrimaryPart
					healthUse:Play()

					Debris:AddItem(healthUse)
					Effect:FireAllClients(Effects.EffectIDs.Shatter, character, better)
				end
			end
		end
	end
)

return HealthGrenade
